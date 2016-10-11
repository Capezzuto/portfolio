<web-work>
  <div class="container">
    <site-card
      each={site in sites}
      image={site.image}
      imagealt={site.imagealt}
      title={site.title}
      url={site.url}
      summary={site.summary}></site-card>
  </div>

  <script>
    require('./site-card.tag');
    this.sites = [
      {
        image: '../assets/SharEat-c-640px.png',
        imagealt: 'SharEat screen-grab',
        title: 'SharEat',
        url: 'http://www.shareat-us.com',
        summary: 'Air BnB for home-cooked meals'
      },
      {
        image: '../assets/Toiletz-c-640px.png',
        imagealt: 'Toiletz screen-grab',
        title: 'Toiletz',
        url: 'http://ec2-54-204-215-124.compute-1.amazonaws.com:3000/',
        summary: 'Toiletz is Yelp for public restrooms'
      },
      {
        image: '../assets/PinWall-c-640px.png',
        imagealt: 'PinWall screen-grab',
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
