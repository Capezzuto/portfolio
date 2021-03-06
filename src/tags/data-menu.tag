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

  function configureTransition(t, dur, del) {
    return t.duration(dur).delay(del);
  }

    tag.on('mount', function() {

      const svg = d3.select('.container')
      .append('svg')
      .attr('height', fullHeight)
      .attr('width', fullWidth)
      .call(responsivefy);

      const tDur = 400;

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
        // console.log('data ===', data);

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
              }),
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

        const flatArea = d3.area()
                            .x((d, i) => d3.scaleLinear().domain([0, 6]).range([0, areaWidth])(i))
                            .y0(areaYScale(0))
                            .y1(d => areaYScale(0));

        let areaUpdate = areaChartGroup
                          .selectAll('.area')
                          .data(top5, d => d.total);

        areaUpdate.exit()
                    .call(removeAreaTransition, tDur)
                    .transition()
                    .delay(tDur)
                    .remove();

        areaUpdate.enter()
                    .append('path')
                      .attr('class', 'area')
                      .attr('fill-opacity', 0.05)
                      .attr('fill', (d, i) => colorScheme[i])
                      .attr('stroke', (d, i) => colorScheme[i])
                      .attr('d', d => flatArea(d.values))
                      .on('mouseover', handleAreaMouseover)
                      .on('mouseout', handleAreaMouseout)
                      .call(addAreaTransition, tDur, areaUpdate.exit().size() ? tDur: 0);

        function handleAreaMouseover(d, i) {
          let title = d.title;

          d3.select(this.parentNode)
            .selectAll('.area')
            .filter((d, i) => d.title !== title)
            .call(muteOtherAreas, 250);

          d3.select(this.parentNode)
            .selectAll('.points')
            .filter((d, i) => d.title !== title)
            .call(muteOtherPoints, 250);

          d3.select(this)
            .call(highlightArea, 250);

          d3.select('#legend')
            .selectAll(`g:nth-child(${i+1})`)
            .call(highlightEntry, 250);
        }

        function handleAreaMouseout(d, i) {
          let title = d.title;

          d3.select(this.parentNode)
            .selectAll('.area')
            .call(resetAllAreas, 100);

          d3.select(this.parentNode)
            .selectAll('circle')
            .call(resetAllPoints, 100);

          d3.select('#legend')
            .selectAll(`g:nth-child(${i+1})`)
            .call(resetEntry, 100);
        }

        /* -------------------- Area Transition Functions -------------------- */

        function addAreaTransition(areaBlock, duration, delay) {
          areaBlock.transition('addAreaTransition')
              .duration(duration)
              .delay(delay)
              .attr('d', d => area(d.values))
        }

        function removeAreaTransition(area, duration) {
          area.transition('removeAreaTransition')
              .duration(duration)
              .attr('d', d => flatArea(d.values))
        }

        function muteOtherAreas(area, duration) {
          area.transition('muteOtherAreas')
              .duration(duration)
              .attr('fill-opacity', 0)
              .attr('stroke-opacity', 0.1);
        }

        // Is this function more performant than muteOtherPoints?
        // To run this function, you would have to .selectAll('circle') after the .filter but before the .call
        // function muteOtherCircles(circle, duration) {
        //   circle.transition('muteOtherCircles')
        //         .duration(duration)
        //         .attr('fill-opacity', 0.1)
        // }

        function muteOtherPoints(pointGroup, duration) {
          pointGroup.each(function() {
            d3.select(this)
              .selectAll('circle')
              .transition('muteOtherPoints')
              .duration(duration)
              .attr('fill-opacity', 0.3);
          })
        }

        function highlightArea(area, duration) {
          area.transition('highlightArea')
              .duration(duration)
              .attr('fill-opacity', 0.3);
        }

        function highlightEntry(entry, duration) {
          entry.transition('highlightEntry')
                .duration(duration)
                .attr('opacity', 1);
        }

        function resetAllAreas(area, duration) {
          area.transition('resetAllAreas')
              .duration(duration)
              .attr('fill-opacity', 0.05)
              .attr('stroke-opacity', 1);
        }

        function resetAllPoints(point, duration) {
          point.transition('resetAllPoints')
                .duration(duration)
                .attr('fill-opacity', 1);
        }

        function resetEntry(entry, duration) {
          entry.transition('resetEntry')
                .duration(duration)
                .attr('opacity', 0.5);
        }

        /* ------------------------- scatterplot data ------------------------- */

        let pointsGroupUpdate = areaChartGroup
                                  .selectAll('.points')
                                  .data(top5, d => d.total);

        let pointsUpdate = pointsGroupUpdate
                            .data(top5, d => d.total).enter()
                            .append('g')
                              .attr('class', 'points')
                              .selectAll('circle')
                              .data(d => d.values, d => d.gross);

        pointsGroupUpdate.exit()
                          .each(function(d, i) {
                            d3.select(this)
                              .selectAll('circle')
                              .call(removePointsTransition, tDur - 200, 200);
                          })
                          .transition()
                          .call(configureTransition, 0, tDur)
                          .remove();

        let point = pointsUpdate.enter()
                      .append('circle')
                        .attr('r', 3)
                        .attr('cx', d => areaXScale(d.date))
                        .attr('cy', areaHeight)
                        .attr('fill', function() {
                          let i = d3.select(this.parentNode).data()[0].rank - 1;
                          return colorScheme[i];
                        })
                        .attr('stroke', function() {
                          let i = d3.select(this.parentNode).data()[0].rank - 1;
                          return colorScheme[i];
                        })
                        .attr('stroke-width', 20)
                        .attr('stroke-opacity', 0)
                        .on('mouseover', handlePointMouseover)
                        .on('mouseout', handlePointMouseout)

        point.call(addPointsTransition, tDur, pointsGroupUpdate.exit().size() ? tDur : 0)

        function handlePointMouseover(d, i) {
          const title = d3.select(this.parentNode).data()[0].title;
          const { date, gross } = d;
          const xCoord = areaXScale(date);
          const tooltip = pointsGroupUpdate
                            .enter()
                            .append('g')
                            .attr('id', 'tooltip');

          d3.select(this)
              .attr('fill-opacity', 0)
              .attr('stroke-opacity', 1)

          d3.selectAll('.area')
              .filter(d => d.title !== title)
              .call(muteAreasPointTransition, 250)

          d3.selectAll('.points')
            .filter(d => d.title !== title)
            .selectAll('circle')
            .attr('fill-opacity', 0.1)

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
        }

        function handlePointMouseout(d, i) {
          d3.select(this)
              .attr('fill-opacity', 1)
              .attr('stroke-opacity', 0)
              .attr('stroke-width', 20);

          d3.selectAll('circle')
            .attr('fill-opacity', 1);

          d3.selectAll('.area')
            .call(resetAreasPointTransition, 100);

          if (d3.select('#tooltip').nodes().length) {
            d3.selectAll('#tooltip').remove()
          }
        }

      /* ------------------- Points transition functions ------------------- */

      function addPointsTransition(point, duration, delay) {
        point.transition('addPointsTransition')
              .duration(duration)
              .delay(delay)
              .attr('cy', d => areaYScale(d.gross));
      }

      function removePointsTransition(point, duration, delay) {
        point.transition('removePointsTransition')
              .duration(duration)
              .delay(delay)
              .ease(d3.easeCubicIn)
              .attr('cy', areaHeight);
      }

      function muteAreasPointTransition(area, duration) {
        area.transition('muteAreasPointTransition')
            .duration(duration)
            .attr('fill-opacity', 0)
            .attr('stroke-opacity', 0.1);
      }

      function resetAreasPointTransition(area, duration) {
        area.transition('resetAreasPointTransition')
            .duration(duration)
            .attr('fill-opacity', 0.05)
            .attr('stroke-opacity', 1);
      }

        /* ---------------------------- legend data ---------------------------- */

        let legendUpdate = legend.selectAll('.legend-entry')
                                  .data(top5, d => d.total);

        legendUpdate.exit().remove();

        let legendEntry = legendUpdate.enter()
                            .append('g')
                              .attr('class', 'legend-entry')
                              .attr('opacity', 0.5)
                              .on('mouseover', handleLegendMouseover)
                              .on('mouseout', handleLegendMouseout);

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

        function handleLegendMouseover(d, i) {
          let title = d.title;

          d3.select(this.parentNode.previousSibling)
            .selectAll('.area')
            .filter(d => d.title !== title)
            .call(muteOtherAreas, 250);

          d3.select(this.parentNode.previousSibling)
            .selectAll('.points')
            .filter(d => d.title !== title)
            .call(muteOtherPoints, 250)

          d3.select(this)
            .call(highlightEntry, 250);

          d3.selectAll(`.area:nth-child(${i+3})`)
            .call(highlightArea, 250);
        }

        function handleLegendMouseout(d, i) {
          let title = d.title;

          d3.select(this.parentNode.previousSibling)
            .selectAll('.area')
            .call(resetAllAreas, 100);

          d3.select(this.parentNode.previousSibling)
            .selectAll('circle')
            .call(resetAllPoints, 100);

          d3.select(this)
            .call(resetEntry, 100);
        }

        /*--------------- LegendEntry transition functions -----------------*/

        // The following functions are found in the area transition functions:
        // function muteOtherAreas(area, duration)
        // function resetAllAreas(area, duration)
        // function muteOtherPoints(pointGroup, duration)
        // function resetAllPoints(point, duration)
        // function highlightEntry(entry, duration)
        // function resetEntry(entry, duration) {
        // function highlightArea(area, duration)

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
                  .on('mouseover', handlePieMouseover)
                  .on('mouseout', handlePieMouseout)
                  .attr('fill', (d, i) => colorScheme[i])
                  .attr('fill-opacity', 0.5)
                  .transition()
                  .duration(tDur)
                  .attrTween('d', tweenPie);

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

        function tweenPie(el) {
          el.innerRadius = 0;
          el.outerRadius = 0;
          let interpolate = d3.interpolate({ startAngle: 0, endAngle: 0 }, el);
          return function(t) { return arc(interpolate(t)) };
        }

        function handlePieMouseover(d, i) {
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
            .call(transformSlice, 250);

          function transformSlice(path, duration) {
            path.transition('transformSlice')
                .duration(duration)
                .style('transform', 'scale(1.1)')
                .style('fill-opacity', 1);
          }
        }

        function handlePieMouseout(d, i) {
          d3.select(this)
            .call(transformSlice, 100);

          if (d3.select('#pietip').nodes().length) {
            pieChartGroup.select('#pietip').remove()
          }

          function transformSlice(path, duration) {
            path.transition('transformSlice')
                .duration(duration)
                .style('transform', 'scale(1)')
                .style('fill-opacity', 0.5);
          }
        }

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

        barGroupUpdate.exit()
                      .each(function(d, i) {
                        let timeMod = i * 50;
                        d3.select(this)
                          .selectAll('rect')
                          .call(removeBarGroupTransition, tDur, timeMod);
                      })
                      .transition()
                      .call(configureTransition, 0, tDur + 250)
                      .remove();

        // barUpdate.exit().remove();

        let bar = barUpdate.enter()
                    .append('rect')
                      .attr('class', (d, i) => `bar bar-${i}`)
                      .attr('x', d => barX1Scale(d.title))
                      .attr('y', barHeight)
                      .attr('width', barX1Scale.bandwidth())
                      .attr('height', 0)
                      .attr('fill', (d, i) => colorScheme[i])
                      .attr('fill-opacity', 0.5)
                      .on('mouseover', handleBarMouseover)
                      .on('mouseout', handleBarMouseout);

        bar.call(addBarGroupTransition, tDur, barGroupUpdate.exit().size() ? tDur : 0)

        function handleBarMouseover(d, i) {
          const groupXVal = parseInt(this.parentNode
            .getAttribute('transform')
            .split(',')[0]
            .slice(10));
          const bartip = barChartGroup.append('g')
            .attr('id', 'bartip');

          d3.select(this)
            .call(highlightBarMouseover, 250);

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
        }

        function handleBarMouseout() {
          d3.select('#bartip').remove();
          d3.select(this)
            .call(resetBarMouseout, 100);
        }

        /* ---------------------- Bar Chart Transition Functions ---------------------- */

        function addBarGroupTransition(barGroup, duration, delay) {
          barGroup.transition('addBarGroupTransition')
                  .duration(duration)
                  .delay(delay)
                  .attr('y', d => barYScale(d.avg))
                  .attr('height', d => barHeight - barYScale(d.avg));
        }

        function removeBarGroupTransition(barGroup, duration, delay) {
          barGroup.transition('removeBarGroupTransition')
                  .duration(duration)
                  .delay(delay)
                  .attr('y', barHeight)
                  .attr('height', 0);
        }

        function highlightBarMouseover(bar, duration) {
          bar.transition('highlightBarMouseover')
              .duration(duration)
              .attr('fill-opacity', 1);
        }

        function resetBarMouseout(bar, duration) {
          bar.transition('resetBarMouseout')
              .duration(duration)
              .attr('fill-opacity', 0.5);
        }

        /* ---------------------------- bar chart legend ---------------------------- */

        let barLegendUpdate = barLegend
                                .selectAll('.legend-entry')
                                .data(top5Keys, d => d + Math.random());

        barLegendUpdate.exit().remove();

        let barLegendEntry = barLegendUpdate.enter()
                                      .append('g')
                                        .attr('class', 'legend-entry')
                                        .on('mouseover', handleBarLegendMouseover)
                                        .on('mouseout', handleBarLegendMouseout);

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


        function handleBarLegendMouseover(d, i) {
          console.log('over');
          d3.select(this.parentNode.previousSibling)
              .selectAll(`.bar-${i}`)
              .call(highlightBarsTransition, 250);

          d3.select(this.parentNode.previousSibling)
              .selectAll('.bar')
              .filter(function() {
                return this.classList[1] !== `bar-${i}`;
              })
              .call(muteOtherBarsTransition, 250);
        }

        function handleBarLegendMouseout(d, i) {
          console.log('out');
          d3.select(this.parentNode.previousSibling)
            .selectAll('.bar')
            .call(resetAllBarsTransition, 200);
        }

        /* --------------- Bar Legend Transition Functions --------------- */
        function highlightBarsTransition(bar, duration) {
          bar.transition('highlightBarsTransition')
              .duration(duration)
              .attr('fill-opacity', 1);
        }

        function muteOtherBarsTransition(bar, duration) {
          bar.transition('muteOtherBarsTransition')
              .duration(duration)
              .attr('fill-opacity', 0);
        }

        function resetAllBarsTransition(bar, duration) {
          console.log('reset');
          bar.transition('resetAllBarsTransition')
              .duration(duration)
              .attr('fill-opacity', 0.5);
        }

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
