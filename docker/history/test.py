from steem import Steem
from pymongo import MongoClient
from pprint import pprint

from apscheduler.schedulers.background import BackgroundScheduler

fullnodes = [
    #'http://10.60.103.43:8080',
    'http://gnexportal.com:9000',
]
rpc = Steem(fullnodes)
mongo = MongoClient("mongodb://195.181.245.47")
#mongo = MongoClient("mongodb://10.40.103.102")
db = mongo.steemdb


if __name__ == '__main__':
    pprint("starting");
    # Load all account data into memory

    item = db.account.find()
    for entry in item:
      print(item)

    db.statistics.update({
      'key': 'users',
      'date': 'test',
    }, {
      'key': 'users',
      'date': 'test',
      'value': 100
    }, upsert=True)
    print ('over')
