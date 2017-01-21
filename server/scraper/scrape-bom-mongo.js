require('dotenv').config({ path: '/home/capezzuto/portfolio/.env'});
const config = require('../config/config.js');
const cheerio = require('cheerio');
const request = require('request');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
const BoxOfficeWeekly = require('../boxOffice/boxOfficeWeeklyModel.js');
const BoxOfficeDaily = require('../boxOffice/boxOfficeDailyModel.js');

const args = process.argv.slice(2);

module.exports = {
  getWeeklyData: function(arg) {
    mongoose.connect(config.db);
    const db = mongoose.connection;
    db.on('error', console.error.bind(console, 'Error opening connection'));
    db.on('open', () => {
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
        let date_range = $('#body').find('h2').eq(1).text();

        let total_gross = $('#body')
                            .find('tr')
                            .last()
                            .prev('tr')
                            .find('tr')
                            .last()
                            .find('td')
                            .eq(1).text();
        total_gross = Number(total_gross.replace(/\D/g, ''));

        const reducerFuncs = {
          0: function(obj, curr, entry) { obj.movies[entry] = { rank: Number(curr) }; },
          1: function(obj, curr, entry) { obj.movies[entry]['prev_rank'] = Number(curr) || 0; },
          2: function(obj, curr, entry) { obj.movies[entry]['title'] = curr; },
          3: function(obj, curr, entry) { obj.movies[entry]['studio'] = curr; },
          4: function(obj, curr, entry) { obj.movies[entry]['week_gross'] = Number(curr.replace(/\D/g, '')); },
          5: function(obj, curr, entry) { obj.movies[entry]['pct_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0;},
          6: function(obj, curr, entry) { obj.movies[entry]['theaters'] = Number(curr.replace(/\D/g, '')); },
          7: function(obj, curr, entry) { obj.movies[entry]['theater_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; },
          8: function(obj, curr, entry) { obj.movies[entry]['avg'] = Number(curr.replace(/\D/g, '')); },
          9: function(obj, curr, entry) { obj.movies[entry]['total'] = Number(curr.replace(/\D/g, '')); },
          10: function(obj, curr, entry) { obj.movies[entry]['budget'] = Number(curr.replace(/\$/g, '')) || 0; },
          11: function(obj, curr, entry) { obj.movies[entry]['week'] = Number(curr) || 1; },
        }

        let jsonData = weeklyData.reduce((obj, curr, i) => {
          let x = i % 12;
          let entry = Math.floor(i/12);
          reducerFuncs[x](obj, curr, entry);
          return obj;
        }, { week, date_range, total_gross, movies: [], days: [] });

        BoxOfficeWeekly.create(jsonData)
          .then((output) => {
            BoxOfficeDaily
              .find({ week })
              .select('_id')
              .exec((err, days) => {
                if (err)  return err;
                output.days = days;
                output.save((err, updatedDoc) => {
                  if (err) return err;
                  // console.log('----------------->', updatedDoc);
                  mongoose.disconnect();
                })
              });
          })
          .catch((err) => {
            console.log('error', err);
            mongoose.disconnect();
          });
      });
    });
  },
  getDailyData: function(arg) {
    mongoose.connect(config.db);
    const db = mongoose.connection;
    db.on('error', console.error.bind(console, 'Error opening connection'));
    db.on('open', () => {
      let dailyData;
      request(`http://www.boxofficemojo.com/daily/chart/?sortdate=${arg.date}&view=1day&p=.htm`,
        (error, response, body) => {
          if(error) {
            console.log(error);
          }
          // console.log('status code:', response.statusCode);

          const $ = cheerio.load(body);

          dailyData = $('#body')
                        .find('center')
                        .find('table').slice(2,3)
                        .find('tr').slice(1)
                        .find('td')
                        .map(function(i, el) {
                          if (i < 110) return $(el).text();
                        }).get();

          const reducerFuncs = {
            0: function(obj, curr, entry) { obj.top10[entry] = { rank_today: Number(curr) }; },
            1: function(obj, curr, entry) { obj.top10[entry]['rank_yesterday'] = Number(curr) || 0; },
            2: function(obj, curr, entry) { obj.top10[entry]['title'] = curr; },
            3: function(obj, curr, entry) { obj.top10[entry]['studio'] = curr; },
            4: function(obj, curr, entry) { obj.top10[entry]['daily_gross'] = Number(curr.replace(/\D/g, '')); },
            5: function(obj, curr, entry) { obj.top10[entry]['pct_change_yd'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; },
            6: function(obj, curr, entry) { obj.top10[entry]['pct_change_lw'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; },
            7: function(obj, curr, entry) { obj.top10[entry]['theaters'] = Number(curr.replace(/\D/g, '')); },
            8: function(obj, curr, entry) { obj.top10[entry]['avg'] = Number(curr.replace(/\D/g, '')); },
            9: function(obj, curr, entry) { obj.top10[entry]['total'] = Number(curr.replace(/\D/g, '')); },
            10: function(obj, curr, entry) { obj.top10[entry]['day'] = Number(curr) || 1; },
          };

          let jsonData = dailyData.reduce((obj, curr, i) => {
            let x = i % 11;
            let entry = Math.floor(i/11);
            reducerFuncs[x](obj, curr, entry);
            return obj;
          }, { date: arg.date, week: `${arg.year}_${arg.week}`, top10: [] });

          BoxOfficeDaily.create(jsonData)
            .then((output) => {
              console.log('created...', output);
              mongoose.disconnect();
            })
            .catch((err) => {
              console.log('error', err);
              mongoose.disconnect();
            });
      });
    });
  }
};


/*************************************************************************************
** process.argv's first argument (args[0]) should be a string: 'week' or 'day'      **
** process.argv's second argument (args[1]) should be the year or date (yyyy-mm-dd) **
** process.argv's third argument (args[2]) should be the week                       **
*************************************************************************************/
if (args[0] === 'week') {
module.exports.getWeeklyData({ year: args[1], week: args[2] });
}
if (args[0] === 'day') {
module.exports.getDailyData({ year: args[1], week: args[2], date: args[3] });
}
