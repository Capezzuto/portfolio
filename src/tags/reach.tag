<reach>
  <div class="background background-magenta"></div>

  <div class="reach-container">
    <h2>How to reach me</h2>
    <div>
      <div class="revealer phone"><div>phone:</div></div>
    </div>
    <div>
      <div class="revealer email"><div>e-mail:</div></div>
    </div>
    <div>
      <div class="revealer">
        <div>Github:</div>
      </div>
      <div class="been revealed">
        <div>
          <a href="https://github.com/Capezzuto" target="_blank">
            https://github.com/Capezzuto
          </a>
        </div>
      </div>
    </div>
    <div>
      <div class="revealer">
        <div>LinkedIn:</div>
      </div>
      <div class="been revealed">
        <div>
          <a href="https://www.linkedin.com/in/joseph-capezzuto" target="_blank">
            https://www.linkedin.com/in/joseph-capezzuto
          </a>
        </div>
      </div>
    </div>
    <div>
      <div class="revealer">
        <div>Instagram:</div>
      </div>
      <div class="been revealed">
        <div>
          <a href="https://www.instagram.com/josephcapezzuto/" target="_blank">
            https://www.instagram.com/josephcapezzuto/
          </a>
        </div>
      </div>
    </div>
  </div>

  <script>

    this.on('mount', () => {

      $('.revealer.phone').on('click', function() {
        $('<div class="revealed"><div>310.210.3041</div></div>')
          .insertAfter(this)
          .animate({
            padding: '0.2em 0.5em',
            width: '320px'
          }, 175, 'linear')
          .addClass('been');
          $('.revealer.phone').off();
      });

      $('.revealer.email').on('click', function() {
        $('<div class="revealed"><div><a href="mailto:joseph.capezzuto@gmail.com">joseph.capezzuto@gmail.com</a></div></div>')
          .insertAfter(this)
          .animate({
            padding: '0.2em 0.5em',
            width: '320px'
          }, 175, 'linear')
          .addClass('been');
           $('.revealer.email').off();
      });

    })

  </script>
</reach>
