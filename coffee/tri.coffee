root = exports ? this

sin30 = Math.pow(3,1/2)/2
cos30 = 0.5

sin60 = sin30 * 2
cos60 = cos30 * 2

Triangles = () ->
  layout = 'top'
  parent = null
  svg = null
  points = null
  details = null
  comps = null
  images = null
  width = 800
  height = 520
  aspect = (width) / (height)
  user_id = -1
  paddingY = width * 0.01
  topR = width * 0.2
  midR = (topR * 2) * 0.25
  tiers = [{id: 1, x: width / 2, y: height / 5 + (topR / 4 + (paddingY * 3)), r: topR, index: 0},
           {id: 2, x: (midR * 3  - midR / 2 - 10), y: (height / 5 ) + (topR + (topR / 4) + (paddingY * 3)) + paddingY, r: midR, index:0},
           {id: 3, x: (midR * 2 - midR / 2 ), y: (height / 5) + (topR + (topR / 4) + (paddingY * 3)) + (midR * 1.60) + paddingY, r: midR, index:0}]

  compCord = {x: (width / 2) + (width / 4), y: midR , r: midR / 2}
  data = []
  allData = []
  compColors = []

  minRadius = 8
  maxRadius = topR - 20
  rScale = d3.scale.sqrt().range([minRadius, maxRadius])

  currentColor = null
  currentRecs = "match"
  

  tier = (i) ->
    if i == 0
      t = tiers[0]
    else if i > 0 and i < 6
      t = tiers[1]
    else
      t = tiers[2]
    t

  # x, y & r values for a triangle
  # depends on the index of the triangle
  # and if the triangle is flipped or not
  coords = (i,flip) ->
    t = tier(i)
    # TODO: don't modify tier inside coords
    t.index = t.index + 1
    c = {id:t.id, x:t.x, y:t.y, r: t.r}
    if c.id > 1
      c.x = (t.x) + ((midR - (midR / 8))  * t.index)
      if flip
        c.y = c.y - midR / 2
    c

  trianglePath = (r, flip) ->
    x = 0
    y = 0
    if flip
      "M#{x - r * sin30} #{y - r * cos30} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y + r} Z"
    else
      "M#{x} #{y - r} L #{x - r * sin30} #{y + r * cos30} L #{x + r * sin30} #{y + r * cos30} Z"

  diamondPath = (r, flip) ->
    x = 0
    y = 0
    if flip
      "M#{x - r * sin30} #{y - r * cos30} L #{x} #{y - r} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y} Z"
    else
      "M#{x} #{y} L #{x - r * cos30} #{y + r * sin30} l #{x + r * cos30 } #{y + r  } L #{x + r * cos30} #{y + r * sin30} Z"
      # "M#{x - r * sin30} #{y - r * cos30} L #{x} #{y - r} L #{x + r * sin30} #{y - r * cos30} L #{x} #{y} Z"

  compPath = (r, flip) ->
    x = 0
    y = 0
    if flip
      "M#{x} #{y} L #{x - r} #{y} L #{x} #{y + r} Z"
    else
      "M#{x} #{y} L #{x - r} #{y}  L #{x} #{y - r} Z"

  flipFor = (d,i) ->
    flip = false
    if i > 5
      flip = (i % 2 == 1)
    else if i > 0
      flip = (i % 2 == 0)
    flip

  showImages = (d) ->
    color_id = d.color_id
    if !color_id
      color_id = d.id
    jpegs = []
    [0..3].forEach (i) ->
      jpegs.push("img/style_imgs/#{color_id}_#{i}.jpg")

    img = images.selectAll('.img').data(jpegs)

    img.enter().append("image")
      .attr("xlink:href", (d) -> d)
      .attr("width", 75)
      .attr("height", 115)
      .attr("x", (width - 75) - 40)
      .attr("y", (d,i) -> (115 + 10) * i)


  showDetails = (d) ->
    # xcord = 0
    # text = details.append("text")
    #   .attr("class", "detail_text")
    #   .attr("x", width - 40)
    #   .attr("y", d.coords.y)
    #   .attr("dy", 5)
    #   .attr("opacity", 1e-6)
    #   .attr("fill" ,() -> d3.hsl(d.rgb_string).darker(1))
    #   .attr("text-anchor", "end")
    #   .text(d.name)
    #   .each((d) -> xcord = this.getBBox().x)

    xcord = (width - 40) - 20
    path = details.append("path")
      .attr("d", "M #{d.coords.x} #{d.coords.y} L #{d.coords.x} #{d.coords.y}")
    path.transition().duration(200)
      .attr("d", "M #{d.coords.x} #{d.coords.y} L #{xcord - 10} #{d.coords.y}")
    # text.transition().duration(200)
    #   .delay(100)
    #   .attr("opacity", 1)


  hideDetails = (d) ->
    details.select("path").remove()
    images.selectAll(".img").remove()
    # details.select("text").remove()

  mouseover = (d,i) ->
    triG = d3.select(this)
    triG.moveToFront()
    tri = triG.select(".triangle_path")
    tri
      .attr("stroke-width", 3)
      .attr("stroke", (d) -> d3.hsl(tri.attr("fill")).darker(1))
    showDetails(d)
    showImages(d)

  mouseout = (d,i) ->
    triG = d3.select(this)
    tri = triG.select(".triangle_path")
    tri
      .attr("stroke-width", 0)
    hideDetails(d)

  updateRecs = (colorId, recType) ->
    jpegs = []
    [0..3].forEach (i) ->
      jpegs.push("img/style_imgs/#{colorId}_#{i}.jpg")

    d3.select("#rec_content").html("")

    rec = d3.select("#rec_content").selectAll(".rec")
      .data(jpegs).enter()
      .append("div")
      .attr("class", "rec col-md-3")
      .append("img")
      .attr("class", "center-block")
      .attr("src", (d) -> d)

  showRecs = (d,i) ->
    colorId = d.color_id
    if !colorId
      colorId = d.id
    currentColor = colorId
    updateRecs(currentColor, currentRecs)

  getUser = (rawData, userId) ->
    if userId < 0
      userId = rawData[0].id
    data = allData.filter (d) -> d.id == userId
    data = data[0]
    data

  filterData = (rawData) ->
    console.log(rawData)
    # data = data.sort (a,b) -> +a.rank - +b.rank
    data = rawData.colors.sort (a,b) -> b.weighted_count - a.weighted_count
    data = data.filter (d,i) -> i < 13
    if data.length < 6
      data = data.filter (d,i) -> i < 1
    if data.length < 12
      data = data.filter (d,i) -> i < 6
    # data = data.sort (a,b) -> b.count - a.count
    data


  setupData = (data) ->
    rScale.domain(d3.extent(data, (d) -> d.weighted_count))
    data.forEach (d,i) ->
      d.flip = flipFor(d,i)
      d.tier = tier(i)
      d.coords = coords(i, d.flip)
      d.amount_r = rScale(d.weighted_count)

  getComps = (rawData) ->
    comps = rawData.complementary_colors
    # comps = comps.filter (c,i) -> i < 5
    comps.forEach (c, i) ->
      c.coords = {'xR':compCord.x, 'yR':compCord.y, 'r': compCord.r}
      if i == 0
        c.coords.x = c.coords.xR + (c.coords.r / 2)
        c.coords.y = c.coords.yR 
        c.flip = true
      if i == 1
        c.coords.x = c.coords.xR 
        c.coords.y = c.coords.yR - (c.coords.r)
        # c.coords.x = c.coords.x + c.coords.r
        c.flip = false
      if i == 2
        c.coords.x = c.coords.xR - (c.coords.r / 2)
        c.coords.y = c.coords.yR 
        # c.coords.x = c.coords.x + c.coords.r
        # c.coords.y = c.coords.y + c.coords.r
        c.flip = true
      if i == 3
        c.coords.x = c.coords.xR 
        c.coords.y = c.coords.yR + c.coords.r
        # c.coords.x = c.coords.x - c.coords.r
        # c.coords.y = c.coords.y + c.coords.r
        c.flip = false

    comps

  chart = (selection) ->
    selection.each (rawData) ->

      allData = rawData
      rawData = getUser(allData, user_id)
      compColors = getComps(rawData)
      data = filterData(rawData)
      setupData(data)

      parent = $(this)
      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      # help to maintain size in mobile.
      svg.attr("viewBox", "0 0 #{width} #{height}")
      svg.attr("preserveAspectRatio", "xMidYMid")
      
      chart.resize()

      g = svg.select("g")

      g.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("stroke-fill", "none")
        .attr("fill", "none")

      points = g.append("g").attr("id", "vis_triangles")
      comps = g.append("g").attr("id", "vis_comps")
      details = g.append("g").attr("id", "vis_details")
      images = g.append("g").attr("id", "vis_images")
      comps.append("text")
        .attr("text-anchor", "end")
        .attr("x", compCord.x - (compCord.r / 2))
        .attr("y", compCord.y - (compCord.r * 1.5) )
        # .attr("dy", -20)
        .attr("dx", 0)
        .attr("class", "comp_title")
        .text("Complementary Colors")


  updateComps = () ->
    p = comps.selectAll(".triangle")
      .data(compColors, (d) -> d.name)

    gEnter = p.enter()
      .append("g")
      .attr("class", "triangle")
      .attr("transform", (d,i) -> "translate(#{d.coords.xR},#{d.coords.yR})rotate(#{90 + (90 * i)} #{0} #{0})")
      # .attr("transform", (d,i) -> "translate(#{d.coords.x},#{d.coords.y})")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", showRecs)

    t = gEnter.append("path")
      .attr("class", "triangle_path")
      .attr("d", (d, i) -> diamondPath(d.coords.r, d.flip))
    t.attr("fill", (d) -> d.rgb_string)

  update = () ->
    # data = filterData(allData, user_id)
    updateComps()

    p = points.selectAll(".triangle")
      .data(data, (d) -> d.name)

    gEnter = p.enter()
      .append("g")
      .attr("class", "triangle")
      .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})")
      .on("mouseover", mouseover)
      .on("mouseout", mouseout)
      .on("click", showRecs)

    t = gEnter.append("path")
      .attr("class", "triangle_path")
      .attr("d", (d, i) -> trianglePath(d.coords.r, d.flip))

    t.attr("fill", (d) -> d.rgb_string)

    if layout == "top"
      p.transition()
        .duration(1000)
        .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})rotate(#{if d.flip then 120 else 120})")
      p.select(".triangle_path").transition()
        .duration(1000)
        .attr("d", (d, i) -> trianglePath(d.coords.r, d.flip))
    else
      p.transition()
        .duration(1000)
        .attr("transform", (d) -> "translate(#{d.coords.x},#{d.coords.y})rotate(#{if d.flip then 60 else 0})")

      p.select(".triangle_path").transition()
        .duration(1000)
        .attr("d", (d, i) -> trianglePath(d.amount_r, d.flip))

  setLayout = (newLayout) ->
    layout = newLayout
    if layout == "top"
      1 + 1
    else if layout == "amounts"
      1 + 1
  
  chart.toggleLayout = (newLayout) ->
    setLayout(newLayout)
    update()

  chart.toggleRecs = (newRec) ->
    currentRecs = newRec
    updateRecs(currentColor, currentRecs)

  # attempt to make vis responsive in design
  # http://stackoverflow.com/questions/9400615/whats-the-best-way-to-make-a-d3-js-visualisation-layout-responsive
  chart.resize = () ->
    targetWidth = parent.width()
    svg.attr("width", targetWidth)
    svg.attr("height", Math.round(targetWidth / aspect))


  chart.start = () ->
    update()

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)

