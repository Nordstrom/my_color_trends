
$ ->

  display = (error, data) ->
    data.sort  (a,b) -> a.last_name.localeCompare(b.last_name)
    data.forEach (d) ->
      d.name = "#{d.first_name.split("")[0]} #{d.last_name.split('')[0]}"
    all = d3.select("#all")
    users = all.selectAll(".user")
      .data(data).enter()
      .append("div")
      .attr("class", "user")
      .append("a")
      .attr("href", (d) -> "index.html##{d.id}")
      .attr("class", "button")
      .append("span")
      .text (d) -> "#{d.first_name.split("")[0]} #{d.last_name.split("")[0]}"

    $('.typeahead').typeahead({name: 'names',local:data,valueKey:'name', limit: 5})

    $('.typeahead').on 'typeahead:selected', (object, d) ->
      window.location.href = "index.html##{d.id}"
      # console.log(object)

  queue()
    # .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .defer(d3.json, "data/color_data/all.json")
    .await(display)
