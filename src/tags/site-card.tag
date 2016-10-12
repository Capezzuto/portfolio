<site-card>

  <div class="site-container" style="background-image: url('{opts.image}')">
    <div class="site-entry">
      <h1>{opts.title}</h1>
      <p>{opts.summary}</p>
      <a href="{opts.url}">{opts.url}</a>
    </div>
  </div>

  <script>
    this.on('mount', function() {
      console.log('site_card loaded..');
    })
  </script>

</site-card>
