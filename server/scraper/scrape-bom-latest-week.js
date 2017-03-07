const cheerio = require('cheerio');
const phantom = require('phantom');

module.exports = function getLatestWeek() {
  let _ph, _page;
  let _latestWeek = { week: null, year: null };
  const bomURL = 'http://www.boxofficemojo.com/weekly/';

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
    .then((html) => parseLatestWeek(html))
    .then((latestWeek) => {
      _latestWeek = latestWeek;
      return _page.close()
    })
    .then(() => _ph.exit())
    .then(() => _latestWeek)
    .catch((err) => {
      console.log(err);
      return _page.close()
        .then(() => _ph.exit())
        .then(() => _latestWeek);
    });
};

function parseLatestWeek(html) {
  const $ = cheerio.load(html);

  let trs = $('#body')
            .find('tr')
            .filter((i, el) => $(el).attr('bgcolor') === '#ffff99')
            .find('a')
            .first()
            .attr('href');
  // console.log('year:  ', trs.slice(18, 22));
  // console.log('week:  ', trs.slice(26, 28));
  return { year: trs.slice(18,22), week: trs.slice(26,28) };
}
