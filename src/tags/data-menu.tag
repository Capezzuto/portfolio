<data-menu>
  <div class="background background-yellow"></div>

  <div class="page-header"><h2>Data Visualizations</h2></div>
  <div class="container">
    <h3>U.S. Box Office, Top Five Movies for the Week of {dateRange}</h3>
  </div>

  <div class="footnotes">
    <p>Part of an ongoing project to build data visualizations with D3.js. <span class="small">Source: Box Office Mojo</span></p>
  </div>

  <script>
    this.dateRange = 'November 4-10, 2016' //eventually will be selected by user
    this.on('mount', function() {

    /* ---------------- declare preliminary variables ---------------------*/
      const d3 = require('d3');
      const axios = require('axios');

      const parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");
      const getDay = d3.timeFormat('%a');

      const tIn = d3.transition().duration(250);
      const tOut = d3.transition().duration(100);

      const margin = { left: 50, right: 30, top: 20, bottom: 20 };
      let height = 500 - margin.top - margin.bottom; // temporary
      let width = 960 - margin.right - margin.left; // temporary
      let areaHeight = 500 - margin.top - margin.bottom;
      let areaWidth = 960 - margin.right - margin.left;
      let pieHeight = 400 - margin.top - margin.bottom;
      let pieWidth = 400 - margin.right - margin.left;
      let barHeight = 300 - margin.top - margin.bottom;
      let barWidth = 960 - margin.right - margin.left;

      let fullWidth = width + margin.right + margin.left;
      let fullHeight = areaHeight + pieHeight + barHeight + 3 * (margin.top + margin.bottom);

      const svg = d3.select('.container')
                    .append('svg')
                      .attr('height', fullHeight)
                      .attr('width', fullWidth)
                      .call(responsivefy);

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

      const areaChartGroup = svg
                              .append('g')
                              .attr('id', 'area-chart')
                              .attr('transform', `translate(${margin.left}, ${margin.top})`);
      const legend = svg
                      .append('g')
                      .attr('id', 'legend')
                      .attr('transform', `translate(${areaWidth}, 0)`);

      const pieChartGroup = svg
                              .append('g')
                              .attr('id', 'pie-chart')
                              .attr('transform', `translate(${pieWidth / 2 + 2 * margin.left}, ${areaHeight + pieHeight / 2 +(2 * margin.top) + margin.bottom})`);

      const barChartGroup = svg
                              .append('g')
                              .attr('id', 'bar-chart')
                              .attr('transform', `translate(0, ${areaHeight + pieHeight + 2 * (margin.top + margin.bottom)})`);

      let selectedWeek = '2016_45';


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
          const areaXScale = d3.scaleTime()
                      .domain([
                        d3.min(data.days, day => parseTime(day.date)),
                        d3.max(data.days, day => parseTime(day.date))
                      ])
                      .range([0, width]);

          const areaXAxis = d3.axisBottom(areaXScale).ticks(7);

          const areaYScale = d3.scaleLinear()
                      .domain([0, d3.max(data.days, day => day.top10[0].daily_gross)])
                      .range([areaHeight, 0]);

          const areaYAxis = d3.axisLeft(areaYScale).tickFormat(d3.format('$,.2s'));

          areaChartGroup.append('g')
                      .attr('class', 'axis')
                      .attr('transform', `translate(0, ${areaHeight})`)
                      .call(areaXAxis);
          areaChartGroup.append('g')
                      .attr('class', 'axis')
                      .call(areaYAxis);

  /* ------------------------------ area data ------------------------------ */
          const area = d3.area()
                          .x((d, i) => areaXScale(d.date))
                          .y0(areaYScale(0))
                          .y1(d => areaYScale(d.gross));

          let areaUpdate = areaChartGroup.selectAll('.area').data(top5);

          areaUpdate.enter()
                      .append('path')
                        .attr('class', 'area')
                        .attr('d', d => area(d.values))
                        .attr('fill-opacity', 0.05)
                        .attr('fill', (d, i) => colorScheme[i])
                        .attr('stroke', (d, i) => colorScheme[i])
                        .on('mouseover', function(d, i) {
                          d3.select(this)
                            .transition(tIn)
                            .attr('fill-opacity', 1);
                          d3.select('#legend')
                            .selectAll(`g:nth-child(${i+1})`)
                            .transition(tIn)
                            .attr('opacity', 1);
                          tooltip
                            .style('left', `${33}vw`)
                            .style('top', `${areaYScale(d.values[2].gross) + 70}px`)
                            .style('opacity', 1)
                            .html(
                              `<h4>${d.title}</h4>
                               <h5>Weekly Total:</h5>
                               <p>$${data.movies[d.rank - 1].week_gross.toLocaleString()}</p>`
                            );
                        })
                        .on('mouseout', function(d, i) {
                          d3.select(this)
                            .transition(tOut)
                            .attr('fill-opacity', 0.05);
                          d3.select('#legend')
                            .selectAll(`g:nth-child(${i+1})`)
                            .transition(tOut)
                            .attr('opacity', 0.5);
                          tooltip
                            .style('opacity', 0)
                            .style('left', '0')
                            .style('top', '0')
                            .html(``);
                        });

  /* ---------------------------- legend data ---------------------------- */

          let legendEntry = legend.selectAll('g.legend-entry')
                                    .data(top5)
                                    .enter()
                                    .append('g')
                                      .attr('class', 'legend-entry')
                                      .attr('opacity', 0.5)
                                      .on('mouseover', function(d, i) {
                                        d3.select(this)
                                          .transition(tIn)
                                          .attr('opacity', 1);
                                        d3.selectAll(`.area:nth-child(${i+3})`)
                                          .transition(tIn)
                                          .attr('fill-opacity', 1);
                                        tooltip
                                          .style('left', `${33}vw`)
                                          .style('top', `${areaYScale(d.values[2].gross) + 100}px`)
                                          .style('opacity', 1)
                                          .html(
                                            `<h4>${d.title}</h4>
                                             <h5>Weekly Total:</h5>
                                             <p>$${data.movies[d.rank - 1].week_gross.toLocaleString()}</p>`
                                          );
                                      })
                                      .on('mouseout', function(d, i) {
                                        d3.select(this)
                                          .transition(tOut)
                                          .attr('opacity', 0.5);
                                        d3.selectAll(`.area:nth-child(${i+3})`)
                                          .transition(tOut)
                                          .attr('fill-opacity', 0.05);
                                        tooltip
                                          .style('opacity', 0)
                                          .style('left', '0')
                                          .style('top', '0')
                                          .html(``);
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

/* ---------------------------- circle data ---------------------------- */
          const radius = pieWidth / 2;
          let top5week = [];
          for (let i = 0; i < 5; i++) {
            top5week.push({
              title: data.movies[i].title,
              week_gross: data.movies[i].week_gross
            })
          }

          let totalOfFive = top5week.reduce((total, movie) => {
            return total + movie.week_gross;
          },0);

          top5week.push({
            title: 'Other',
            week_gross: data.total_gross - totalOfFive
          });
          console.log('top5week', top5week)

          const arc = d3.arc()
                        .innerRadius(radius - 90)
                        .outerRadius(radius - 10);

          const labelArc = d3.arc()
                              .innerRadius(radius - 60)
                              .outerRadius(radius - 40);

          const pie = d3.pie().sort(null).value(d => d.week_gross);
          let pieUpdate = pieChartGroup
                            .selectAll('.pie')
                            .data(pie(top5week))
                            // .enter()
                            // .append('g')
                            //   .attr('class', 'pie');

          pieUpdate.enter()
                    .append('path')
                      .attr('d', arc)
                      .style('fill', (d, i) => colorScheme[i])
                      .style('fill-opacity', 0.5)
                      .on('mouseover', function(d) {
                        // console.log('this is', this);
                        d3.select(this)
                          .transition(tIn)
                          .style('transform', 'scale(1.1)')
                          .style('fill-opacity', 1);
                      })
                      .on('mouseout', function(d) {
                        d3.select(this)
                          .transition(tOut)
                          .style('transform', 'scale(1)')
                          .style('fill-opacity', 0.5)
                      })

          pieUpdate.enter()
                    .append('text')
                      .attr('transform', d => `translate(${labelArc.centroid(d)})`)
                      .attr('dy', '0.6em')
                      .attr('dx', /*(d, i) => i > 1 && i !== 5 ? -20 : 0*/ -20)
                      .text(d => {
                        if (d.data.title.length > 15) {
                          return d.data.title.slice(0, 11) + '...'
                        }
                        return d.data.title
                      })
                      .on('mouseover', function(d, i) {
                        console.log(document.querySelectorAll('#pie-chart > path')[i])
                        d3.select(`#pie-chart > path:nth-child(${i + 1})`)
                          .transition(tIn)
                          .style('transform', 'scale(1.1)')
                      });




        })
        .catch((err) => {
          console.log(err);
        });

  /* ---------- responsivefy originally written by Brendan Sudol ---------- */
  /* ---------  http://www.brendansudol.com/writing/responsive-d3 ---------  */
      function responsivefy(svg) {
        let container = d3.select(svg.node().parentNode);
        let width = parseInt(svg.style('width'));
        let height = parseInt(svg.style('height'));
        const aspect = width / height;

        svg.attr('viewBox', `0 0 ${width} ${height}`)
            .attr('preserveAspectRatio', 'xMinYMid')
            .call(resize);

        d3.select(window).on(`resize.${container.attr('id')}`, resize);

        function resize() {
          let targetWidth = parseInt(container.style('width'));
          svg.attr('width', targetWidth)
          svg.attr('height', Math.round(targetWidth / aspect));
        }
      }

    });
  </script>
</data-menu>
