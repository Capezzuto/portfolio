<web-work>
  <div class="background background-cyan"></div>
  <div class="jumbo-container">
    <div><h2>Web Development</h2></div>
    <site-card
      each={site in sites}
      image={site.image}
      title={site.title}
      url={site.url}
      summary={site.summary}></site-card>
  </div>

  <script>
    require('./site-card.tag');
    const $ = require('jquery');
    window.jQuery = $;
    window.$ = $;

    this.sites = [
      {
        image: '../assets/Shareat-full-screen-web.jpg',
        title: 'SharEat',
        url: 'http://www.shareat-us.com',
        summary: 'Air BnB for home-cooked meals'
      },
      {
        image: '../assets/Toiletz-full-screen-web.jpg',
        title: 'Toiletz',
        url: 'http://ec2-54-204-215-124.compute-1.amazonaws.com:3000/',
        summary: 'Toiletz is Yelp for public restrooms'
      },
      {
        image: '../assets/Pinwall-full-screen-web.jpg',
        title: 'PinWall',
        url: 'https://fathomless-ravine-28520.herokuapp.com',
        summary: 'A virtual bulletin board for intra-organizational communication'
      }
    ];

    // Underscore version of debounce
    function debounce(fn, wait = 20, immediate = true) {
      let timeout;
      return function() {
        const context = this;
        const args = arguments;
        const later = function() {
          timeout = null;
          if (!immediate) fn.apply(context, arguments)
        }
        let callNow = immediate && !timeout;
        clearTimeout(timeout)
        timeout = setTimeout(later, wait);
        if (callNow) fn.apply(context, arguments);
      }
    }

    this.on('mount', () => {
      riot.mount('site-card');

      function scrollOpacity() {
        let adjBottom = window.scrollY + window.innerHeight;
        $('.site-container').each(function(index) {
          let imageBottom = this.offsetTop + this.clientHeight;
          let fadePointBottom = adjBottom + this.clientHeight;
          let fadePointTop = adjBottom - this.clientHeight;
          let opacity = Math.max(0, 1 - Math.pow(Math.abs(imageBottom - adjBottom) / this.clientHeight, 2));
          if (imageBottom < fadePointBottom && imageBottom > fadePointTop) {
            $(this).css('opacity', opacity);
          }
        });
      }
      $(window).on('scroll', debounce(scrollOpacity, 13, false));
      scrollOpacity();
    });
  </script>
</web-work>
