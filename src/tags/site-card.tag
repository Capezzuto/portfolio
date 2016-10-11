<site-card>
  <div class="skew">
    <div class="deskew">
      <a href={opts.url}>
        <img class="site-image" src={opts.image} alt={opts.imagealt} />
      </a>
      <div class="site-info">
        <a href={opts.url}><h2>{opts.title}</h2></a>
        <p>{opts.summary}</p>
      </div>
    </div>
  </div>

  <script>
    this.on('mount', function() {
      console.log('site_card loaded..');
      // console.log(title);
    })
  </script>

</site-card>
