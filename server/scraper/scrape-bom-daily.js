const cheerio = require('cheerio');
const phantom = require('phantom');
const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');

const BoxOfficeDaily = require('../boxOffice/boxOfficeDailyModel.js');

const args = process.argv.slice(2);

module.exports = function getDailyData(arg, db) {
  let _ph, _page;
  const bomURL = `http://www.boxofficemojo.com/daily/chart/?sortdate=${arg.date}&view=1day&p=.htm`;

  return phantom.create()
    .then((ph) => {
      _ph = ph;
      return _ph.createPage();
    })
    .then((page) => {
      _page = page;
      return _page.open(bomURL);
    })
    .then((status) => {
      return _page.evaluate(function() {
        return document.querySelector('#body').outerHTML;
      })
    })
    .then((html) => buildDailyEntry(html, arg))
    .then((output) => _page.close())
    .then(() => _ph.exit())
    .catch((err) => {
      console.log(err);
      return _page.close()
        .then(() => _ph.exit())
    });
};

function buildDailyEntry(html, arg) {
  const $ = cheerio.load(html);

  let dailyData = $('#body')
  .find('center')
  .find('table').slice(2,3)
  .find('tr').slice(1)
  .find('td').slice(0,110)
  .map((i, el) => $(el).text())
  .get();

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
}
