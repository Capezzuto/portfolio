const mongoose = require('mongoose');
mongoose.Promise = require('bluebird');

const getDailyData = require('./scrape-bom-daily.js');
const getWeeklyData = require('./scrape-bom-weekly.js');

const args = process.argv.slice(2);

/***************************************************************************************
** process.argv's first argument (args[0]) should be a string: 'week' or 'day'        **
** process.argv's second argument (args[1]) should be the year                        **
** process.argv's third argument (args[2]) should be the week                         **
** process.argv's fourth argument (optional, args[3]) should be the date (yyyy-mm-dd) **
***************************************************************************************/

mongoose.connect(config.db)
  .then(function() {
    if (args[0] === 'week') {
      return getWeeklyData({ year: args[1], week: args[2] });
    }
    if (args[0] === 'day') {
      return getDailyData({ year: args[1], week: args[2], date: args[3] });
    }
  })
  .then(function() {
    mongoose.connection.close();
  })
  .catch(function(err) {
    console.log(err);
    mongoose.connection.close();
  })
