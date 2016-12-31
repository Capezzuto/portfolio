// const weeklyData = require('../scraper/weekly-data.json');
// const dailyData = require('../scraper/daily-data.json');
const DailyBoxOffice = require('./boxOfficeDailyModel.js');
const WeeklyBoxOffice = require('./boxOfficeWeeklyModel.js');

const url = require('url');

module.exports = {
  '/weekly': {
    //should get all available weeks in array to populate selection menu
  },
  // the :week query string should be in the format: 'yyyy_ww'
  '/weekly/:week': {
    get(req, res) {
      const week = url.parse(req.url, true).path.slice(8);
      const year = week.slice(0, 4);

      WeeklyBoxOffice.findOne({ week: week }).then((data)=> {

      })
      if (!(week in weeklyData)) res.status(404).send('Unable to retrieve data')

      const weekTotals = weeklyData[week];
      const days = [];

      for (let key in dailyData) {
        if (key.slice(0, 4) === year && dailyData[key].week === week.slice(5)) {
          days.push(dailyData[key]);
        }
      }

      days.sort((a, b) => {
        if (a.date < b.date) return -1;
        if (a.date > b.date) return 1;
        return 0;
      });

      const data = Object.assign({}, { weekTotals }, { days });

      res.status(200).send(data);
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
