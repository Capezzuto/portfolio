<web-work>
  <div class="background-cyan"></div>
  <div class="container">
    <site-card
      each={site in sites}
      image={site.image}
      title={site.title}
      url={site.url}
      summary={site.summary}></site-card>
  </div>

  <script>
    require('./site-card.tag');
    this.sites = [
      {
        image: '../assets/SharEat-640px.png',
        title: 'SharEat',
        url: 'http://www.shareat-us.com',
        summary: 'Air BnB for home-cooked meals'
      },
      {
        image: '../assets/Toiletz-640px.png',
        title: 'Toiletz',
        url: 'http://ec2-54-204-215-124.compute-1.amazonaws.com:3000/',
        summary: 'Toiletz is Yelp for public restrooms'
      },
      {
        image: '../assets/PinWall-640px.png',
        title: 'PinWall',
        url: '​https://fathomless-ravine-28520.herokuapp.com/',
        summary: 'A virtual bulletin board for intra-organizational communication'
      },

    ];
    this.on('mount', () => {
      riot.mount('site-card');
    });
  </script>
</web-work>
