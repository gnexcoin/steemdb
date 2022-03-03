<script>
  d3.json("/api/supply").get(function(error, rows) {
    var data = rows;
    var dataset = new Plottable.Dataset(data);
    var dayOffset = (24*60*60*1000); // 1 day
    var today = new Date();
    var xScale = new Plottable.Scales.Time()
        .domain([
          new Date(today.getTime() - dayOffset * 45),
          new Date(today.getTime() - dayOffset)
        ]);

    var xAxis = new Plottable.Axes.Time(xScale, "bottom");
    var yScale = new Plottable.Scales.Linear();
    var yScale2 = new Plottable.Scales.Linear();
    var yAxis = new Plottable.Axes.Numeric(yScale, "left");
    var yAxis2 = new Plottable.Axes.Numeric(yScale2, "right");

    var pDate = function(d) {
      var dateString = d._id.year + "/" + d._id.month + "/" + d._id.day;
      return new Date(dateString);
    };

    var pGBD = function(d) { return +d.sbd; };
    var pGNEX = function(d) { return +d.steem; };
    var pGP = function(d) { return +d.sp; };

    // Chart SBD
    var lGBD = new Plottable.Plots.Line();
    lGBD.addDataset(dataset);
    lGBD.x(pDate, xScale)
         .y(pGBD, yScale)
         .attr("stroke", "#EF320B")
         ;

    // Chart Replies
    var lGNEX = new Plottable.Plots.Line();
    lGNEX.addDataset(dataset);
    lGNEX.x(pDate, xScale)
             .y(pGNEX, yScale)
             .attr("stroke", "#0A46D6")
             ;

    // Chart Votes
    var lGP = new Plottable.Plots.Line();
    lGP.addDataset(dataset);
    lGP.x(pDate, xScale)
             .y(pGP, yScale2)
             .attr("stroke", "#58DC0A");

    var cs = new Plottable.Scales.Color();
    cs.range(["#EF320B", "#0A46D6", "#58DC0A", "#58DC0A"]);
    cs.domain(["GBD","GNEX","GNEX POWER"]);
    var legend = new Plottable.Components.Legend(cs);
    legend.maxEntriesPerRow(3);

    var squareFactory = Plottable.SymbolFactories.square();
    var circleFactory = Plottable.SymbolFactories.circle();

    legend.symbol(function (d, i) {
      if(i === 0) { return squareFactory; }
      else { return circleFactory; }
    });

    legend.maxEntriesPerRow(5)

    var yLabel = new Plottable.Components.AxisLabel("", "270");
    var xLabel = new Plottable.Components.TitleLabel("Supply History", "0");

    var plots = new Plottable.Components.Group([lGBD, lGNEX, lGP]);
    var table = new Plottable.Components.Table([
      [null, null, xLabel, null, null],
      [null, null, legend, null, null],
      [yLabel, yAxis, plots],
      [null, null, xAxis, null, null]
    ]);

    table.renderTo("svg#supply");
  });
</script>
