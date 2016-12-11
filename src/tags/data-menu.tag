<data-menu>
  <div class="background background-yellow"></div>

  <div class="container">
    <h2>Coming soon: data visualizations</h2>
  </div>

  <script>
  this.on('mount', function() {
    console.log('data-menu loaded..');
    const d3 = require('d3');
    const axios = require('axios');
    const svg = d3.select('.container').append('svg').attr('height', '75vh').attr('width', '100%');
    // axios.get()


  })
  </script>
</data-menu>
