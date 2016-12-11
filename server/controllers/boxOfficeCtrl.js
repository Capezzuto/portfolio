const weeklyData = require('../scraper/weekly-data.json');
const dailyData = require('../scraper/daily-data.json');
const url = require('url');

module.exports = {
  '/weekly/:week': {
    get(req, res) {
      const week = url.parse(req.url, true).path.slice(8);
      const year = week.slice(0, 4);
      
      if (!(week in weeklyData)) res.status(404).send('Unable to retrieve data')

      const weekTotals = weeklyData[week];
      const days = {};

      for (let key in dailyData) {
        if (key.slice(0, 4) === year && dailyData[key].week === week.slice(5)) {
          days[key] = dailyData[key];
        }
      }

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
