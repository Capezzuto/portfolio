<home>
  <h2>HOME</h2>
  <animation></animation>  
  <script>
    require('./animation.tag');
    this.on('mount', function() {
      riot.mount('animation');
      console.log('home loaded...');
    })
  </script>
</home>
