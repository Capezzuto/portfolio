const cheerio = require('cheerio');
const request = require('request');
const moment = require('moment');
const fs = require('fs');
const currWeek = require('./week');
const weeklyDataFile = require('./weekly-data');
const dailyDataFile = require('./daily-data');

const args = process.argv.slice(2);

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

      let totalGross = $('#body').find('tr').last().prev('tr').find('tr').last().find('td').eq(1).text();

      console.log(`totalGross = ${totalGross}`);

      let jsonData = weeklyData.reduce(function(obj, curr, i) {
        let x = i % 12;
        let entry = Math.floor(i/12) + 1;
        switch(x) {
          case 0: obj[entry] = { rank: Number(curr) }; break;
          case 1: obj[entry]['prev_rank'] = Number(curr) || 0; break;
          case 2: obj[entry]['title'] = curr; break;
          case 3: obj[entry]['studio'] = curr; break;
          case 4: obj[entry]['week_gross'] = Number(curr.replace(/\D/g, '')); break;
          case 5: obj[entry]['pct_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 6: obj[entry]['theaters'] = Number(curr.replace(/\D/g, '')); break;
          case 7: obj[entry]['theater_change'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 8: obj[entry]['avg'] = Number(curr.replace(/\D/g, '')); break;
          case 9: obj[entry]['total'] = Number(curr.replace(/\D/g, '')); break;
          case 10: obj[entry]['budget'] = Number(curr.replace(/\$/g, '')) || 0; break;
          case 11: obj[entry]['week'] = Number(curr); break;
          default: break;
        }
        return obj;
      }, { totalGross });

      _writeToFile('weekly-data.json', weeklyDataFile, jsonData, arg.week, arg.year)

      // res.status(200).send(jsonData);
    });


  },
  getDailyData: function(arg) {
    console.log('in getDailyData...');
    // req.date = date;
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
                    .find('td').map(function(i, el) {
                      if (i < 110) return $(el).text();
                    }).get();

      let jsonData = dailyData.reduce((obj, curr, i) => {
        let x = i % 11;
        let entry = Math.floor(i/11) + 1;
        switch(x) {
          case 0: obj[entry] = { rank_today: Number(curr) }; break;
          case 1: obj[entry]['rank_yesterday'] = Number(curr) || 0; break;
          case 2: obj[entry]['title'] = curr; break;
          case 3: obj[entry]['studio'] = curr; break;
          case 4: obj[entry]['daily_gross'] = Number(curr.replace(/\D/g, '')); break;
          case 5: obj[entry]['pct_change_yd'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 6: obj[entry]['pct_change_lw'] = parseInt(curr.replace(/\,/g, ''), 10) || 0; break;
          case 7: obj[entry]['theaters'] = Number(curr.replace(/\D/g, '')); break;
          case 8: obj[entry]['avg'] = Number(curr.replace(/\D/g, '')); break;
          case 9: obj[entry]['total'] = Number(curr.replace(/\D/g, '')); break;
          case 10: obj[entry]['day'] = Number(curr); break;
          default: break;
        }
        return obj;
      }, { date: arg.date, week: arg.week  });
      _writeToFile('daily-data.json', dailyDataFile, jsonData, arg.date);
      // res.status(200).send(jsonData);
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

/********************************************************************************
** process.argv's first argument (args[0]) should be a string: 'week' or 'day' **
** process.argv's second argument (args[1]) should be the year or date         **
** process.argv's third argument (args[2]) should be the week                  **
********************************************************************************/
if (args[0] === 'week') {
  module.exports.getWeeklyData({ year: args[1], week: args[2] });
}
if (args[0] === 'day') {
  module.exports.getDailyData({ date: args[1], week: args[2] });
}
