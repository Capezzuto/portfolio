<home>
  <animation></animation>
  <script>
    require('./animation.tag');
    this.on('mount', function() {
      riot.mount('animation');
      console.log('home loaded...');
    })
  </script>
</home>
