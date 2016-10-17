<print-work>
  <div class="background background-magenta"></div>
  <div class="container">
    <div><h2>Product Design and Advertising</h2></div>
    <div each={item in thumbs.products} class="print-entry">
      <img
        data-link="{item.link}"
        data-title="{item.title}"
        data-year="{item.year}"
        src="{item.pic}"
        width="150px"
        height="150px">
    </div>
    <div><h2>Illustration</h2></div>
    <div each={item in thumbs.illustrations} class="print-entry">
      <img
        data-link="{item.link}"
        data-title="{item.title}"
        data-year="{item.year}"
        src="{item.pic}"
        width="150px"
        height="150px">
    </div>
  </div>
  <script>
    //eventually, get .json in this.on('mount', getDataFunction)
    this.thumbs = {
      products: [
        {
          pic: '../assets/thumbs/Products/GoldenStateTeeThumb.jpg',
          link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/GoldenStateTee.png',
          year: '2015',
          title: 'Golden State Tee-Shirt'
        },
        // {
        //   pic: '../assets/thumbs/Products/July11FlyerThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/July11FlyerWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-BBQ-Thumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Product-Line-FDA-BBQ.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-TM-Thumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Product-Line-FDA-TM.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HickorySmokedThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-HickorySmoked.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HoneyRoastedThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-HoneyRoasted.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-SantaFeThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/DMBBQ-Trail-Mix-SantaFe.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/BizCardsThumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/BizCards.png'
        // },
        // {
        //   pic: '../assets/thumbs/Products/Hang-Tag--InsideOutsideThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Hang-Tag--InsideOutside.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/Business_Card_Front2_Back4Thumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Business_Card_Front2_Back4.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Products/Cafe_Display_V1_CWebThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Products/Cafe_Display_V1_CWeb.jpg'
        // },

      ],
      illustrations: [
        // {
        //   pic: '../assets/thumbs/Illustration/PsycheCthuluWebThumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/PsycheCthuluWeb.png'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Tri-Color_1_RedWebThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_1_RedWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Tri-Color_2_BlueWebThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_2_BlueWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Tri-Color_3_YellowWebThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tri-Color_3_YellowWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Network_Blue_SpiralWebThumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Blue_SpiralWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Network_Yellow_Vertical-ZonesWebThumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Yellow_Vertical-ZonesWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Network_Orange_B&WWebThumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Orange_B&WWeb.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Network_Green_Vertical-StudyThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Network_Green_Vertical-Study.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Structure07WebThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Structure07Web.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/TronometryThumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Tronometry.jpg'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Reclamation01Thumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation01.png'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Reclamation02Thumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation02.png'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Reclamation03Thumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation03.png'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/Reclamation04Thumb.png',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/Reclamation04.png'
        // },
        // {
        //   pic: '../assets/thumbs/Illustration/2-3-74Thumb.jpg',
        //   link: 'https://s3-us-west-1.amazonaws.com/joseph.capezzuto.portfolio-items/Illustration/2-3-74.jpg'
        // },

      ]
    };

    $('body').on('click', '.print-entry', (event) => {
      let $link = $(event.target).attr('data-link');
      let $year = $(event.target).attr('data-year');
      let $title = $(event.target).attr('data-title');
      console.log('$link', $link, '$year', $year, '$title', $title);
      let selectedImage = `
        <div class="selectedImage">
          <div>
            <img src="${$link}">
            <p class="caption">${$title}, ${$year}  </p>
          </div>
        </div>
      `;

      $('.overlay').append(selectedImage).show();
    });

    $('.overlay').on('click', function(){
      $('.overlay').html('').hide();
    })

  </script>
</print-work>
