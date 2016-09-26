
const riot = require('riot');
const riotNav = require('./tags/riot-nav.tag');
require('./tags/home.tag');
require('./tags/web-work.tag');
require('./tags/print-work.tag');
require('./tags/data-menu.tag');
require('./tags/bio.tag');
require('./tags/reach.tag');
require('./tags/page-not-found.tag');

// import riot-nav from './riot-nav.tag';


//This would be the place to initialize a redux store if I were so inclined in the future


let currentTag = null;
const routes = {
  'home': function(id) {
    mount('home');
  },
  'web': function(id) {
    mount('web-work');
  },
  'print': function(id) {
    mount('print-work');
  },
  'data': function(id) {
    //id should be title of data-vis
    if (id) {
      //fetch data from id page, << axios.get().then() >>
      //if valid data, then...
      mount(`data-${id}`)
    } else {
      mount('data-menu')
    }
  },
  'bio': function() {
    mount('bio');
  },
  'reach': function() {
    mount('reach');
  }
}

function mount(tag, options) {
  currentTag && currentTag.unmount(true); //if there is a currentTag, unmount it to start
  currentTag = riot.mount('#content', tag, options)[0];
}

function routeHandler(routeSelected, id) {
  let route = routes[routeSelected || 'home'];
  route ? route(id) : mount('page-not-found');
}

riot.route.stop();
riot.route.start(true);

riot.route(routeHandler);

riot.mount('riot-nav');
