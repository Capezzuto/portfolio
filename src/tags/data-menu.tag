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

      const margin = { left: 50, right: 30, top: 30, bottom: 20 };
      const areaHeight = 600 - margin.top - margin.bottom;
      const areaWidth = 960 - margin.right - margin.left;
      const pieHeight = 400 - margin.top - margin.bottom;
      const pieWidth = 400 - margin.right - margin.left;
      const barHeight = 300 - margin.top - margin.bottom;
      const barWidth = 960 - margin.right - margin.left;

      const fullWidth = areaWidth + margin.right + margin.left;
      const fullHeight = areaHeight + pieHeight + barHeight + 3 * (margin.top + margin.bottom);

      const svg = d3.select('.container')
                    .append('svg')
                      .attr('height', fullHeight)
                      .attr('width', fullWidth)
                      .call(responsivefy);

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
                      .attr('transform', `translate(${areaWidth}, 5)`);

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
          // console.log(data);
          // let dateRange = 'November 4-10, 2016';

  /* ----------------------------- clean data ----------------------------- */
          let top5 = [];
          for (let i = 0; i < 5; i++) {
            let { title, total } = data.movies[i];
            top5.push(
              {
                title,
                total,
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

          // console.log(top5);
  /* ------------------------------ axis data ------------------------------ */
          const areaXScale = d3.scaleTime()
                      .domain([
                        d3.min(data.days, day => parseTime(day.date)),
                        d3.max(data.days, day => parseTime(day.date))
                      ])
                      .range([0, areaWidth]);

          const areaXAxis = d3.axisBottom(areaXScale).ticks(7);

          const areaYScale = d3.scaleLinear()
                      .domain([0, d3.max(data.days, day => day.top10[0].daily_gross) * 1.2])
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
                          let title = d.title;

                          d3.select(this.parentNode)
                            .selectAll('.area')
                            .filter((d, i) => d.title !== title)
                            .attr('fill-opacity', 0)
                            .attr('stroke-opacity', 0.1);

                          d3.select(this.parentNode)
                            .selectAll('.points')
                            .filter((d, i) => d.title !== title)
                            .selectAll('circle')
                            .attr('fill-opacity', 0.1)

                          d3.select(this)
                            .transition(tIn)
                            .attr('fill-opacity', 0.3);

                          d3.select('#legend')
                            .selectAll(`g:nth-child(${i+1})`)
                            .transition(tIn)
                            .attr('opacity', 1);

                        })
                        .on('mouseout', function(d, i) {
                          let title = d.title;

                          d3.select(this.parentNode)
                            .selectAll('.area')
                            .attr('fill-opacity', 0.05)
                            .attr('stroke-opacity', 1);

                          d3.select(this.parentNode)
                            .selectAll('circle')
                            .attr('fill-opacity', 1)

                          d3.select(this)
                            .transition(tOut)
                            .attr('fill-opacity', 0.05);

                          d3.select('#legend')
                            .selectAll(`g:nth-child(${i+1})`)
                            .transition(tOut)
                            .attr('opacity', 0.5);
                        });

  /* ------------------------- scatterplot data ------------------------- */

          let pointsUpdate = areaUpdate.enter()
                                        .append('g')
                                          .attr('class', 'points')
                                          .selectAll('circle')
                                          .data(d => d.values);
          let point = pointsUpdate.enter()
                        .append('circle')
                          .attr('r', 3)
                          .attr('cx', d => areaXScale(d.date))
                          .attr('cy', d => areaYScale(d.gross))
                          .attr('fill', function() {
                            let i = d3.select(this.parentNode).data()[0].rank - 1;
                            return colorScheme[i];
                          })
                          .attr('stroke', function() {
                            let i = d3.select(this.parentNode).data()[0].rank - 1;
                            return colorScheme[i];
                          })
                          .attr('stroke-width', 20)
                          .attr('stroke-opacity', 0);

          point.on('mouseover', function(d, i) {
                  let title = d3.select(this.parentNode).data()[0].title;
                  let { date, gross } = d;
                  d3.select(this)
                      .attr('fill-opacity', 0)
                      .attr('stroke-opacity', 1)
                      .attr('stroke-width', 20);

                  d3.selectAll('.area')
                      .filter(d => d.title !== title)
                      .attr('fill-opacity', 0)
                      .attr('stroke-opacity', 0.1);

                  d3.selectAll('.points')
                    .filter(d => d.title !== title)
                    .selectAll('circle')
                    .attr('fill-opacity', 0.1)

                  const tooltip = pointsUpdate
                                    .enter()
                                    .append('g')
                                    .attr('id', 'tooltip');
                  // console.log('tooooooltip', tooltip);

                  tooltip.append('path')
                          .attr('d', d => `M${areaXScale(date) + Math.cos(45) * 11.5} ${areaYScale(gross) - Math.sin(45) * 11.5} l 40 -40 l 200 0`)
                          .style('fill', 'none')
                          .style('stroke', '#000000')
                          .style('stroke-opacity', 0.5)
                          .style('stroke-width', 0.5);

                  // tooltip.append('text')
                  //         .attr('dx', labelArc.centroid(d)[0] + 75)
                  //         .attr('dy', labelArc.centroid(d)[1] - 53)
                  //         // .attr('class', 'tooltip-pct')
                  //         .text(`%${d.data.pct} of total weekly gross`);
                  //
                  // tooltip.append('text')
                  //             .attr('class', 'pietip-title')
                  //             .attr('dx', labelArc.centroid(d)[0] + 75)
                  //             .attr('dy', labelArc.centroid(d)[1] - 73)
                  //             .text(d.data.title);
                });

          point.on('mouseout', function(d, i) {
                  d3.select(this)
                      .attr('fill-opacity', 1)
                      .attr('stroke-opacity', 0)
                      .attr('stroke-width', 20);

                  d3.selectAll('circle')
                    .attr('fill-opacity', 1);

                  d3.selectAll('.area')
                    .attr('fill-opacity', 0.05)
                    .attr('stroke-opacity', 1)
                  // console.log('tooltip?', d3.select('#tooltip').nodes());
                  if (d3.select('#tooltip').nodes().length) {
                    d3.selectAll('#tooltip').remove()
                  }
                })


  /* ---------------------------- legend data ---------------------------- */

          let legendEntry = legend.selectAll('g.legend-entry')
                                    .data(top5)
                                    .enter()
                                    .append('g')
                                      .attr('class', 'legend-entry')
                                      .attr('opacity', 0.5);

          legendEntry.on('mouseover', function(d, i) {
                        let title = d.title;

                        d3.select(this.parentNode.previousSibling)
                          .selectAll('.area')
                          .filter(d => d.title !== title)
                          .attr('fill-opacity', 0)
                          .attr('stroke-opacity', 0.1);

                        d3.select(this.parentNode.previousSibling)
                          .selectAll('.points')
                          .filter(d => d.title !== title)
                          .selectAll('circle')
                          .attr('fill-opacity', 0.3)

                        d3.select(this)
                          .transition(tIn)
                          .attr('opacity', 1);

                        d3.selectAll(`.area:nth-child(${i+3})`)
                          .transition(tIn)
                          .attr('fill-opacity', 0.3);

                      });

            legendEntry.on('mouseout', function(d, i) {
                          let title = d.title;

                          d3.select(this.parentNode.previousSibling)
                            .selectAll('.area')
                            .attr('fill-opacity', 0.05)
                            .attr('stroke-opacity', 1);

                          d3.select(this.parentNode.previousSibling)
                            .selectAll('circle')
                            .attr('fill-opacity', 1)

                          d3.select(this)
                            .transition(tOut)
                            .attr('opacity', 0.5);

                          d3.selectAll(`.area:nth-child(${i+3})`)
                            .transition(tOut)
                            .attr('fill-opacity', 0.05);
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
              week_gross: data.movies[i].week_gross,
              pct: ((data.movies[i].week_gross / data.total_gross) * 100).toFixed(2)
            })
          }

          let totalOfFive = top5week.reduce((total, movie) => {
            return total + movie.week_gross;
          },0);

          top5week.push({
            title: 'Other',
            week_gross: data.total_gross - totalOfFive,
            pct: (((data.total_gross - totalOfFive)/ data.total_gross) * 100).toFixed(2)
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

          pieUpdate.enter()
                    .append('path')
                      .attr('d', arc)
                      .style('fill', (d, i) => colorScheme[i])
                      .style('fill-opacity', 0.5)
                      .on('mouseover', function(d, i) {
                        const pietip = pieChartGroup
                                          .append('g')
                                          .attr('id', 'pietip');

                        pietip.append('path')
                                .attr('d', `M${labelArc.centroid(d)[0]} ${labelArc.centroid(d)[1] - 10} l 70 -40 l 200 0`)
                                .style('fill', 'none')
                                .style('stroke', '#000000')
                                .style('stroke-opacity', '0.5');

                        pietip.append('text')
                                .attr('dx', labelArc.centroid(d)[0] + 75)
                                .attr('dy', labelArc.centroid(d)[1] - 53)
                                .attr('class', 'pietip-pct')
                                .text(`%${d.data.pct} of total weekly gross`);

                        pietip.append('text')
                                    .attr('class', 'pietip-title')
                                    .attr('dx', labelArc.centroid(d)[0] + 75)
                                    .attr('dy', labelArc.centroid(d)[1] - 73)
                                    .text(d.data.title);

                        d3.select(this)
                          .transition(tIn)
                          .style('transform', 'scale(1.1)')
                          .style('fill-opacity', 1);
                      })
                      .on('mouseout', function(d, i) {

                        d3.select(this)
                          .transition(tOut)
                          .style('transform', 'scale(1)')
                          .style('fill-opacity', 0.5)

                        if (d3.select('#pietip').nodes().length) {
                          pieChartGroup.select('#pietip').remove()
                        }
                      })

          pieUpdate.enter()
                    .append('text')
                      .attr('transform', d => `translate(${labelArc.centroid(d)})`)
                      .attr('dx', -20)
                      .attr('dy', '0.6em')
                      .attr('pointer-events', 'none')
                      .style('fill-opacity', 0.5)
                      .text(d => {
                        if (d.data.title.length > 15) {
                          return d.data.title.slice(0, 11) + '...'
                        }
                        return d.data.title
                      })
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
