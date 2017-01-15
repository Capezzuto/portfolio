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
  <div class="page-header"><h2>Data Visualizations</h2></div>
  <div class="container">
    <h3>U.S. Box Office, Top Five Movies for the Week of November 4-10, 2016</h3>
  </div>

  <div class="footnotes">
    <p>Part of an ongoing project to build data visualizations with D3.js. <span class="small">Source: Box Office Mojo</span></p>
  </div>

  <script>
  this.on('mount', function() {

  /* ---------------- declare preliminary variables ---------------------*/
    const d3 = require('d3');
    const axios = require('axios');

    const parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");
    const getDay = d3.timeFormat('%a');

    const margin = { left: 80, right: 20, top: 20, bottom: 20 };
    let height = 500 - margin.top - margin.bottom;
    let width = 960 - margin.right - margin.left;

    let fullWidth = width + margin.right + margin.left;
    let fullHeight = height + margin.top + margin.bottom;

    const svg = d3.select('.container')
                  .append('svg')
                    .attr('height', fullHeight)
                    .attr('width', fullWidth);

    const tooltip = d3.select('.container')
                      .append('div')
                        .attr('id', 'tooltip')
                        .style('opacity', 0)
                        .style('position', 'absolute');

    const colorScheme = [
      'rgb(0, 154, 212)',
      'rgb(236, 0, 140)',
      'rgb(240, 230, 0)',
      'rgb(170, 205, 255)',
      'rgb(250, 170, 170)',
      'rgb(60, 174, 239)',
      'rgb(255, 242, 0)'
    ];

    const chartGroup = svg.append('g').attr('transform', `translate(${margin.left}, ${margin.top})`);
    const legend = svg.append('g').attr('transform', `translate(${width + 35}, 0)`).attr('id', 'legend');
    // const pieChartGroup = svg.append('g').attr('transform', 'translate(760, 0)').attr('id', 'pie-chart');

    let selectedWeek = '2016_46';
    let dateRange = 'November 4-10, 2016' //eventually will be selected by user

    axios.get(`/data/boxoffice/weekly/${selectedWeek}`)
      .then((response) => {
        const data = response.data;
        console.log(data);
        // let dateRange = 'November 4-10, 2016';

/* ----------------------------- clean data ----------------------------- */
        let top5 = [];
        for (let i = 0; i < 5; i++) {
          let title = data.movies[i].title;
          top5.push(
            {
              title: title,
              rank: data.movies[i].rank,
              values: data.days.map(day => {
                return {
                  date: parseTime(day.date),
                  gross: day.top10.find(movie => movie.title === title).daily_gross || 0
                 }
               })
            }
          );
        }

        console.log(top5);
/* ------------------------------ axis data ------------------------------ */
        const xScale = d3.scaleTime()
                    .domain([
                      d3.min(data.days, day => parseTime(day.date)),
                      d3.max(data.days, day => parseTime(day.date))
                    ])
                    .range([0, width]);

        const xAxis = d3.axisBottom(xScale).ticks(7);

        const yScale = d3.scaleLinear()
                    .domain([0, d3.max(data.days, day => day.top10[0].daily_gross)])
                    .range([height, 0]);

        const yAxis = d3.axisLeft(yScale).tickFormat(d3.format('$,.0f'));

        chartGroup.append('g')
                    .attr('class', 'axis')
                    .attr('transform', `translate(0, ${height})`)
                    .call(xAxis);
        chartGroup.append('g')
                    .attr('class', 'axis')
                    .call(yAxis);

/* ------------------------------ area data ------------------------------ */
        let area = d3.area()
                        .x((d, i) => xScale(d.date))
                        .y0(yScale(0))
                        .y1(d => yScale(d.gross));

        chartGroup.selectAll('.area')
                    .data(top5)
                    .enter().append('path')
                      .attr('class', 'area')
                      .attr('d', d => area(d.values))
                      .attr('fill-opacity', d => { console.log(d); return 0.05; })
                      .attr('fill', (d, i) => colorScheme[i])
                      .attr('stroke', (d, i) => colorScheme[i])
                      .on('mouseover', function(d, i) {
                        d3.select(this).attr('fill-opacity', 1);
                        d3.select('#legend').selectAll(`g:nth-child(${i+1})`).attr('opacity', 1);
                        tooltip.style('left', `${33}vw`).style('top', `${yScale(d.values[2].gross) + 70}px`).style('opacity', 1).html(`<h4>${d.title}</h4>
                          <h5>Weekly Total:</h5><p>$${data.movies[d.rank - 1].week_gross.toLocaleString()}</p>`);
                      })
                      .on('mouseout', function(d, i) {
                        d3.select(this).attr('fill-opacity', 0.05);
                        d3.select('#legend').selectAll(`g:nth-child(${i+1})`).attr('opacity', 0.5);
                        tooltip.style('left', '0').style('top', '0').style('opacity', 0).html(``);
                      });

/* ---------------------------- legend data ---------------------------- */

        let legendEntry = legend.selectAll('g.legend-entry')
                                  .data(top5)
                                  .enter().append('g')
                                    .attr('class', 'legend-entry')
                                    .attr('opacity', 0.5)
                                    .on('mouseover', function(d, i) {
                                      d3.select(this).attr('opacity', 1);
                                      d3.selectAll(`.area:nth-child(${i+3})`).attr('fill-opacity', 1);
                                      tooltip.style('left', `${33}vw`).style('top', `${yScale(d.values[2].gross) + 100}px`).style('opacity', 1).html(`<h4>${d.title}</h4>
                                        <h5>Weekly Total:</h5><p>$${data.movies[d.rank - 1].week_gross.toLocaleString()}</p>`);
                                    })
                                    .on('mouseout', function(d, i) {
                                      d3.select(this).attr('opacity', 0.5);
                                      d3.selectAll(`.area:nth-child(${i+3})`).attr('fill-opacity', 0.05);
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
                    .text(d => d.title);

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
