{% extends 'layouts/default.volt' %}

{% block header %}

{% endblock %}

{% block content %}
{#<div class="ui vertical stripe segment">
  <div class="ui middle aligned stackable grid container">
    <div class="row">
      <div class="column">
        <div class="ui huge header">
          Steem Apps
          <div class="sub header">
            Applications and Platforms powered by the Gnex blockchain.
          </div>
        </div>
        <div class="ui secondary inverted menu">
          <a class="active item">
            Clients
          </a>
          <a class="item">
            Explorers
          </a>
          <a class="item">
            Development
          </a>
          <a class="item">
            Utilities
          </a>
          <a class="item">
            Misc
          </a>
        </div>
      </div>
    </div>
  </div>#}
  <div class="ui hidden divider"></div>
  <div class="ui container">
    <div class="ui segment">
      <div class="ui middle aligned stackable grid">
        <div class="one column row">
          <div class="column">
            <div class="ui huge header">
              Platforms
              <div class="sub header">
                User interfaces for interacting with the Gnexcoin blockchain
              </div>
            </div>
          </div>
        </div>
        <div class="one column row">
          <div class="column">
            <div class="ui divider"></div>
            <div class="ui header">
              Platform Details
              <div class="sub header">
                The most prominent platforms have their own profile pages, click the link below to view them. To get added to this list, contact <a href="/@starfall">ray.wu</a> on gnexcoin.
              </div>
            </div>
            <table class="ui stripped compact table">
              {% for platform in platforms %}
              <tr>
                <td>
                <a href="/app/{{platform}}">
                  {{ platform }}
                </a>
                </td>
              </tr>
              {% endfor %}
            </table>
          </div>
        </div>
        <div class="one column row">
          <div class="column">
            <div class="ui divider"></div>
            <div class="ui header">
              Platform Charts
              <div class="sub header">
                Visualizations of platform statistics. Click on the name of a platform in the legend to enable/disable.
              </div>
            </div>
            <div id="dominance" style="min-width: 310px; height: 500px; max-width: 1200px; margin: 0 auto"></div>
          </div>
        </div>
        <div class="two column row">
          <div class="column">
            <div id="posts" style="min-width: 310px; height: 400px; max-width: 800px; margin: 0 auto"></div>
          </div>
          <div class="column">
            <div id="beneficiares" style="min-width: 310px; height: 400px; max-width: 800px; margin: 0 auto"></div>
          </div>
        </div>
        <div class="one column row">
          <div class="column">
            <div class="ui divider"></div>
            <div class="ui large header">
              Recent Performance of All Platforms
              <div class="sub header">
                Showing posts and rewards generated by each application.
              </div>
            </div>
          </div>
        </div>
        <div class="one column row">
          <div class="ui divider"></div>
          <table class="ui table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Rewards</th>
                <th>Posts</th>
                <th>Breakdown</th>
              </tr>
            </thead>
            <tbody>
              {% for day in dates %}
                <tr>
                  <td>
                    {{ day._id.year }}-{{ day._id.month }}-{{ day._id.day }}
                  </td>
                  <td>
                    ${{ day.reward }}
                  </td>
                  <td>
                    {{ day.total }}
                  </td>
                  <td class='collapsing'>
                    <table class="ui compact small table">
                      <thead>
                        <tr>
                          <th>Platform</th>
                          <th>Posts Created</th>
                          <th>Post Rewards (Users)</th>
                        </tr>
                      </thead>
                      <tbody>
                        {% for client in day.clients %}
                        <tr>
                          <td>
                            {% if client.client in platforms %}
                            <a href="/app/{{client.client}}">
                              {{ (client.client) ? client.client : 'unknown' }}
                            </a>
                            {% else %}
                              {{ (client.client) ? client.client : 'unknown' }}
                            {% endif %}
                          </td>
                          <td>
                            <?php echo round($client->count / $day->total * 100, 2); ?>% ({{ client.count }})
                          </td>
                          <td>
                           <?php echo round($client->reward / $day->reward * 100, 2); ?>% (${{ client.reward }})
                          </td>
                        </tr>
                        {% endfor %}
                      </tbody>
                    </table>
                  </td>
                </tr>
              {% endfor %}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
<script src="https://code.highcharts.com/highcharts.src.js"></script>
<script>

Highcharts.chart('dominance', {
      chart: {
          type: 'area'
      },
      title: {
          text: 'Platform Dominance (90 days)'
      },
      tooltip: {
          pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
      },
      xAxis: {
          categories: <?php echo json_encode($dominancedates) ?>
      },
      yAxis: {
          title: {
              text: 'Percent'
          }
      },
      tooltip: {
          pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f})<br/>',
          split: true
      },
      plotOptions: {
          area: {
              stacking: 'percent',
              lineColor: '#ffffff',
              lineWidth: 1,
              marker: {
                  enabled: false,
                  lineWidth: 1,
                  lineColor: '#ffffff'
              }
          }
      },
      series: <?php echo json_encode($dominance) ?>
  });

Highcharts.chart('posts', {
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            type: 'pie'
        },
        title: {
            text: 'Rewards Generated per Platform (90 days)'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
                showInLegend: true
            }
        },
        series: [{
            name: 'Apps',
            colorByPoint: true,
            data: <?php echo json_encode($rewards) ?>
        }]
    });


Highcharts.chart('beneficiares', {
  chart: {
      type: 'area'
  },
  title: {
      text: 'Beneficiares Reward Earned per Platform by Date'
  },
  xAxis: {
      type: 'datetime',
      categories: <?php echo json_encode($appdates) ?>
  },
  yAxis: {
      title: {
          text: 'Percent'
      }
  },
  tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f} VESTS)<br/>',
      split: true
  },
  plotOptions: {
      area: {
          stacking: 'percent',
          lineColor: '#ffffff',
          lineWidth: 1,
          marker: {
              lineWidth: 1,
              lineColor: '#ffffff'
          }
      }
  },
  series: <?php echo json_encode($apps) ?>
});
</script>

{% endblock %}
