<site-card>

  <div class="site-container loading" style="background-image: url('{opts.image}')">
    <a href="{opts.url}" target="_blank">
      <div class="site-entry">
        <h1>{opts.title}</h1>
        <p>{opts.summary}</p>
        <p class='tech'>Technologies: {opts.tech}</p>
      </div>
    </a>
  </div>

  <script>
    this.on('mount', () => {
      const site = document.querySelector('.loading');
      site.addEventListener('animationend', function() {
        console.log('this', this);
        site.classList.remove('loading');
      })
    })
  </script>

</site-card>
