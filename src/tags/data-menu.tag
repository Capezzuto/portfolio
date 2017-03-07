<data-menu>
  <div class="background background-yellow"></div>

  <div class="page-header"><h2>Data Visualizations</h2></div>
  <div class="container">
    <h3>U.S. Box Office, Top Five Movies for the Week of {dateRange}</h3>
    <select onchange={selectAndUpdateGraph}>
      <option value={null} selected>Choose a week</option>
      <option each={week, i in menuOptions} value={week[0]}>{week[1]}</option>
    </select>
  </div>

  <div class="footnotes">
    <p>Part of an ongoing project to build data visualizations with D3.js. <span class="small">Source: Box Office Mojo</span></p>
  </div>

  <script>
  /* ---------------- declare preliminary variables ---------------------*/
  const tag = this;
  const d3 = require('d3');
  const axios = require('axios');

  const parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");
  const getDay = d3.timeFormat('%a');
  const getDate = d3.timeFormat('%b %d, %Y')

  const tIn = d3.transition().duration(250);
  const tOut = d3.transition().duration(100);

  const margin = { left: 50, right: 30, top: 50, bottom: 50 };
  const headingHeight = 30;
  const areaHeight = 650 - headingHeight - margin.top - margin.bottom;
  const areaWidth = 960 - margin.right - margin.left;
  const pieHeight = 400 - margin.top - margin.bottom;
  const pieWidth = 400 - margin.right - margin.left;
  const barHeight = 450 - margin.top - margin.bottom;
  const barWidth = 960 - margin.right - margin.left;

  const fullWidth = areaWidth + margin.right + margin.left;
  const fullHeight = areaHeight + pieHeight + barHeight + headingHeight + 3 * (margin.top + margin.bottom);

  const colorScheme = [
    'rgb(0, 154, 212)',
    'rgb(236, 0, 140)',
    'rgb(240, 230, 0)',
    'rgb(170, 205, 255)',
    'rgb(250, 170, 170)',
    'rgb(60, 174, 239)',
    'rgb(255, 242, 0)'
  ];

  let selectedWeek = '';
  tag.dateRange = ''; //eventually will be selected by user
  tag.menuOptions = [];

    tag.on('mount', function() {

      const svg = d3.select('.container')
      .append('svg')
      .attr('height', fullHeight)
      .attr('width', fullWidth)
      .call(responsivefy);

      /* -------------------- set up area chart groups and axes -------------------- */

      const areaHeading = svg.append('text')
                              .attr('transform', `translate(${margin.left}, ${headingHeight})`)
                              .attr('class', 'boxoffice-heading')
                              .text('Daily sales for top five movies');

      const areaChartGroup = svg.append('g')
                                  .attr('id', 'area-chart')
                                  .attr('transform', `translate(${margin.left}, ${margin.top + headingHeight})`);

      const areaXScale = d3.scaleTime()
                            .range([0, areaWidth]);

      let areaXAxis = d3.axisBottom(areaXScale).ticks(7);

      const areaYScale = d3.scaleLinear()
                            .domain([0, 12000000])
                            .range([areaHeight, 0]);

      let areaYAxis = d3.axisLeft(areaYScale).tickFormat(d3.format('$,.2s'));

      areaChartGroup.append('g')
                      .attr('class', 'x axis')
                      .attr('transform', `translate(0, ${areaHeight})`)
                      .call(areaXAxis);

      areaChartGroup.append('g')
                      .attr('class', 'y axis')
                      .call(areaYAxis);

      const legend = svg.append('g')
                          .attr('id', 'legend')
                          .attr('transform', `translate(${areaWidth}, ${margin.top + headingHeight})`);

      /* -------------------- set up pie chart groups and axes -------------------- */

      const pieHeading = svg.append('text')
                              .attr('transform', `translate(${fullWidth - 2 * margin.right}, ${areaHeight + 2 * (headingHeight + margin.top + margin.bottom)})`)
                              .attr('class', 'boxoffice-heading')
                              .attr('text-anchor', 'end')
                              .text('Total sales for week, top five movies');

      const pieChartGroup = svg.append('g')
                                .attr('id', 'pie-chart')
                                .attr('transform', `translate(${pieWidth / 2 + 2 * margin.left}, ${areaHeight + pieHeight / 2 + (2 * margin.top) + margin.bottom})`);

      /* -------------------- set up bar chart groups and axes -------------------- */

      const barHeading = svg.append('text')
                              .attr('transform', `translate(${fullWidth - margin.right}, ${fullHeight - barHeight - 2 * margin.bottom - margin.top})`)
                              .attr('class', 'boxoffice-heading')
                              .attr('text-anchor', 'end')
                              .text('Daily per theater average, top five movies');

      const barChartGroup = svg.append('g')
                                .attr('id', 'bar-chart')
                                .attr('transform', `translate(${margin.left}, ${areaHeight + pieHeight + 2 * (margin.top + margin.bottom)})`);

      const barLegend = svg.append('g')
                            .attr('id', 'bar-legend')
                            .attr('transform', `translate(${barWidth}, ${fullHeight - margin.bottom - barHeight - margin.top - 30})`);


      const barX0Scale = d3.scaleBand()
                            .rangeRound([0, barWidth])
                            .paddingInner(0.1)
                            // .domain(dailyData.map(d => parseTime(d.date)))

      const barX1Scale = d3.scaleBand()
                            .padding(0.05)
                            // .domain(top5Keys)
                            .rangeRound([0, barX0Scale.bandwidth()])

      let barXAxis = d3.axisBottom(barX0Scale).tickFormat(getDay)

      const barYScale = d3.scaleLinear()
                          // .domain([0, d3.max(dailyData, day => d3.max(day.top5, movie => movie.avg)) * 1.1])
                          .range([barHeight, 0]);

      let barYAxis = d3.axisLeft(barYScale).tickFormat(d3.format('$,.2s'))

      barChartGroup.append('g')
                    .attr('class', 'barXAxis')
                    .attr('transform', `translate(0, ${barHeight})`)
                    .call(barXAxis);

      barChartGroup.append('g')
                    .attr('class', 'barYAxis')
                    .call(barYAxis);

      /* ------------------------ initial ajax requests ------------------------ */

      axios.get('/data/boxoffice/latest')
        .then((response) => {
          updateCharts(response.data);
        })
        .catch((err) => {
          console.log(err);
        });

      axios.get('/data/boxoffice/weekly')
        .then((response) => {
          let newOptions = [];
          for (let key in response.data) {
            newOptions.push([key, response.data[key]]);
          }
          newOptions.sort((a, b) => {
            return a[0] > b[0] ? 1 : -1;
          });
          tag.menuOptions = newOptions;
          tag.update();
        });


      function updateCharts(data) {
        tag.dateRange = data.date_range;
        tag.update();
        console.log('data ===', data);

        /* --------------------- clean data --------------------- */

        let top5 = [];
        for (let i = 0; i < 5; i++) {
          let { title, total } = data.movies[i];
          top5.push(
            {
              title,
              total,
              rank: data.movies[i].rank,
              values: data.days.map(day => {
                let movie = day.top10.find(movie => movie.title === title);
                return {
                  date: parseTime(day.date),
                  gross: movie ? movie.daily_gross : 0
                };
               })
            }
          );
        }

        // console.log(top5);
      /* ------------------------------ axis data ------------------------------ */
      areaXScale.domain([
                  d3.min(data.days, day => parseTime(day.date)),
                  d3.max(data.days, day => parseTime(day.date))
                ])
                .range([0, areaWidth]);

      const areaXAxis = d3.axisBottom(areaXScale).ticks(7);

      const areaYScale = d3.scaleLinear()
                  .domain([0, d3.max(data.days, day => day.top10[0].daily_gross) * 1.2])
                  .range([areaHeight, 0]);

      const areaYAxis = d3.axisLeft(areaYScale).tickFormat(d3.format('$,.2s'))

      areaChartGroup.select('.x.axis')
                    .call(areaXAxis);

      areaChartGroup.select('.y.axis')
                    .call(areaYAxis);

        /* ------------------------------ area data ------------------------------ */
        const area = d3.area()
                        .x((d, i) => areaXScale(d.date))
                        .y0(areaYScale(0))
                        .y1(d => areaYScale(d.gross));

        let areaUpdate = areaChartGroup
                          .selectAll('.area')
                          .data(top5, d => d.total);

        areaUpdate.exit().remove();

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

        let pointsGroupUpdate = areaChartGroup
                                  .selectAll('.points')
                                  .data(top5, d => d.total);

        let pointsUpdate = pointsGroupUpdate.enter()
                            .append('g')
                              .attr('class', 'points')
                              .selectAll('circle')
                              .data(d => d.values, d => d.gross);

        pointsGroupUpdate.exit().remove();
        pointsUpdate.exit().remove();

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
                let xCoord = areaXScale(date);

                tooltip.append('path')
                        .attr('d', () => {
                          if (xCoord > 600) {
                            return `M${xCoord + Math.cos(135) * 10} ${areaYScale(gross) - Math.sin(45) * 10} l -40 -40 l -200 0`;
                          }
                          return `M${xCoord + Math.cos(45) * 11.5} ${areaYScale(gross) - Math.sin(45) * 11.5} l 40 -40 l 200 0`;
                      })
                        .style('fill', 'none')
                        .style('stroke', '#000000')
                        .style('stroke-width', 0.5);

                tooltip.append('text')
                        .attr('dx', () => {
                          if (xCoord > 600) {
                            return xCoord + Math.cos(135) * 10 -235;
                          }
                          return xCoord + Math.cos(45) * 11.5 + 45
                        })
                        .attr('dy', areaYScale(gross) - Math.sin(45) * 11.5 - 43)
                        .attr('class', 'tooltip-data')
                        .text(`${getDate(date)} -- $${gross.toLocaleString()}`);

                tooltip.append('text')
                            .attr('class', 'tooltip-title')
                            .attr('dx', () => {
                              if (xCoord > 600) {
                                return xCoord + Math.cos(135) * 10 -235;
                              }
                              return xCoord + Math.cos(45) * 11.5 + 45
                            })
                            .attr('dy', areaYScale(gross) - Math.sin(45) * 11.5 - 62)
                            .text(title);
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
              });


        /* ---------------------------- legend data ---------------------------- */

        let legendUpdate = legend.selectAll('.legend-entry')
                                  .data(top5, d => d.total);

        legendUpdate.exit().remove();

        let legendEntry = legendUpdate.enter()
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
                    .attr('y', (d, i) => i * 45);

        legendEntry.append('text')
                    .attr('x', 0)
                    .attr('y', (d, i) => i * 45 + 20)
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

        const arc = d3.arc()
                      .innerRadius(radius - 90)
                      .outerRadius(radius - 10);

        const labelArc = d3.arc()
                            .innerRadius(radius - 60)
                            .outerRadius(radius - 40);

        let pie = d3.pie().sort(null).value(d => d.week_gross);

        let pieUpdate = pieChartGroup
                          .selectAll('.pie')
                          .data(pie(top5week), d => d.data.week_gross)

        pieUpdate.exit().remove();

        let pieEnter = pieUpdate.enter()
                                  .append('g')
                                    .attr('class', 'pie');

        pieEnter.append('path')
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
                            .text(`%${d.data.pct} of total weekly box office`);

                    pietip.append('text')
                            .attr('class', 'pietip-gross')
                            .attr('dx', labelArc.centroid(d)[0] + 75)
                            .attr('dy', labelArc.centroid(d)[1] - 70)
                            .text(`$${d.data.week_gross.toLocaleString()}`);

                    pietip.append('text')
                                .attr('class', 'pietip-title')
                                .attr('dx', labelArc.centroid(d)[0] + 75)
                                .attr('dy', labelArc.centroid(d)[1] - 90)
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


          pieEnter.append('text')
                    .style('fill-opacity', 0.5)
                    .attr('transform', d => `translate(${labelArc.centroid(d)})`)
                    .attr('dx', -20)
                    .attr('dy', '0.6em')
                    .attr('pointer-events', 'none')
                    .text(d => {
                      if (d.data.title.length > 15) {
                        return d.data.title.slice(0, 11) + '...'
                      }
                      return d.data.title
                    });

        /* ------------------------------ bar graph ------------------------------ */

        let top5Hash = {};
        let top5Keys = [];
        for (let i = 0; i < 5; i++) {
          top5Hash[data.movies[i].title] = data.movies[i].title;
          top5Keys.push(data.movies[i].title);
        }

        const dailyData = data.days.map(day => {
          return { date: day.date,
                   top5: top5Keys.map(key => {
                    let movie = day.top10.find(movie => movie.title === key);
                    return movie ? movie : {
                                             avg: 0,
                                             daily_gross: 0,
                                             theaters: 0,
                                             title: key
                                           };
                    })
                 };
        });

        const barX0Scale = d3.scaleBand()
                              .rangeRound([0, barWidth])
                              .paddingInner(0.1)
                              .domain(dailyData.map(d => parseTime(d.date)))

        const barX1Scale = d3.scaleBand()
                              .padding(0.05)
                              .domain(top5Keys)
                              .rangeRound([0, barX0Scale.bandwidth()])

        let barXAxis = d3.axisBottom(barX0Scale).tickFormat(getDay)

        const barYScale = d3.scaleLinear()
                            .domain([0, d3.max(dailyData, day => d3.max(day.top5, movie => movie.avg)) * 1.1])
                            .range([barHeight, 0]);

        let barYAxis = d3.axisLeft(barYScale).tickFormat(d3.format('$,.2s'))

        barChartGroup.select('.barXAxis')
                      .call(barXAxis);

        barChartGroup.select('.barYAxis')
                      .call(barYAxis);

        let barGroupUpdate = barChartGroup.selectAll('.bargroup').data(dailyData, d => d.date.toString());

        let barGroup = barGroupUpdate.enter()
                        .append('g')
                          .attr('class', 'bargroup')
                          .attr('transform', d => `translate(${barX0Scale(parseTime(d.date))}, 0)`)
                          .attr('data-transform', d => barX0Scale(parseTime(d.date)));

        let barUpdate = barGroup
                          .selectAll('.bar')
                          .data(d => d.top5, d => d.title);

        barGroupUpdate.exit().remove();
        barUpdate.exit().remove();

        let bar = barUpdate.enter()
                    .append('rect')
                      .attr('class', (d, i) => `bar bar-${i}`)
                      .attr('x', d => barX1Scale(d.title))
                      .attr('y', d => barYScale(d.avg))
                      .attr('width', barX1Scale.bandwidth())
                      .attr('height', d => barHeight - barYScale(d.avg))
                      .attr('fill', (d, i) => colorScheme[i])
                      .attr('fill-opacity', 0.5);

        bar.on('mouseover', function(d, i) {

          d3.select(this)
            .transition(tIn)
            .attr('fill-opacity', 1);

          const groupXVal = parseInt(this.parentNode
                                      .getAttribute('transform')
                                      .split(',')[0]
                                      .slice(10));
          const bartip = barChartGroup.append('g')
                                        .attr('id', 'bartip');

          bartip.append('path')
                  .attr('d', () => {
                    if (groupXVal > 550) {
                      return `M${barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2} ${barYScale(d.avg)} l -50 -25 l -150 0`;
                    }
                    return `M${barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2} ${barYScale(d.avg)} l 50 -25 l 150 0`;
                  })
                  .attr('fill', 'none')
                  .attr('stroke', '#000000');

          bartip.append('text')
                  .attr('dx', () => {
                    if (groupXVal > 550) {
                      return barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2 - 196;
                    }
                    return barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2 + 52;
                  })
                  .attr('dy', barYScale(d.avg) - 27)
                  .text(`Average: $${d.avg}`);

          bartip.append('text')
                  .attr('dx', () => {
                    if (groupXVal > 550) {
                      return barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2 - 196;
                    }
                    return barX1Scale(d.title) + groupXVal + barX1Scale.bandwidth()/2 + 52;
                  })
                  .attr('dy', barYScale(d.avg) - 45)
                  .text(`Theaters: ${d.theaters}`)


        });

        bar.on('mouseout', function() {
          d3.select('#bartip').remove();
          d3.select(this).transition(tOut).attr('fill-opacity', 0.5);
        })

        /* ---------------------------- bar chart legend ---------------------------- */

        let barLegendUpdate = barLegend
                                .selectAll('.legend-entry')
                                .data(top5Keys, d => d + Math.random());

        barLegendUpdate.exit().remove();

        let barLegendEntry = barLegendUpdate.enter()
                                      .append('g')
                                        .attr('class', 'legend-entry');

        barLegendEntry.append('rect')
                              .attr('fill', (d,i) => colorScheme[i])
                              .attr('fill-opacity', 0.5)
                              .attr('width', 30)
                              .attr('height', 18)
                              .attr('x', 30)
                              .attr('y', (d, i) => i * 30);

        barLegendEntry.append('text')
                              .attr('fill', (d, i) => colorScheme[i])
                              .attr('text-anchor', 'end')
                              .attr('x', 10)
                              .attr('y', (d, i) => i * 30 + 15)
                              .text(d => d);

        barLegendEntry.on('mouseover', function(d, i) {
          d3.select(this.parentNode.previousSibling)
             .selectAll(`.bar-${i}`)
             .transition(tIn)
             .attr('fill-opacity', 1);

          let selectionn = d3.select(this.parentNode.previousSibling)
              .selectAll('.bar')
              .filter(function() {
                return this.classList[1] !== `bar-${i}`;
              })
              .transition(tIn)
              .attr('fill-opacity', 0);

        });

        barLegendEntry.on('mouseout', function(d, i) {
          d3.select(this.parentNode.previousSibling)
            .selectAll(`.bar`)
            .transition()
            .attr('fill-opacity', 0.5);
        });

      }

      tag.selectAndUpdateGraph = function(e) {
        axios.get(`/data/boxoffice/weekly/${e.target.value}`)
          .then((response) => {
            updateCharts(response.data);
          })
          .catch((err) => {
            console.log('error in update..', err);
          })
      }
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


  </script>
</data-menu>
