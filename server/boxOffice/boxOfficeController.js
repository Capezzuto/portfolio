// const weeklyData = require('../scraper/weekly-data.json');
// const dailyData = require('../scraper/daily-data.json');
const DailyBoxOffice = require('./boxOfficeDailyModel.js');
const WeeklyBoxOffice = require('./boxOfficeWeeklyModel.js');

const url = require('url');

module.exports = {
  '/weekly': {
    //should get all available weeks in array to populate selection menu
    get(req, res) {
      WeeklyBoxOffice
        .find()
        .select('week date_range')
        .limit(52)
        .exec((err, weeks) => {
          if (err) {
            console.log('error in data/boxoffice/weekly...', err);
            res.status(500).send(err);
          }
          res.status(200).send(weeks);
        })

    }
  },
  // the :week query string should be in the format: 'yyyy_ww'
  '/weekly/:week': {
    get(req, res) {
      const week = url.parse(req.url, true).path.slice(8);

      WeeklyBoxOffice
        .findOne({ week: week })
        .populate({
          path: 'days',
          select: 'date top10.title top10.daily_gross top10.theaters top10.avg',
          options: { sort: { date: 1 } }
        })
        .exec((err, week) => {
          console.log('sending week...', week)
          res.status(200).send(week);
        })

    }
  },
  '/daily/:date': {
    get(req, res) {
      const date = url.parse(req.url, true).path.slice(7);
      if (!(date in dailyData)) res.status(404).send('Unable to retrieve data');
      const data = dailyData[date];
      res.status(200).send(data);
    }
  }
}
