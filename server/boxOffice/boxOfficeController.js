const url = require('url');
const redis = require('redis');
const bluebird = require('bluebird');

bluebird.promisifyAll(redis.RedisClient.prototype);
bluebird.promisifyAll(redis.Multi.prototype);

const latestCache = require('../redis/start-routine').latest;

const DailyBoxOffice = require('./boxOfficeDailyModel.js');
const WeeklyBoxOffice = require('./boxOfficeWeeklyModel.js');


module.exports = {
  '/weekly': {
    //should get all available weeks in array to populate selection menu
    get(req, res) {
      const client = redis.createClient();

      client.hgetallAsync('menu')
        .then((weeks) => {
          res.status(200).send(weeks);
          client.quit();
        })
        .catch((err) => {
          res.status(500).send(err);
          client.quit();
        });
      // WeeklyBoxOffice
      //   .find()
      //   .select('week date_range')
      //   .limit(52)
      //   .exec((err, weeks) => {
      //     if (err) {
      //       console.log('error in data/boxoffice/weekly...', err);
      //       res.status(500).send(err);
      //     }
      //     res.status(200).send(weeks);
      //   })

    }
  },
  // the :week query string should be in the format: 'yyyy_ww'
  '/weekly/:week': {
    get(req, res) {
      const week = url.parse(req.url, true).path.slice(8);

      if (latestCache.week === week) {
        res.status(200).send(latestCache);
      } else {
        WeeklyBoxOffice
        .find({ week: week })
        .select('-movies.studio -movies.budget -movies.week -movies.prev_rank')
        .populate({
          path: 'days',
          select: 'date top10.title top10.daily_gross top10.theaters top10.avg',
          options: { sort: { date: 1 } }
        })
        .exec((err, data) => {
          if (err) {
            res.status(500).send(err);
          }
          res.status(200).send(data[0]);
        })
      }

    }
  },
  '/weekly/latest': {
    get(req, res) {
      console.log('in /weekly/latest')
      res.status(200).send(latestCache);
    }
  },
  '/daily/:date': {
    get(req, res) {
      const date = url.parse(req.url, true).path.slice(7);
      // if (!(date in dailyData)) res.status(404).send('Unable to retrieve data');
      // const data = dailyData[date];
      res.status(200).send(date);
    }
  }
}
