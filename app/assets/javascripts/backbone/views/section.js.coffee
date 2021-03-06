class Wiki.Views.Section extends Backbone.View
  template : JST['backbone/templates/section']

  templateIn: false

  events:
    'click .foldButton' : 'fold'
    'click .cancelButton': 'cancel'
    'click .saveButton': 'save'
    'mouseover a[href^="/wiki/"]': 'tooltipHeadline'
    'mouseleave a[href^="/wiki/"]' :'tooltipLeft'

  initialize:  (attrs) ->
    @subview = attrs.subview
    @subId = attrs.subId
    @model.bind('error', @error, @)
    @model.bind('sync', @render, @)

  render: (options) ->
    self = @
    # check if template is already in place
    if not self.templateIn
      html = $(@template({title: @model.get('title')}))
      $('#sections-parsed').append(html)
      @setElement($(html))
      @templateIn = true
      $.ajax({
          type: "POST"
          url: "/api/parse/"
          data: {content: self.model.get('content'), id: Wiki.pageTitle}
          success: (data) ->
            if self.subview
              self.renderSubView()
            else
              self.insertHTML(data.html)
            self.bindHanders()
            if options.renderTour
              self.handleTour()
        })
    else
      @renderSubView()

  handleTour: ->
    tourString = localStorage.getItem('currentTour')
    if tourString
      tourData = JSON.parse(tourString)
      tourStep = parseInt(localStorage.getItem('currentTourStep'))
      nextPage = tourData.pages[tourStep + 1]
      tour = new Tour(
        backdrop: true
        onPrev: (tour) ->
          if tour._current == 0
            localStorage.setItem('currentTourStep', tourStep - 1)
        onEnd: ->
          localStorage.removeItem('currentTour')
      )
      tour.setState('end', 'no')
      data = []
      $.each(tourData.pages[tourStep].sections, (i, section) ->
        sectionid = '#' + section.toLowerCase().replace(/\s/g, "_")
        if $(sectionid).length
          data.push(element: sectionid, title: section)
      )
      if tourStep
        if nextPage
          prev = data.length + 1
        else
          prev = data.length
        data[0].prev = prev
      if nextPage
        data.push(path: '/wiki/' + nextPage.title)
        localStorage.setItem('currentTourStep', tourStep + 1)
      if tourStep
        data.push(path: '/wiki/' + tourData.pages[tourStep - 1].title)
      tour.addSteps data
      if tour.ended()
        tour.restart()
      else
        tour.start()

  renderSubView: ->
    if @subview
      $(@el).attr('id', @subId)
      @subview.render()

  fixLinks: ->
    $.each $(@el).find('a') , (a) ->
      $(@).text(Wiki.Utils.atTo101($(@).text()))
      $(@).text($(@).text().replace(/_/g, ' '))

  bindHanders: ->
    self = @
    @editb = $(@el).find('.editButton')
    @foldb = $(@el).find('.foldButton')
    @notEditingButtons = $(@el).find('.notEditing')
    @editingButtons = $(@el).find('.editing')
    if _.contains(Wiki.currentUser.get('actions'), "Edit")
      @editb.click( -> self.initedit())
      @editb.show()

    # enable tool-tips
    $('a[href^="/wiki/"]', @el).tooltip(delay: {show: 250})

  insertHTML : (html) ->
    $(@el).find('.section-content-parsed').html(html).find("h2").remove()
    @fixLinks()

  initedit: ->
    self = @
    @editb.unbind('click').bind('click', -> self.edit())
    @toggleEdit(true)
    editordiv = $(@el).find('.editor')[0]
    editorid = @model.get('title').replace(' ', '-') + 'editor'
    $(editordiv).attr('id', editorid)
    @editor = ace.edit(editordiv)
    @editor.setTheme("ace/theme/wiki")
    @editor.getSession().setMode("ace/mode/wiki")
    @editor.getSession().setUseWrapMode(true)
    @editor.setValue(@model.get('content'))
    @editor.on('change', -> self.editor.replaceAll('[[@', needle: '[[101'))
    @editor.navigateFileStart()
    enable_spellcheck(editorid)

  edit: ->
    @toggleEdit(true)

  save: ->
    self = @
    text = @editor.getValue()
    `matches = text.match(/==([^\r\n=])+==/g)`
    if matches
      `newheadline = matches[0].replace(/==/g,'').trim()`
      $(@el).find('.headline').text(newheadline)
      $(@el).find('.loading-indicator').show()
      $.ajax({
        type: "POST"
        url: "/api/parse/"
        data: {content: text, id: Wiki.pageTitle}
        success: (data) ->
          unless self.subview
            self.insertHTML(data.html)
          self.model.set('content': self.editor.getValue(), 'title': newheadline)
          self.model.set()
          self.toggleEdit(false)
      })
    else
      @showError("Validation Error: Section header missing")

  cancel: (button) ->
    @toggleEdit(false)
    @editor.setValue(@model.get('content'))

  toggleEdit: (open) ->
    self = @
    if open
      $(@el).find('.section-content').animate({marginLeft: '-100%'}, 300)
      $(@el).find('.section-content-source').css(height: '400px')
      $(@el).find('.editor').css(height: '400px')
      $(@notEditingButtons).hide()
      $(@editingButtons).show()

    else
      $(@el).find('.section-content').animate({marginLeft: '0%'}, 300)
      $(@el).find('.section-content-source').css(height: '0px')
      $(@el).find('.editor').css(height: '0px')
      $(@editingButtons).hide()
      $(@notEditingButtons).show()

  fold: ->
      $(@el).find('.section-content').toggle(100)
      $(@foldb).find('i').toggleClass('icon-resize-small icon-resize-full')

  error: (model, err, options) ->
    @showError(err)

  showError: (err) ->
    $('#modal_body').html(
      $('<div>').addClass('alert alert-error')
        .text(err))
    $('#modal').modal()

  tooltipHeadline: (event) ->
    $target = $(event.target)
    $target.addClass('hovered')
    targetMissing = $target.attr('class').indexOf("missing-link") != -1
    if (not targetMissing and $target.attr('data-original-title') == '')
      $target.attr('data-original-title', 'Loading headline...')
      linkTitle = $target.attr('href').replace('/wiki/', '').replace(/^\s+|\s+$/g, '')
      linkDiscovery = new Wiki.Models.PageDiscovery(title: linkTitle)
      linkDiscovery.fetch({
        dataType: 'jsonp'
        success: (model) ->
          headline = model.get('headline').charAt(0).toUpperCase() + model.get('headline').slice(1);
          if headline == ''
            headline = "Page does not have a headline."
          $target.attr('title', headline).tooltip('fixTitle')
          if $target.hasClass('hovered')
            $target.tooltip('show')
        error: ->
          $target.attr('title', "Page not found.").tooltip('fixTitle')
          if $target.hasClass('hovered')
            $target.tooltip('show')
      })

  tooltipLeft: (event) ->
    $(event.target).removeClass("hovered")
