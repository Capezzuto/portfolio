require('dotenv').config({ path: '/Users/capezzuto/portfolio/.env'});
const config = require('../config/config.js');

const moment = require('moment');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
const redis = require('redis');

const cache = require('../redis/start-routine.js');
const getDailyData = require('./scrape-bom-daily.js');
const getWeeklyData = require('./scrape-bom-weekly.js');
const getLatestWeek = require('./scrape-bom-latest-week.js');

let yesterday = moment().subtract(1, 'days'); // start with yesterday's date
let date = yesterday.format('YYYY-MM-DD'); // get formatted date for query
let weekAndYear;

//run daily scraper
mongoose.connect(config.db)
  .then(function() { return getLatestWeek(); })
  .then(function(latestWeek) {
    weekAndYear = latestWeek;
    let { week, year } = weekAndYear;
    if (week != null) {
      week = ++week < 10 ? '0' + week : String(week);
      if (parseInt(week) > 52) {
        week = '01';
        year = String(year++);
      }
      return getDailyData({ date, week, year });
    }
    return;
  })
  .then(function() {
    //run weekly scraper
    if (yesterday.isoWeekday() === 4) { // run this code only on fridays
      let { year, week } = weekAndYear;
      if (week !== null) {
        return getWeeklyData({ year, week })
          .then(function() {
            const client = redis.createClient();
            client.on('error', function(err) {
              console.log('Error in connecting to redis', err);
            });
            client.on('connect', function(response) {
              console.log('successfully connected to redis...', response);
            });
            return cache.populateMenu(client)
            .then(() => cache.getLatestWeeklyBoxOffice(client))
            .then(() => client.quit());
          })
          .catch((err) => {
            console.log(err);
            return err;
          });
      }
    }
    return;
})
.then(function() {
  console.log('closing mongoose connection');
  return mongoose.connection.close();
})
.catch(function(err) {
  console.log('error', err)
  return mongoose.connection.close();
})
