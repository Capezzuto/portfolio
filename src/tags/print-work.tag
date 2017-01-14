<print-work>
  <div class="background background-magenta"></div>
  <div class="overlay"></div>
  <div class="page-header"><h2>Product Design and Advertising</h2></div>
  <div class="container">
    <div each={item, i in thumbs.products} class="print-entry">
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
    <div each={item, i in thumbs.illustrations} class="print-entry">
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
    //eventually, get .json in this.on('mount', getDataFunction)
    let thumbs = {
      products: [
        {
          pic: '../assets/thumbs/Products/GoldenStateTeeThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/GoldenStateTee.png',
          year: 2015,
          title: 'Golden State Tee-Shirt'
        },
        {
          pic: '../assets/thumbs/Products/July11FlyerThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/July11FlyerWeb.jpg',
          year: 2015,
          title: 'Flyer for new product launch'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-BBQ-Thumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Product-Line-FDA-BBQ.jpg',
          year: 2015,
          title: 'Product sheet side 1'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-TM-Thumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Product-Line-FDA-TM.jpg',
          year: 2015,
          title: 'Product sheet side 2'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HickorySmokedThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-HickorySmoked.jpg',
          year: 2015,
          title: 'Hickory Smoked Trail Mix label'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HoneyRoastedThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-HoneyRoasted.jpg',
          year: 2015,
          title: 'Honey Roasted Trail Mix label'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-SantaFeThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-SantaFe.jpg',
          year: 2015,
          title: 'Santa Fe Trail Mix label'
        },
        {
          pic: '../assets/thumbs/Products/BizCardsThumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/BizCards.png',
          year: 2014,
          title: 'Deaf Man\'s BBQ business card design'
        },
        {
          pic: '../assets/thumbs/Products/Hang-Tag--InsideOutsideThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Hang-Tag--InsideOutside.jpg',
          year: 2014,
          title: 'Hang tag for BBQ sauce'
        },
        {
          pic: '../assets/thumbs/Products/Business_Card_Front2_Back4Thumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Business_Card_Front2_Back4.jpg',
          year: 2014,
          title: 'Mami Jolly business card design'
        },
        {
          pic: '../assets/thumbs/Products/Cafe_Display_V1_CWebThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Cafe_Display_V1_CWeb.jpg',
          year: 2014,
          title: 'Cafe display for Mami Jolly'
        },

      ],
      illustrations: [
        {
          pic: '../assets/thumbs/Illustration/PsycheCthuluWebThumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/PsycheCthuluWeb.png',
          year: 2015,
          title: 'Cthulhu Variations #1 (Psychedelic Poster)'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_1_RedWebThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_1_RedWeb.jpg',
          year: 2009,
          title: 'Tri-Color (Red)'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_2_BlueWebThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_2_BlueWeb.jpg',
          year: 2009,
          title: 'Tri-Color (Blue)'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_3_YellowWebThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_3_YellowWeb.jpg',
          year: 2009,
          title: 'Tri-Color (Yellow)'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Blue_SpiralWebThumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Blue_SpiralWeb.jpg',
          year: 2009,
          title: 'Network (Blue Spiral)'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Yellow_Vertical-ZonesWebThumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Yellow_Vertical-ZonesWeb.jpg',
          year: 2009,
          title: 'Network (Yellow Zones)'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Orange_B&WWebThumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Orange_B&WWeb.jpg',
          year: 2008,
          title: 'Network (Orange B&W)'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Green_Vertical-StudyThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Green_Vertical-Study.jpg',
          year: 2008,
          title: 'Network (green study)'
        },
        {
          pic: '../assets/thumbs/Illustration/Structure07WebThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Structure07Web.jpg',
          year: 2008,
          title: 'Network #07'
        },
        {
          pic: '../assets/thumbs/Illustration/TronometryThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tronometry.jpg',
          year: 2008,
          title: 'Tronometry'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation01Thumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation01.png',
          year: 2007,
          title: 'Reclamation'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation02Thumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation02.png',
          year: 2007,
          title: 'Reclamation'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation03Thumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation03.png',
          year: 2007,
          title: 'Reclamation'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation04Thumb.png',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation04.png',
          year: 2007,
          title: 'Reclamation'
        },
        {
          pic: '../assets/thumbs/Illustration/2-3-74Thumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/2-3-74.jpg',
          year: 2004,
          title: '2-3-74'
        },

      ]
    };

    this.thumbs = thumbs;

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

  </script>
</print-work>
