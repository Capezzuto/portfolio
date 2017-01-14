<bio>
  <div class="background background-cyan"></div>

  <div class="page-header"><h2>Bio</h2></div>

  <div class="container" id="bio-container">
    <div class="section">
      <h3>About Me</h3>
      <div class="subsection">
       <div class="profile-pic">
         <img src="/assets/square-profile-web-384.jpg" height="192px" width="192px">
       </div>
       <div id="bio">
         <div class="block" >
           <div class="deskew">
             <p>
               I have a background in art and design, but also love math and logic.  In 2012, after finishing a M.A. in art history at California State University, Long Beach, I worked as a freelance designer for a few clients, creating designs for print, ranging from business cards to tee-shirts.  This led to maintaining the a client’s web site, which led to new challenges and more opportunities to learn. I have continued to learn and grow since then through a combination of formal education and learning through projects.
             </p>
           </div>
             <br>
           <div class="deskew">
             <p>
               I like to find new solutions to old problems. I am always looking for a better user experience, improvements in performance and efficiency, and new and creative ways to present information. My current interests include data visualizations, build tools for web development, front-end Javascript frameworks, and motion graphics.
             </p>
           </div>
         </div>
       </div>
      </div>

    </div>

    <div class="section">
      <div class="subsection">
        <h3>Projects</h3>
        <div each={project in projects} class="block project">
          <div class="deskew">
            <h4 class="title">{project.title}</h4>
            <a href="{project.url}">{project.url}</a>
            <p>{project.role}</p>
            <p>{project.description}</p>
          </div>
          <div class="deskew">
            <ul>
              <li each={task in project.work}>{task}</li>
            </ul>
          </div>
        </div>
      </div>

      <div class="subsection">
        <h3>Technical Skills</h3>
        <skills></skills>
      </div>

      <div class="subsection">
        <h3>Work Experience</h3>
        <div each={job in jobs} class="block work">
          <div class="deskew">
            <h4>{job.company}</h4>
            <p>{job.dates}</p>
            <p>{job.role}</p>
          </div>
          <div class="deskew">
            <ul>
              <li each={task in job.tasks}>{task}</li>
            </ul>
          </div>
        </div>
      </div>

      <div class="subsection">
        <h3>Education</h3>
        <education></education>
      </div>

    </div>
  </div>

  <script type="text/javascript">
    require('./skills-table.tag');
    require('./education-table.tag');

    this.projects = [
      {
        title: 'SharEat',
        role: 'Full-stack Engineer',
        description: 'An app enabling a community of users to host meals and find and attend other meals',
        url: 'http://www.shareat-us.com',
        work: [
          'Enhanced clarity of UX in map view with CSS styling and logical structuring of React components.',
          'Empowered users to find better meals with search menu that filters by location, search radius, type of food, and diet.',
          'Streamlined search for logged-in users by pre-populating search fields with user’s preferences.',
          'Created efficient client/server solutions through schema design and HTTP request responses that gather targeted data considering client-side data requirements with Sequelize and MySQL .'
        ]
      },
      {
        title: 'Toiletz',
        role: 'Full-stack Engineer',
        description: 'An app that lets users add a public restroom to the database so that others can quickly find the nearest toilet.',
        url: 'http://ec2-54-204-215-124.compute-1.amazonaws.com:3000/',
        work: [
          'Improved user search experience by creating map popovers with street views and addresses.',
          'Provided relevant results by implementing search for available restrooms within a 1-mile radius.',
          'Increased script efficiency by 18% by refactoring all site interactions with the Google Maps API.'
        ]
      },
      {
        title: 'PinWall',
        role: 'Front-end Developer',
        description: 'A site that enables members of an organization to post notes to a virtual bulletin board.',
        url: '​https://fathomless-ravine-28520.herokuapp.com/',
        work: [
          'Provided a foundation for front-end team by architecting client side with Redux and React Router.',
          'Ensured useful navigation options at each stage of UX with navbar variants based on user-login status.',
          'Improved quality of user data and ensured properly formatted posts using form validation.'
        ]
      }
    ];
    this.jobs = [
      {
        company: 'Deaf Man\'s BBQ',
        role: 'Freelance Print and Web Designer',
        dates: '2014-2016',
        tasks: [
          'Designed labels for new product lines; redesigned existing labels to meet FDA standards.',
          'Maintained and updated web site design for promotional campaigns.',
          'Created marketing materials for new ad campaigns and product launches.'
        ]
      },
      {
        company: 'Miriam Reed Productions',
        role: 'Historical Consultant',
        dates: '2011-2013',
        tasks: [
          'Translated source materials and correspondence into Japanese and English.',
          'Researched and advised on cultural notes, spelling, and Japanese-English transliteration.'
        ]
      },
      {
        company: 'California State University, Long Beach',
        role: 'Teaching Associate, ART110 - Introduction to Visual Arts',
        dates: '2010-2012',
        tasks: [
          'Communicated art-historical and formal design topics spanning the world and 2000 years​.',
          'Updated online course component with lecture notes, assignments, and useful resources.'
        ]
      }
    ];

    this.on('mount', () => {
      riot.mount('skills');
      riot.mount('education');
    })
  </script>
</bio>
