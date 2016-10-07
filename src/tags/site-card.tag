<site-card>
  <div class="skew">
    <div class="deskew">
      <img class="site-image" src={opts.image} alt={opts.imagealt} />
      <div class="site-info">
        <h2>{opts.title}</h2>
        <h6><a href={opts.url}>{opts.url}</a></h6>
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
