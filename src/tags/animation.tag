<animation>
  <div class="animation-container"></div>
  <script type="text/javascript">

      function getRandomAttr() {
        const magenta = '#EC008C', cyan = '#00AEEF', yellow = '#FFF200';
        return {
          position: Math.floor(Math.random() * (window.innerWidth - 120) + 60),
          side: Math.ceil(Math.random() * 160) + 20,
          color: () => {
            let random = Math.floor(Math.random() * 3);
            if (random <= 0) return magenta;
            if (random === 1) return cyan;
            if (random >= 2) return yellow;
          },
          ascduration: Math.floor(Math.random() * 6000) + 2000,
          turnduration: Math.floor(Math.random() * 4000) + 1000
        };
      }

      function createShard(attr) {
        let $shard = $('<div class="shard"></div>');
        return $shard.css({
          "bottom": "-" + (attr.side * 2) + "px",
          "left":  attr.position + "px",
          "height": attr.side + "px",
          "width": attr.side + "px",
          "background-color": attr.color(),
          "animation": "turn " + attr.turnduration + "ms linear infinite"
        });
      }

      function appendAndAnimateShard(attr) {
        createShard(attr)
          .appendTo('.animation-container')
          .animate({ "bottom": (window.innerHeight + (attr.side * 2)) + "px" },
            attr.ascduration,
            'linear',
            function () {
              this.remove();
              appendAndAnimateShard(getRandomAttr());
            }
          );
      }

      this.on('mount', () => {
        // var i = 0;
        // var max = Math.ceil(window.innerWidth / 100);
        // var timer = setInterval(function() {
        //   createShard(getRandomAttr());
        //   i++;
        //   if (i === max) {
        //     console.log('clearing timer');
        //     clearInterval(timer);
        //   }
        // }, 400);
        console.log('animation mounted...');
        for (let i = 0; i < Math.ceil(window.innerWidth /100); i++ ) {
          appendAndAnimateShard(getRandomAttr());
        }
      });
    </script>
</animation>