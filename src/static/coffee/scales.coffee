console.log "scales run"

dataArray = [20, 80, 100, 120]

height = 1000
width = 1000

widthScale = d3.scale.linear()
  .domain [0, 120]
  .range [0, width]

color = d3.scale.linear()
  .domain [0, 120]
  .range ["red", "blue"]

canvas = d3.select("body")
  .append("svg")
  .attr("height", height)
  .attr("width", width)

bars = canvas.selectAll "rect"
  .data dataArray
  .enter()
  .append "rect"
  .attr "width", (bar)->
  	widthScale bar
  .attr "height", 50
  .attr "y", (bar, i)->
  	i * 100
  .attr "fill", (bar)->
  	color bar