console.log "d3 is started :)"

dataArray = [200, 800, 1000]

canvas = d3.select("body")
  .append("svg")
  .attr("height", 1000)
  .attr("width", 1000)

bars = canvas.selectAll "rect"
  .data dataArray
  .enter()
  .append "rect"
  .attr "width", (bar)->
  	bar
  .attr "height", 50
  .attr "y", (bar, i)->
  	i * 100