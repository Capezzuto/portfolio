const moment = require('moment');
const scraper = require('./scrape-bom-mongo.js');
// /************************************************************/
// if Jan 01 of Date.now's year is a Fri, add 3 days, then get the week
// if Jan 01 of Date.now's year is a mon, tue, wed, or thu, subtract 4 days, then get the week
// if Jan 01 of Date.now's year is a sat or sun, do nothing
// /*************************************************************/
let yesterday = moment().subtract(1, 'days');
let year = yesterday.year();
let yearStartDay = moment(year, 'YYYY').isoWeekday();
let yest = moment().subtract(1, 'days')
let week = yest.isoWeek();
let date = yesterday.format('YYYY-MM-DD');
if (yearStartDay < 5) week = yest.subtract(4, 'days').isoWeek();
if (yearStartDay === 5) week = yest.add(3, 'days').isoWeek();

//run weekly scraper
if (yesterday.isoWeekday() === 4) {
  scraper.getWeeklyData({ year, week });
}

//run daily scraper
scraper.getDailyData({ date, week });
