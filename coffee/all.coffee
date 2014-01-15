
$ ->

  display = (error, data) ->
    all = d3.select("#all")
    users = all.selectAll(".user")
      .data(data).enter()
      .append("div")
      .attr("class", "user")
      .append("a")
      .attr("href", (d) -> "index.html##{d.id}")
      .attr("class", "button")
      .append("span")
      .text (d) -> "#{d.first_name} #{d.last_name}"

  queue()
    # .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .defer(d3.json, "data/color_data/all.json")
    .await(display)
