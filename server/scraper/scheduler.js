require('dotenv').config({ path: '/Users/capezzuto/portfolio/.env'});
const config = require('../config/config.js');

const moment = require('moment');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
const fs = require('fs');
const redis = require('redis');

const getDailyData = require('./scrape-bom-daily.js');
const getWeeklyData = require('./scrape-bom-weekly.js');
const weekCount = require('./week.json');

let yesterday = moment().subtract(1, 'days'); // start with yesterday's date
let date = yesterday.format('YYYY-MM-DD'); // get formatted date for query
let week = weekCount.week < 10 ? '0' + weekCount.week : String(weekCount.week); // set initial value for week according to iso standard
let year = String(weekCount.year); // now get year according to yest's value, altered by yearStartDay
// console.log(`typeof week is ${typeof weekCount.week} and typeof year is ${typeof weekCount.year}`)
console.log('yesterday.isoWeekday() is', yesterday.isoWeekday());

let thisYear = moment().year(); // year for today's date
let yearStartDay = moment(thisYear, 'YYYY').isoWeekday(); // check the day of the week the year started on

//run daily scraper
mongoose.connect(config.db)
  .then(function() { return getDailyData({ date, week, year }) })
  .then(function() {
    //run weekly scraper
    if (yesterday.isoWeekday() === 4) { // run this code only on fridays
      return getWeeklyData({ year, week })
        .then(function() {
          if (weekCount.week >= 52) { // is week 52 associated with yesterday's data?
            if (yearStartDay <= 5 || weekCount.week === 53) { // did this new year start sometime in the past week? or are we already on week 53?
              weekCount.week = 0; // if so, then starting on this friday, we start our week count over at 1 (zero, but we'll increment below)
              weekCount.year++; // and we increment the year
            }
          }
          console.log('pretending to increment weekCount.week');
          //weekCount.week++;  // either way, increment the week TODO: uncomment this line
          let json = JSON.stringify(weekCount);
          fs.writeFile('week.json', json, 'utf8'); // write new weekCount data
        })
        .then(function() {
          console.log('TODO: update redis')
        });
    }
    return;
})
.then(function() {
  mongoose.connection.close();
})
.catch(function(err) {
  mongoose.connection.close();
})
