//'client' should be a redis client
const WeeklyBoxOffice = require('../boxOffice/boxOfficeWeeklyModel.js');
const weekCount = require('../scraper/week.json');

module.exports = {
  //populateMenu must return a promise
  populateMenu: function(client) {
    return WeeklyBoxOffice
      .find()
      .select('week date_range')
      .limit(52)
      .exec((err, weeks) => {
        if (err) {
          console.log('error getting menu information...', err);
        } else {
          console.log('got weeks');
          weeks.forEach((week) => {
            client.hsetnx('menu', week.week, week.date_range);
          })
        }
      })

  },
  getLatestWeeklyBoxOffice: function(client) {
    let week = weekCount.week - 1 < 10 ? '0' + (weekCount.week - 1) : String(weekCount.week - 1);
    let weekAndYear = `${weekCount.year}_${week}`;
    client.hgetallAsync('menu').then(weeks => console.log('weeks', weeks));

    return WeeklyBoxOffice
      .find({week: weekAndYear})
      .select('-movies.studio -movies.budget -movies.week -movies.prev_rank')
      .populate({
        path: 'days',
        select: 'date top10.title top10.daily_gross top10.theaters top10.avg',
        options: { sort: { date: 1 } }
      })
      .lean()
      .exec((err, data) => {
        if (err) {
          console.log('error in setting latest box office....');
        } else {
          client.set('latest', JSON.stringify(data[0]));
        }

      })
  }
}
