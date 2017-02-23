require('dotenv').config({ path: '/Users/capezzuto/portfolio/.env'});
const config = require('../config/config.js');
const cheerio = require('cheerio');
const phantom = require('phantom');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');

const BoxOfficeWeekly = require('../boxOffice/boxOfficeWeeklyModel.js');
const BoxOfficeDaily = require('../boxOffice/boxOfficeDailyModel.js');

const args = process.argv.slice(2);

module.exports = function getWeeklyData(arg, db) {
  let _ph, _page;
  const bomURL = `http://www.boxofficemojo.com/weekly/chart/?yr=${arg.year}&wk=${arg.week}&p=.htm`;
  console.log('0.i in getWeeklyData....&&&&&&&&&&&&&&&&')

  console.log('readyState', mongoose.connection.readyState);

  return phantom.create()
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
    .then((html) => buildWeeklyEntry(html, arg))
    .then(() => {
      console.log('proceeding...');
      return _page.close()
    })
    .then(() => _ph.exit())
    .catch((err) => {
      console.log(err);
      return _page.close()
        .then(() => _ph.exit())
    });

};

function buildWeeklyEntry(html, arg) {
  console.log('in buildWeeklyEntry.....')
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


  return BoxOfficeWeekly.create(jsonData, function() { console.log('created'); })
    .then((output) => {
      console.log('III.i creating weekly entry...', output);
      return BoxOfficeDaily
            .find({ week: output.week })
            .select('_id')
            .exec((err, days) => {
              if (err)  return err;
              output.days = days;
              console.log('III.ii updating weekly entry...')
              output.save((err, updatedDoc) => {
                if (err) return err;
                console.log('-----------------> updatedDoc');
              });
            });
      });
}

//module.exports({ year: args[1], week: args[2] });
