from datetime import datetime
from pymongo import MongoClient
from steem import Steem
from pprint import pprint
from time import gmtime, strftime
from apscheduler.schedulers.background import BackgroundScheduler
import collections
import time
import sys
import os

env_dist = os.environ
steemd_url = env_dist.get('STEEMD_URL')
if steemd_url == None or steemd_url == "":
    steemd_url = 'http://gnexportal.com:9000'
mongodb_url = env_dist.get('MONGODB')
if mongodb_url == None or mongodb_url == "":
    print('NEED MONGODB')
    exit()

fullnodes = [
    #'http://10.40.103.102:8090',
    'http://gnexportal.com:9876',
    #'http://10.60.103.43:8080',
    steemd_url,
]
rpc = Steem(fullnodes)

mongo = MongoClient(mongodb_url)
db = mongo.steemdb

misses = {}

log_tag = '[Witness] '

# Command to check how many blocks a witness has missed
def check_misses():
    global misses
    witnesses = rpc.get_witnesses_by_vote('', 100)
    for witness in witnesses:
        owner = str(witness['owner'])
        # Check if we have a status on the current witness
        if owner in misses.keys():
            # Has the count increased?
            if witness['total_missed'] > misses[owner]:
                # Update the misses collection
                record = {
                  'date': datetime.now(),
                  'witness': owner,
                  'increase': witness['total_missed'] - misses[owner],
                  'total': witness['total_missed']
                }
                db.witness_misses.insert(record)
                # Update the misses in memory
                misses[owner] = witness['total_missed']
        else:
            misses.update({owner: witness['total_missed']})



def update_witnesses():
    now = datetime.now().date()
    # pprint("[GNEX] - Update Miner Queue")
    # miners = rpc.get_miner_queue()
    # db.statistics.update({
    #   '_id': 'miner_queue'
    # }, {
    #   'key': 'miner_queue',
    #   'updated': datetime.combine(now, datetime.min.time()),
    #   'value': miners
    # }, upsert=True)
    scantime = datetime.now()
    users = rpc.get_witnesses_by_vote('', 100)
    #pprint(users)
    pprint(log_tag + "[GNEX] - Update Witnesses (" + str(len(users)) + " accounts)")
    db.witness.remove({})
    for user in users:
        # Convert to Numbers
        for key in ['virtual_last_update', 'virtual_position', 'virtual_scheduled_time', 'votes']:
            user[key] = float(user[key])
        # Convert to Date
        for key in ['last_sbd_exchange_update']:
            user[key] = datetime.strptime(user[key], "%Y-%m-%dT%H:%M:%S")
        # Save current state of account
        db.witness.update({'_id': user['owner']}, user, upsert=True)
        # Create our Snapshot dict
        snapshot = user.copy()
        _id = user['owner'] + '|' + now.strftime('%Y%m%d')
        snapshot.update({
          '_id': _id,
          'created': scantime
        })
        # Save Snapshot in Database
        db.witness_history.update({'_id': _id}, snapshot, upsert=True)

def run():
    update_witnesses()
    check_misses()

if __name__ == '__main__':
    # Start job immediately
    run()
    # Schedule it to run every 1 minute
    scheduler = BackgroundScheduler()
    scheduler.add_job(run, 'interval', seconds=30, id='run')
    scheduler.start()
    # Loop
    try:
        while True:
            time.sleep(2)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown()
