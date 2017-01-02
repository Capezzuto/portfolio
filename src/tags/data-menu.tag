<data-menu>
  <div class="background background-yellow"></div>
  <style>
    #tooltip {
      background-color: #000;
      min-width: 100px;
      min-height: 20px;
      z-index: 40;
      color: #FFF;
      padding: 10px;
      border-radius: 15px;
    }

    #tooltip h4 {
      margin: 0;
      margin-bottom: 10px;
    }

    #tooltip h5 {
      margin: 0;
      margin-bottom: 5px;
    }
  </style>
  <div class="container">
    <h2>U.S. Box Office, Top Five Movies for the Week of November 4 - 10</h2>
  </div>

  <div class="footnotes">
    <p>Part of an ongoing project to build data visualizations with D3.js. <span class="small">Source: Box Office Mojo</span></p>
  </div>

  <script>
  this.on('mount', function() {

    const d3 = require('d3');
    const axios = require('axios');

    const parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");
    const getDay = d3.timeFormat('%a');

    const margin = { left: 80, right: 20, top: 20, bottom: 0 };
    let height = 500 - margin.top;
    let width = 960 - margin.right - margin.left;

    const svg = d3.select('.container').append('svg').attr('height', height + margin.top * 2).attr('width', width + (margin.right + margin.left) * 2);
    const tooltip = d3.select('.container').append('div').attr('id', 'tooltip').style('opacity', 0).style('position', 'absolute');

    const colorScheme = [
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
        for (let i = 0; i < 5; i++) {
          top5.push(data.movies[i].title);
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

        let area = d3.area()
                        .x((d) => x(d.data.date))
                        .y0((d) => y(d[0]))
                        .y1((d) => y(d[1]));

        let chartGroup = svg.append('g').attr('transform', `translate(${margin.left}, ${margin.top})`);
        let legend = svg.append('g').attr('transform', `translate(${width + 35}, 0)`).attr('id', 'legend');
        let pieChartGroup = svg.append('g').attr('transform', 'translate(760, 0)').attr('id', 'pie-chart');

        chartGroup.append('g')
                  .attr('class', 'axis')
                  .attr('transform', `translate(0, ${height})`)
                  .call(d3.axisBottom(x).ticks(7));
        chartGroup.append('g')
                  .attr('class', 'axis')
                  .call(d3.axisLeft(y).tickFormat(d3.format('$,.0f')));

        chartGroup.selectAll('g.area')
                    .data(stacked)
                    .enter().append('g')
                      .attr('class', 'area')
                      .attr('opacity', 0.5)
                      .on('mouseover', function(d, i) {
                        d3.select(this).attr('opacity', 1);
                        d3.select('#legend').selectAll(`g:nth-child(${i+1})`).attr('opacity', 1);
                        tooltip.style('left', `${33}vw`).style('top', `${y(d[2][1]) + 30}px`).style('opacity', 1).html(`<h4>${d.key}</h4>
                          <h5>Weekly Total:</h5><p>$${data.movies[d.index].week_gross.toLocaleString()}</p>`);
                      })
                      .on('mouseout', function(d, i) {
                        d3.select(this).attr('opacity', 0.5);
                        d3.select('#legend').selectAll(`g:nth-child(${i+1})`).attr('opacity', 0.5);
                        tooltip.style('left', '0').style('top', '0').style('opacity', 0).html(``);
                      })
                    .append('path')
                      .transition().duration(1000).ease(d3.easeLinear)
                      .attr('fill', (d, i) => colorScheme[i])
                      .attr('d', (d) => area(d))

        let legendEntry = legend.selectAll('g.legend-entry')
                                  .data(stacked)
                                  .enter().append('g')
                                    .attr('class', 'legend-entry')
                                    .attr('opacity', 0.5)
                                    .on('mouseover', function(d, i) {
                                      d3.select(this).attr('opacity', 1);
                                      d3.selectAll(`.area:nth-child(${i+3})`).attr('opacity', 1);
                                      tooltip.style('left', `${33}vw`).style('top', `${y(d[2][1]) + 30}px`).style('opacity', 1).html(`<h4>${d.key}</h4>
                                        <h5>Weekly Total:</h5><p>$${data.movies[d.index].week_gross.toLocaleString()}</p>`);
                                    })
                                    .on('mouseout', function(d, i) {
                                      d3.select(this).attr('opacity', 0.5);
                                      d3.selectAll(`.area:nth-child(${i+3})`).attr('opacity', 0.5);
                                      tooltip.style('left', '0').style('top', '0').style('opacity', 0).html(``);
                                    });

        legendEntry.append('rect')
                    .attr('fill', (d, i) => colorScheme[i])
                    .attr('width', 30)
                    .attr('height', 30)
                    .attr('x', 15)
                    .attr('y', (d, i) => i * 50);

        legendEntry.append('text')
                    .attr('x', 0)
                    .attr('y', (d, i) => i * 50 + 20)
                    .attr('fill', (d, i) => colorScheme[i])
                    .attr('text-anchor', 'end')
                    .text(d => d.key);

      })
      .catch((err) => {
        console.log(err);
      });

    function resize() {
      console.log('resize');
    }

    d3.select(window).on('resize', resize);

  })
  </script>
</data-menu>
