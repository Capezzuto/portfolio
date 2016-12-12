<data-menu>
  <div class="background background-yellow"></div>
  <style>


  </style>
  <div class="container">
    <h2>Coming soon: data visualizations</h2>
  </div>

  <script>
  this.on('mount', function() {
    console.log('data-menu loaded..');
    const d3 = require('d3');
    const axios = require('axios');

    const parseTime = d3.timeParse('%Y-%m-%d');
    const getDay = d3.timeFormat('%a');

    const svg = d3.select('.container').append('svg').attr('height', '75vh').attr('width', '100%');

    const height = 400;
    const width = 700;
    const margin = { left: 80, right: 20, top: 20, bottom: 0 };
    const cat20 = d3.schemeCategory20;

    let selectedWeek = '2016_45'; //eventually will be selected by user
    axios.get(`/data/boxoffice/weekly/${selectedWeek}`)
      .then((response) => {
        const data = response.data;
        const movieKeys = ['movie1','movie2','movie3','movie4','movie5'];
        let top5 = [];
        for (let i = 1; i < 6; i++) {
          top5.push(data.weekTotals[i].title);
        }
        const stack = d3.stack().keys(movieKeys);


        const top5Data = data.days.map((day) => {
          return {
            date: parseTime(day.date),
            movie1: day.top10.find((movie) => movie.title === top5[0]).daily_gross || 0,
            movie2: day.top10.find((movie) => movie.title === top5[1]).daily_gross || 0,
            movie3: day.top10.find((movie) => movie.title === top5[2]).daily_gross || 0,
            movie4: day.top10.find((movie) => movie.title === top5[3]).daily_gross || 0,
            movie5: day.top10.find((movie) => movie.title === top5[4]).daily_gross || 0,
          };
        });

        let x = d3.scaleTime()
                    .domain(d3.extent(top5Data, (d) => d.date))
                    .range([0, width]);

        let y = d3.scaleLinear()
                    .domain([0, d3.max(top5Data, (d) => {
                      return d.movie1 + d.movie2 + d.movie3 + d.movie4 + d.movie5;
                    })])
                    .range([height, 0]);

        const stacked = stack(top5Data);
        console.log(stacked);

        let area = d3.area()
                        .x((d) => x(d.data.date))
                        .y0((d) => y(d[0]))
                        .y1((d) => y(d[1]));

        let chartGroup = svg.append('g').attr('transform', `translate(${margin.left}, ${margin.top})`);

        chartGroup.append('g')
                  .attr('class', 'axis')
                  .attr('transform', `translate(0, ${height})`)
                  .call(d3.axisBottom(x));
        chartGroup.append('g')
                  .attr('class', 'axis')
                  .call(d3.axisLeft(y));

        chartGroup.selectAll('g.area')
                    .data(stacked)
                    .enter().append('g')
                      .attr('class', 'area')
                    .append('path')
                      .attr('class','area')
                      .attr('fill', (d, i) => cat20[i])
                      .attr('opacity', 0.5)
                      .attr('d', (d) => area(d));

      })
      .catch((err) => {
        console.log(err);
      })

  })
  </script>
</data-menu>