openSearch = (e) ->
  $('#search_user').show('slide').select()
  $('#change_nav_link').hide()
  d3.event.preventDefault()

hideSearch = () ->
  $('#search_user').hide()
  $('#change_nav_link').show()

changeUser = (user) ->
  id = root.all.get(user)
  if id
    location.replace("#" + encodeURIComponent(id))
  # d3.event.preventDefault()
  return user

setupSearch = (all) ->
  root.all = d3.map()
  all.forEach (a,i) ->
    root.all.set(a.id, a.id)

  users = root.all.keys()
  # console.log(users)
  $('#search_user').typeahead({local:users, updater:changeUser})


activateButton = (parent, id) ->
  d3.select(parent).selectAll(".g-menu-button").classed("g-menu-button-selected", false)
  d3.select("##{id}").classed("g-menu-button-selected", true)

$ ->
  d3.select("#change_nav_link")
    .on("click", openSearch)


  user_id = decodeURIComponent(location.hash.substring(1)).trim()

  if !user_id
    user_id = '10181881329'


  plot = Triangles()
  plot.id(user_id)

  d3.selectAll("#g-menu-style .g-menu-button").on "click", (d) ->
    id = d3.select(this).attr("id")
    activateButton("#g-menu-style", id)
    newLayout = id.split("-")[2]
    plot.toggleLayout(newLayout)

  d3.selectAll("#g-menu-recs .g-menu-button").on "click", (d) ->
    id = d3.select(this).attr("id")
    activateButton("#g-menu-recs", id)
    newRecs = id.split("-")[2]
    plot.toggleRecs(newRecs)
    
  display = (error, data) ->
    setupSearch(data)
    plotData("#vis", data, plot)
    plot.start()

  queue()
    # .defer(d3.tsv, "data/color_palettes_rgb.txt")
    .defer(d3.json, "data/user_colors.json")
    .await(display)

  updateActive = (new_id) ->
    user_id = new_id
    plot.updateDisplay(user_id)

  hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  resize = () ->
    plot.resize()


  d3.select(window)
    .on("hashchange", hashchange)

  d3.select(window)
    .on("resize", resize)

  socialData = {"title":"My Color Trends -  the colors of my Nordstrom wardrobe visualized!", "source":"Nordstrom"}
  Socialighter.sharing(socialData)

  # trigger screenshot now
  config = {'key':user_id}
  BanquoClient.getScreenshot(config)

  $('#link').on "click", (e) ->
    console.log(BanquoClient.screenshotUrl())
    e.preventDefault()
