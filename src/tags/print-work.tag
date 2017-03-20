<print-work>
  </style>

  <div class="background background-magenta"></div>
  <div class="overlay"></div>
  <div class="page-header"><h2>Product Design and Advertising</h2></div>
  <div class="container">
    <div each={item, i in thumbs.products} class="print-entry loading">
      <img
        data-cat="products"
        data-link="{item.link}"
        data-title="{item.title}"
        data-year="{item.year}"
        src="{item.pic}"
        width="150px"
        height="150px"
        index="{i}">
    </div>
    <div><h2>Illustration</h2></div>
    <div each={item, i in thumbs.illustrations} class="print-entry loading">
      <img
        data-cat="illustrations"
        data-link="{item.link}"
        data-title="{item.title}"
        data-year="{item.year}"
        src="{item.pic}"
        width="150px"
        height="150px"
        index="{i}">
    </div>
  </div>
  <script>

    this.thumbs = require('../assets/print-thumbs.js');
    const thumbs = this.thumbs;

    function buildSelectedImage(index, cat) {
      let selection = thumbs[cat][index];
      return `
        <div id="selectedImage">
          <div class="selectWrapper">
            <img src="${selection.link}">
            <p class="caption">${selection.title}, ${selection.year}  </p>
          </div>
        </div>
      `;
    }

    function buildAdjacentImage(side = 'right', index, cat) {
      if (side === 'right') index += 1;
      if (side === 'left') index -= 1;
      let selection = thumbs[cat][index];
      return `
        <div id="next-${side}-image">
          <img src="${selection.link}"
        </div>
      `
    }

    function getNewImage(index, category) {
      let selectedImage = buildSelectedImage(index, category);
      $('.overlay').html('').append(selectedImage);
      $('#selectedImage').animate({'opacity': 1}, 300);
      addArrows(selectedImage, index, category);
      if (thumbs[category][index + 1]) $('.overlay').append(buildAdjacentImage('right', index, category));
      if (thumbs[category][index - 1]) $('.overlay').append(buildAdjacentImage('left', index, category));
    }

    function addArrows(template, index, category) {
      $('#selectedImage').prepend('<div class="left-arrow"></div>');
      $('#selectedImage').append('<div class="right-arrow"></div>');
      if (+index === 0) {
        $('.left-arrow').css("visibility", "hidden");
      }
      if (+index + 1 === thumbs[category].length) {
        $('.right-arrow').css("visibility", "hidden");

      }
      $('#selectedImage').on('click', 'img', function(e) {
        e.stopPropagation();
      })
      $('#selectedImage').on('click', '.right-arrow', function(e) {
        e.stopPropagation();
        $('.selectWrapper').css({ 'transform': 'translateX(-100px)', 'opacity': 0, 'transition': 'transform 300ms, opacity 150ms'});
        setTimeout(() => {
          getNewImage(+index + 1, category)
        }, 300);
      });
      $('#selectedImage').on('click', '.left-arrow', function(e) {
        e.stopPropagation();
        $('.selectWrapper').css({ 'transform': 'translateX(100px)', 'opacity': 0, 'transition': 'transform 300ms, opacity 150ms'});
        setTimeout(() => {
          getNewImage(index - 1, category)
        }, 300);
      })
    }

    $('body').on('click', '.print-entry', (event) => {
      let index = $(event.target).attr('index');
      let cat = $(event.target).attr('data-cat');
      $('.overlay').show();
      getNewImage(+index, cat);
    });

    $('body').on('click', '.overlay', function(){
      $('.overlay').html('').hide();
    })

    this.on('mount', () => {

      
      let entries = document.querySelectorAll('.loading');
      let entriesArray = Array.prototype.slice.call(entries, 0);
      console.log('entries', entries);
      console.log('array', entriesArray);
      entriesArray
      .forEach(function(entry) {
        console.log('for each...')
        entry.addEventListener('animationend', function() {
          console.log('animation ending...')
          this.classList.remove('loading');
        })
      })

    })

  </script>
</print-work>
