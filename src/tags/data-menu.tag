<data-menu>
  <div class="background background-yellow"></div>
  <style>
    .area:hover {
      opacity: 1;
    }
    .legend-entry:hover {
      opacity: 1;
    }

  </style>
  <div class="container">
    <h2>Top 5 Movies at the Box Office, week of November 4 - 10</h2>
  </div>

  <div>
    <p>Ongoing project to build data visualizations with d3.js</p>
  </div>

  <script>
  this.on('mount', function() {

    const d3 = require('d3');
    const axios = require('axios');

    const parseTime = d3.timeParse('%Y-%m-%d');
    const getDay = d3.timeFormat('%a');

    const svg = d3.select('.container').append('svg').attr('height', '75vh').attr('width', '100%');

    const height = 400;
    const width = 700;
    const margin = { left: 80, right: 20, top: 20, bottom: 0 };
    // const colorScheme = [
    //   'rgb(0, 154, 212)',
    //   'rgb(236, 0, 140)',
    //   'rgb(240, 230, 0)',
    //   'rgb(70, 205, 255)',
    //   'rgb(250, 70, 170)',
    //   'rgb(0, 174, 239)',
    //   'rgb(255, 242, 0)'
    // ];
    const colorScheme1 = [
      'rgb(0, 154, 212)',
      'rgb(236, 0, 140)',
      'rgb(240, 230, 0)',
      'rgb(170, 205, 255)',
      'rgb(250, 170, 170)',
      'rgb(60, 174, 239)',
      'rgb(255, 242, 0)'
    ];

    let selectedWeek = '2016_45'; //eventually will be selected by user
    axios.get(`/data/boxoffice/weekly/${selectedWeek}`)
      .then((response) => {
        const data = response.data;
        const movieKeys = ['movie1','movie2','movie3','movie4','movie5'];
        let top5 = [];
        for (let i = 1; i < 6; i++) {
          top5.push(data.weekTotals[i].title);
        }
        const stack = d3.stack().keys(top5);


        const top5Data = data.days.map((day) => {
          return {
            date: parseTime(day.date),
            [top5[0]]: day.top10.find((movie) => movie.title === top5[0]).daily_gross || 0,
            [top5[1]]: day.top10.find((movie) => movie.title === top5[1]).daily_gross || 0,
            [top5[2]]: day.top10.find((movie) => movie.title === top5[2]).daily_gross || 0,
            [top5[3]]: day.top10.find((movie) => movie.title === top5[3]).daily_gross || 0,
            [top5[4]]: day.top10.find((movie) => movie.title === top5[4]).daily_gross || 0,
          };
        });

        const x = d3.scaleTime()
                    .domain(d3.extent(top5Data, (d) => d.date))
                    .range([0, width]);

        const y = d3.scaleLinear()
                    .domain([0, d3.max(top5Data, (d) => {
                      return d[top5[0]] + d[top5[1]] + d[top5[2]] + d[top5[3]] + d[top5[4]];
                    })])
                    .range([height, 0]);

        const stacked = stack(top5Data);
        console.log(stacked);

        let area = d3.area()
                        .x((d) => x(d.data.date))
                        .y0((d) => y(d[0]))
                        .y1((d) => y(d[1]));

        let chartGroup = svg.append('g').attr('transform', `translate(${margin.left}, ${margin.top})`);
        let legend = svg.append('g').attr('transform', 'translate(735, 0)');

        chartGroup.append('g')
                  .attr('class', 'axis')
                  .attr('transform', `translate(0, ${height})`)
                  .call(d3.axisBottom(x).ticks(7));
        chartGroup.append('g')
                  .attr('class', 'axis')
                  .call(d3.axisLeft(y));

        chartGroup.selectAll('g.area')
                    .data(stacked)
                    .enter().append('g')
                      .attr('class', 'area')
                    .append('path')
                      .transition().duration(1000).ease(d3.easeLinear)
                      .attr('class','area')
                      .attr('fill', (d, i) => colorScheme1[i])
                      .attr('opacity', 0.5)
                      .attr('d', (d) => area(d));


        let legendEntry = legend.selectAll('g.legend-entry')
                                  .data(top5)
                                  .enter().append('g')
                                    .attr('class', 'legend-entry')
                                    .attr('opacity', 0.5);

        legendEntry.append('rect')
                    .attr('fill', (d, i) => colorScheme1[i])
                    // .attr('class', 'area')
                    // .attr('opacity', 0.3)
                    .attr('width', 30)
                    .attr('height', 30)
                    .attr('x', 15)
                    .attr('y', (d, i) => i * 50)

        legendEntry.append('text')
                    .attr('x', 0)
                    .attr('y', (d, i) => i * 50 + 20)
                    .attr('fill', (d, i) => colorScheme1[i])
                    .attr('text-anchor', 'end')
                    .text(d => d);

      })
      .catch((err) => {
        console.log(err);
      })

  })
  </script>
</data-menu>
