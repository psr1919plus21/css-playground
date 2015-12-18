console.log "tilt effect"

###*
# tiltfx.js
# http://www.codrops.com
#
# Licensed under the MIT license.
# http://www.opensource.org/licenses/mit-license.php
# 
# Copyright 2015, Codrops
# http://www.codrops.com
###

do (window) ->

  extend = (a, b) ->
    for key of b
      if b.hasOwnProperty(key)
        a[key] = b[key]
    a

  # from http://www.quirksmode.org/js/events_properties.html#position

  getMousePos = (e) ->
    `var e`
    posx = 0
    posy = 0
    if !e
      e = window.event
    if e.pageX or e.pageY
      posx = e.pageX
      posy = e.pageY
    else if e.clientX or e.clientY
      posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
      posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
    {
      x: posx
      y: posy
    }

  # from http://www.sberry.me/articles/javascript-event-throttling-debouncing

  throttle = (fn, delay) ->
    allowSample = true
    (e) ->
      if allowSample
        allowSample = false
        setTimeout (->
          allowSample = true
          return
        ), delay
        fn e
      return

  ###*************************************************************************###

  ###*
  # TiltFx fn
  ###

  TiltFx = (el, options) ->
    @el = el
    @options = extend({}, @options)
    extend @options, options
    @_init()
    @_initEvents()
    return

  init = ->
    # search for imgs with the class "tilt-effect"
    [].slice.call(document.querySelectorAll('img.tilt-effect')).forEach (img) ->
      new TiltFx(img, JSON.parse(img.getAttribute('data-tilt-options')))
      return
    return

  'use strict'

  ###*
  # **************************************************************************
  # utils
  # **************************************************************************
  ###

  # from https://gist.github.com/desandro/1866474
  lastTime = 0
  prefixes = 'webkit moz ms o'.split(' ')
  # get unprefixed rAF and cAF, if present
  requestAnimationFrame = window.requestAnimationFrame
  cancelAnimationFrame = window.cancelAnimationFrame
  # loop through vendor prefixes and get prefixed rAF and cAF
  prefix = undefined
  i = 0
  while i < prefixes.length
    if requestAnimationFrame and cancelAnimationFrame
      break
    prefix = prefixes[i]
    requestAnimationFrame = requestAnimationFrame or window[prefix + 'RequestAnimationFrame']
    cancelAnimationFrame = cancelAnimationFrame or window[prefix + 'CancelAnimationFrame'] or window[prefix + 'CancelRequestAnimationFrame']
    i++
  # fallback to setTimeout and clearTimeout if either request/cancel is not supported
  if !requestAnimationFrame or !cancelAnimationFrame

    requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

    cancelAnimationFrame = (id) ->
      window.clearTimeout id
      return

  ###*
  # TiltFx options.
  ###

  TiltFx::options =
    extraImgs: 2
    opacity: 0.7
    bgfixed: true
    movement:
      perspective: 1000
      translateX: -10
      translateY: -10
      translateZ: 20
      rotateX: 2
      rotateY: 2
      rotateZ: 0

  ###*
  # Initialize: build the necessary structure for the image elements and replace it with the HTML img element.
  ###

  TiltFx::_init = ->
    `var i`
    @tiltWrapper = document.createElement('div')
    @tiltWrapper.className = 'tilt'
    # main image element.
    @tiltImgBack = document.createElement('div')
    @tiltImgBack.className = 'tilt__back'
    @tiltImgBack.style.backgroundImage = 'url(' + @el.src + ')'
    @tiltWrapper.appendChild @tiltImgBack
    # image elements limit.
    if @options.extraImgs < 1
      @options.extraImgs = 1
    else if @options.extraImgs > 5
      @options.extraImgs = 5
    if !@options.movement.perspective
      @options.movement.perspective = 0
    # add the extra image elements.
    @imgElems = []
    i = 0
    while i < @options.extraImgs
      el = document.createElement('div')
      el.className = 'tilt__front'
      el.style.backgroundImage = 'url(' + @el.src + ')'
      el.style.opacity = @options.opacity
      @tiltWrapper.appendChild el
      @imgElems.push el
      ++i
    if !@options.bgfixed
      @imgElems.push @tiltImgBack
      ++@options.extraImgs
    # add it to the DOM and remove original img element.
    @el.parentNode.insertBefore @tiltWrapper, @el
    @el.parentNode.removeChild @el
    # tiltWrapper properties: width/height/left/top
    @view =
      width: @tiltWrapper.offsetWidth
      height: @tiltWrapper.offsetHeight
    return

  ###*
  # Initialize the events on the main wrapper.
  ###

  TiltFx::_initEvents = ->
    self = this
    moveOpts = self.options.movement
    # mousemove event..
    @tiltWrapper.addEventListener 'mousemove', (ev) ->
      requestAnimationFrame ->
        `var i`
        # mouse position relative to the document.
        mousepos = getMousePos(ev)
        docScrolls = 
          left: document.body.scrollLeft + document.documentElement.scrollLeft
          top: document.body.scrollTop + document.documentElement.scrollTop
        bounds = self.tiltWrapper.getBoundingClientRect()
        relmousepos = 
          x: mousepos.x - (bounds.left) - (docScrolls.left)
          y: mousepos.y - (bounds.top) - (docScrolls.top)
        # configure the movement for each image element.
        i = 0
        len = self.imgElems.length
        while i < len
          el = self.imgElems[i]
          rotX = if moveOpts.rotateX then 2 * (i + 1) * moveOpts.rotateX / self.options.extraImgs / self.view.height * relmousepos.y - ((i + 1) * moveOpts.rotateX / self.options.extraImgs) else 0
          rotY = if moveOpts.rotateY then 2 * (i + 1) * moveOpts.rotateY / self.options.extraImgs / self.view.width * relmousepos.x - ((i + 1) * moveOpts.rotateY / self.options.extraImgs) else 0
          rotZ = if moveOpts.rotateZ then 2 * (i + 1) * moveOpts.rotateZ / self.options.extraImgs / self.view.width * relmousepos.x - ((i + 1) * moveOpts.rotateZ / self.options.extraImgs) else 0
          transX = if moveOpts.translateX then 2 * (i + 1) * moveOpts.translateX / self.options.extraImgs / self.view.width * relmousepos.x - ((i + 1) * moveOpts.translateX / self.options.extraImgs) else 0
          transY = if moveOpts.translateY then 2 * (i + 1) * moveOpts.translateY / self.options.extraImgs / self.view.height * relmousepos.y - ((i + 1) * moveOpts.translateY / self.options.extraImgs) else 0
          transZ = if moveOpts.translateZ then 2 * (i + 1) * moveOpts.translateZ / self.options.extraImgs / self.view.height * relmousepos.y - ((i + 1) * moveOpts.translateZ / self.options.extraImgs) else 0
          el.style.WebkitTransform = 'perspective(' + moveOpts.perspective + 'px) translate3d(' + transX + 'px,' + transY + 'px,' + transZ + 'px) rotate3d(1,0,0,' + rotX + 'deg) rotate3d(0,1,0,' + rotY + 'deg) rotate3d(0,0,1,' + rotZ + 'deg)'
          el.style.transform = 'perspective(' + moveOpts.perspective + 'px) translate3d(' + transX + 'px,' + transY + 'px,' + transZ + 'px) rotate3d(1,0,0,' + rotX + 'deg) rotate3d(0,1,0,' + rotY + 'deg) rotate3d(0,0,1,' + rotZ + 'deg)'
          ++i
        return
      return
    # reset all when mouse leaves the main wrapper.
    @tiltWrapper.addEventListener 'mouseleave', (ev) ->
      setTimeout (->
        `var i`
        i = 0
        len = self.imgElems.length
        while i < len
          el = self.imgElems[i]
          el.style.WebkitTransform = 'perspective(' + moveOpts.perspective + 'px) translate3d(0,0,0) rotate3d(1,1,1,0deg)'
          el.style.transform = 'perspective(' + moveOpts.perspective + 'px) translate3d(0,0,0) rotate3d(1,1,1,0deg)'
          ++i
        return
      ), 60
      return
    # window resize
    window.addEventListener 'resize', throttle(((ev) ->
      # recalculate tiltWrapper properties: width/height/left/top
      self.view =
        width: self.tiltWrapper.offsetWidth
        height: self.tiltWrapper.offsetHeight
      return
    ), 50)
    return

  init()
  window.TiltFx = TiltFx
  return

# ---
# generated by js2coffee 2.1.0