require('dotenv').config({ path: '/Users/capezzuto/portfolio/.env'});
const config = require('../config/config.js');
const cheerio = require('cheerio');
const phantom = require('phantom');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
const BoxOfficeWeekly = require('../boxOffice/boxOfficeWeeklyModel.js');
const BoxOfficeDaily = require('../boxOffice/boxOfficeDailyModel.js');

const args = process.argv.slice(2);

module.exports = {
  getWeeklyData: function(arg) {
    let _ph, _page;
    const bomURL = `http://www.boxofficemojo.com/weekly/chart/?yr=${arg.year}&wk=${arg.week}&p=.htm`;
    console.log('0.i in getWeeklyData....')
    mongoose.connect(config.db);
    const db = mongoose.connection;
    console.log('0.ii connected to mongoose...');
    return new Promise((resolve, reject) => {

      db.on('error', () => {
        console.error('Error opening connection');
        reject();
      });
      db.on('open', () => {
        console.log('I.i about to create phantom instance....', bomURL)
        phantom.create()
          .then((ph) => {
          _ph = ph;
          console.log('I.ii assigning _ph...', typeof _ph)
          return _ph.createPage();
          })
          .then((page) => {
            _page = page;
            console.log('I.iii assigning _page...', typeof _page)
            return _page.open(bomURL);
          })
          .then((status) => {
            console.log('I.iv status....', status);
            return _page.evaluate(function() {
              return document.querySelector('#body').outerHTML;
            })
          })
          .then((html) => {

            console.log('II.i getting html..');

            const $ = cheerio.load(html);

            let weeklyData = $('#body')
                            .find('.nav_tabs')
                            .nextAll('center')
                            .find('table').slice(1)
                            .find('tr').slice(1)
                            .find('td').slice(0, 120)
                            .map(function(i, el) {
                              return $(this).text();
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
                console.log('III.i creating weekly entry...', output);
                BoxOfficeDaily
                  .find({ week })
                  .select('_id')
                  .exec((err, days) => {
                    if (err)  return err;
                    output.days = days;
                    console.log('III.ii updating weekly entry...')
                    output.save((err, updatedDoc) => {
                      if (err) return err;
                      // console.log('----------------->', updatedDoc);
                      _page.close()
                        .then(() => _ph.exit())
                        .then(() => {
                          db.close(() => {
                            resolve(updatedDoc);
                          });
                        });

                    })
                  });

              })
              .catch((err) => {
                console.log(err);
                return _page.close()
                  .then(() => _ph.exit())
                  .then(() => {
                    db.close();
                    reject(err);
                  });
              });
          })
          .catch(err => {
            console.log(err);
            return _page.close()
              .then(() => _ph.exit())
              .then(() => {
                db.close();
                reject(err);
              });

          });
      });
    });
  },
  getDailyData: function(arg) {
    let _ph, _page;
    const bomURL = `http://www.boxofficemojo.com/daily/chart/?sortdate=${arg.date}&view=1day&p=.htm`;

    mongoose.connect(config.db);
    const db = mongoose.connection;
    return new Promise((resolve, reject) => {
      db.on('error', console.error.bind(console, 'Error opening connection'));
      db.on('open', () => {
        console.log('1 starting phantom...', bomURL);
        phantom.create()
          .then((ph) => {
            _ph = ph;
            console.log('1.1 assigned _ph', typeof _ph)
            return _ph.createPage();
          })
          .then((page) => {
            _page = page;
            console.log('1.2 assigned _page', typeof _page)
            return _page.open(bomURL);
          })
          .then((status) => {
            console.log('1.3 about to evaluate _page...')
            return _page.evaluate(function() {
              return document.querySelector('#body').outerHTML;
            })
          })
          .then((html) => {
            console.log('2 getting html...');

            const $ = cheerio.load(html);

            let dailyData = $('#body')
            .find('center')
            .find('table').slice(2,3)
            .find('tr').slice(1)
            .find('td').slice(0,110)
            .map(function(i, el) {
              return $(el).text();
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

            return BoxOfficeDaily.create(jsonData)
              .then((output) => {
                console.log('3 creating daily data entry...')
                _page.close()
                .then(() => {
                  console.log('3.1 _page closed, now exiting...');
                  return _ph.exit();
                })
                .then(() => {
                  console.log('3.2 closing mongoose connection...');
                  db.close(() => {
                    resolve(output);
                  });

                })
                .catch((err) => {
                  console.log(err);
                  return _page.close()
                    .then(() => _ph.exit())
                    .then(() => {
                      db.close();
                      reject(err);
                    });
                });

              })
              .catch((err) => {
                console.log(err);
                return _page.close()
                  .then(() => _ph.exit())
                  .then(() => {
                    db.close();
                    reject(err);
                  });
              });
          });
      }); // db.on('open')

    }); // closing promise
  }
};


/***************************************************************************************
** process.argv's first argument (args[0]) should be a string: 'week' or 'day'        **
** process.argv's second argument (args[1]) should be the year                        **
** process.argv's third argument (args[2]) should be the week                         **
** process.argv's fourth argument (optional, args[3]) should be the date (yyyy-mm-dd) **
***************************************************************************************/
if (args[0] === 'week') {
module.exports.getWeeklyData({ year: args[1], week: args[2] });
}
if (args[0] === 'day') {
module.exports.getDailyData({ year: args[1], week: args[2], date: args[3] });
}
