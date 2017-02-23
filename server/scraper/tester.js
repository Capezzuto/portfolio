const moment = require('moment');
// const getDailyData = require('./scrape-bom-mongo.js').getDailyData;
// const getWeeklyData = require('./scrape-bom-mongo.js').getWeeklyData;
const getDailyData = require('./scrape-bom-daily.js');
const getWeeklyData = require('./scrape-bom-weekly.js');
const weekCount = require('./week.json');
const fs = require('fs');
const redis = require('redis');


// getDailyData({date:'2017-02-21', week: '07', year: '2017'})
//   .then((output) => {
//     console.log(output)
//     getDailyData({date:'2017-02-21', week: '07', year: '2017'})
//
//   });

  getWeeklyData({ week: '07', year: '2017'})
      // .then((output) => {
      //   console.log(output);
      //   // getDailyData({date:'2017-02-21', week: '07', year: '2017'})
      //   getWeeklyData({ week: '07', year: '2017'})
      //
      // })

  setTimeout(() => {
    getDailyData({date:'2017-02-21', week: '07', year: '2017'})

  }, 9000)

//   getDailyData({date:'2017-02-21', week: '07', year: '2017'})
//     .then((out) => doesNothing());
//     // .then((output) => {
//     //   console.log(output)
//     //   getDailyData({date:'2017-02-21', week: '07', year: '2017'})
//     //   getWeeklyData({ week: '07', year: '2017'})
//
//     // });
//
// function doesNothing() {
//   return new Promise((resolve, reject) => {
//     console.log('But I\'m doing it')
//     if (1 !== 1) reject();
//     resolve();
//   });
// }
