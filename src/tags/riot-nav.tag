<riot-nav>
  <a class="menu-item" id="hamburger-box"><div class="hamburger"></div></a>
<div class="menu-container">
  <ul>
    <li class="menu-spacer nav-yellow"> </li>
    <li class="menu-spacer nav-cyan"> </li>
    <li class="menu-spacer nav-magenta"><p></p></li>
    <a href="#"><li class="nav-yellow menu-item"><p>Home</p></li></a>
    <a href="#/web"><li class="nav-cyan menu-item"><p>Web</p></li></a>
    <a href="#/print"><li class="nav-magenta menu-item"><p>Print</p></li></a>
    <a href="#/data"><li class="nav-yellow menu-item"><p>Data</p></li></a>
    <a href="#/bio"><li class="nav-cyan menu-item"><p>Bio</p></li></a>
    <a href="#/reach"><li class="nav-magenta menu-item"><p>Reach</p></li></a>
    <li class="menu-spacer nav-yellow"></li>
  </ul>
</div>

  <script>
    const $ = require('jquery');
    window.jQuery = $;
    window.$ = $;

    this.on('mount', () => {

      $('#hamburger-box').on('click', (e) => {
        let currentNavHeight = $('.menu-container').height();

        if (currentNavHeight < 5) {
          let newNavHeight = $('riot-nav ul').height() + 15;
          $('riot-nav').animate({
            'right': '185px'
          },750).children('.menu-container').animate({
            'height': `${newNavHeight}px`
          }, 750);
        } else {
          $('riot-nav').animate({
            'right': '50px'
          },750).children('.menu-container').animate({
            'height': '0px'
          }, 750, () => {$(this).removeAttr('style')});
        }
      });

      $(window).resize(function() {
        if ($(this).width() > 768) {
          $('riot-nav').removeAttr('style').children('.menu-container').removeAttr('style');
        }
      })
    })
  </script>
</riot-nav>
