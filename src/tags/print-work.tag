<print-work>
  <div class="background-magenta"></div>
  <div class="container">
    <div><h2>Product Design and Advertising</h2></div>
    <div each={thumb in thumbs.products} class="print-entry">
      <a href="{thumb.link}"><img src="{thumb.pic}" width="150px" height="150px"></a>
    </div>
    <div><h2>Illustration</h2></div>
    <div each={thumb in thumbs.illustrations} class="print-entry">
      <img src="{thumb.pic}">
    </div>
  </div>
  <script>
    //eventually, get .json in this.on('mount', getDataFunction)
    this.thumbs = {
      products: [
        {
          pic: '../assets/thumbs/Products/GoldenStateTeeThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/July11FlyerThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-BBQ-Thumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Product-Line-FDA-TM-Thumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HickorySmokedThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-HoneyRoastedThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/DMBBQ-Trail-Mix-SantaFeThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/BizCardsThumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/Hang-Tag--InsideOutsideThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/Business_Card_Front2_Back4Thumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Products/Cafe_Display_V1_CWebThumb.jpg',
          link: '#'
        },

      ],
      illustrations: [
        {
          pic: '../assets/thumbs/Illustration/PsycheCthuluWebThumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_1_RedWebThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_2_BlueWebThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Tri-Color_3_YellowWebThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Blue_SpiralWebThumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Yellow_Vertical-ZonesWebThumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Orange_B&WWebThumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Network_Green_Vertical-StudyThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Structure07WebThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/TronometryThumb.jpg',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation01Thumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation02Thumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation03Thumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/Reclamation04Thumb.png',
          link: '#'
        },
        {
          pic: '../assets/thumbs/Illustration/2-3-74Thumb.jpg',
          link: '#'
        },

      ]
    }
  </script>
</print-work>
