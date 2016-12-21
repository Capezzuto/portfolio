const cheerio = require('cheerio');
const request = require('request');
const moment = require('moment');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
const BoxOfficeWeekly = require('../boxOffice/boxOfficeWeeklyModel.js');
const BoxOfficeDaily = require('../boxOffice/boxOfficeDailyModel.js');
// const fs = require('fs');
// const currWeek = require('./week');
// const weeklyDataFile = require('./weekly-data');
// const dailyDataFile = require('./daily-data');
const args = process.argv.slice(2);
mongoose.connect('mongodb://localhost/localdb');
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'Error opening connection'));
db.on('open', () => {
  /*************************************************************************************
  ** process.argv's first argument (args[0]) should be a string: 'week' or 'day'      **
  ** process.argv's second argument (args[1]) should be the year or date (yyyy-mm-dd) **
  ** process.argv's third argument (args[2]) should be the week                       **
  *************************************************************************************/
  if (args[0] === 'week') {
    module.exports.getWeeklyData({ year: args[1], week: args[2] });
  }
  if (args[0] === 'day') {
    module.exports.getDailyData({ date: args[1], week: args[2] });
  }
})

module.exports = {
  getWeeklyData: function(arg) {
    console.log('in getWeeklyData....');
    request(`http://www.boxofficemojo.com/weekly/chart/?yr=${arg.year}&wk=${arg.week}&p=.htm`, (error, response, body) => {
      if (error) {
        console.log('Error: ', error);
      }
      console.log('Status code: ', response.statusCode);

      const $ = cheerio.load(body);

      let weeklyData = $('#body')
                      .find('.nav_tabs')
                      .nextAll('center')
                      .find('table').slice(1)
                      .find('tr').slice(1)
                      .find('td')
                      .map(function(i, el) {
                        if (i < 120) return $(this).text();
                      }).get();

      let week = `${arg.year}_${arg.week}`;
      let total_gross = $('#body')
                          .find('tr')
                          .last()
                          .prev('tr')
                          .find('tr')
                          .last()
                          .find('td')
                          .eq(1).text();
      total_gross = Number(total_gross.replace(/\D/g, ''));

      let jsonData = weeklyData.reduce(function(obj, curr, i) {
        let x = i % 12;
        let entry = Math.floor(i/12);
        switch(x) {
          case 0: obj.movies[entry] = { rank: Number(curr) }; break;
          case 1: obj.movies[entry]['prev_rank'] = Number(curr) || 0; break;
          case 2: obj.movies[entry]['title'] = curr; break;
          case 3: obj.movies[entry]['studio'] = curr; break;
          case 4: obj.movies[entry]['week_gross'] = Number(curr.replace(/\D/g, '')); break;
          case 5: obj.movies[entry]['pct_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 6: obj.movies[entry]['theaters'] = Number(curr.replace(/\D/g, '')); break;
          case 7: obj.movies[entry]['theater_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 8: obj.movies[entry]['avg'] = Number(curr.replace(/\D/g, '')); break;
          case 9: obj.movies[entry]['total'] = Number(curr.replace(/\D/g, '')); break;
          case 10: obj.movies[entry]['budget'] = Number(curr.replace(/\$/g, '')) || 0; break;
          case 11: obj.movies[entry]['week'] = Number(curr); break;
          default: break;
        }
        return obj;
      }, { week, total_gross, movies: [] });

      BoxOfficeWeekly.create(jsonData)
        .then((output) => {
          console.log('created...', output);
          mongoose.disconnect();
        })
        .catch((err) => {
          console.log('error', err);
          mongoose.disconnect();
        });
    });


  },
  getDailyData: function(arg) {
    console.log('in getDailyData...');
    let dailyData;
    request(`http://www.boxofficemojo.com/daily/chart/?sortdate=${arg.date}&view=1day&p=.htm`, (error, response, body) => {
      if(error) {
        console.log(error);
      }
      console.log('status code:', response.statusCode);

      const $ = cheerio.load(body);

      dailyData = $('#body')
                    .find('center')
                    .find('table').slice(2,3)
                    .find('tr').slice(1)
                    .find('td')
                    .map(function(i, el) {
                      if (i < 110) return $(el).text();
                    }).get();

      let jsonData = dailyData.reduce((obj, curr, i) => {
        let x = i % 11;
        let entry = Math.floor(i/11);
        switch(x) {
          case 0: obj.top10[entry] = { rank_today: Number(curr) }; break;
          case 1: obj.top10[entry]['rank_yesterday'] = Number(curr) || 0; break;
          case 2: obj.top10[entry]['title'] = curr; break;
          case 3: obj.top10[entry]['studio'] = curr; break;
          case 4: obj.top10[entry]['daily_gross'] = Number(curr.replace(/\D/g, '')); break;
          case 5: obj.top10[entry]['pct_change_yd'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 6: obj.top10[entry]['pct_change_lw'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 7: obj.top10[entry]['theaters'] = Number(curr.replace(/\D/g, '')); break;
          case 8: obj.top10[entry]['avg'] = Number(curr.replace(/\D/g, '')); break;
          case 9: obj.top10[entry]['total'] = Number(curr.replace(/\D/g, '')); break;
          case 10: obj.top10[entry]['day'] = Number(curr); break;
          default: break;
        }
        return obj;
      }, { date: arg.date, week: arg.week, top10: [] });

      BoxOfficeDaily.create(jsonData)
        .then((output) => {
          console.log('created...', output);
          mongoose.disconnect();
        })
        .catch((err) => {
          console.log('error', err);
          mongoose.disconnect();
        });
    })
  }
}

function _writeToFile(fileName, oldData, newData, time, year) {
  let keystring = year ? `${year}_${time}` : time;
  if (typeof oldData != 'object') {
    console.error('the type of data supplied is wrong')
    throw err;
  }
  oldData[keystring] = newData;
  fs.writeFile(fileName, JSON.stringify(oldData, null, 2), (err) => {
    if (err) console.log(err);
    console.log(`wrote to ${fileName}`);
  });

}
