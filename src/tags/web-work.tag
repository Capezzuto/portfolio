<web-work>
  <h2>Web sites</h2>
  <div>
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
        image: '../assets/SharEat-640px.png',
        imagealt: 'SharEat screen-grab',
        title: 'SharEat',
        url: 'http://www.shareat-us.com',
        summary: 'Air BnB for home-cooked meals'
      },
      {
        image: '../assets/Toiletz-640px.png',
        imagealt: 'Toiletz screen-grab',
        title: 'Toiletz',
        url: 'http://www.shareat-us.com',
        summary: 'Toiletz is Yelp for public restrooms'
      },
    ];
    this.on('mount', () => {
      riot.mount('site-card');
    });
  </script>
</web-work>
