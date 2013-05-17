class Wiki.Views.Section extends Backbone.View
  template : JST['backbone/templates/section']

  templateIn: false

  events:
    'click .foldButton' : 'fold'
    'click .cancelButton': 'cancel'
    'click .saveButton': 'save'

  initialize:  (attrs) ->
    @subview = attrs.subview
    @subId = attrs.subId
    @model.bind('error', @error, @)
    @model.bind('sync', @render, @)

  render: (options) ->
    self = @
    # check if template is already in place
    if not self.templateIn
      html = $(self.template({title: self.model.get('title')}))
      $('#sections-parsed').append(html)
      self.setElement(html)
      self.bindHanders()
      self.fixLinks()
      self.templateIn = true
    if @subview
        @renderSubView()
    else
      $.ajax({
          type: "POST"
          url: "/api/parse/"
          data: {content: self.model.get('content'), pagetitle: Wiki.pageTitle}
          success: (data) ->
            self.insertHTML(data.html)

        })

  renderSubView: ->
    if @subview
      $(@el).attr('id', @subId)
      @subview.render()

  fixLinks: ->
    $.each $(@el).find('a') , (a) ->
      if $(@).attr('href')
        $(@).attr('href', $(@).attr('href').replace(/\/wiki\/(\b[a-z])/g, (s,match) ->
          '/wiki/' + match.toUpperCase())
        )

  bindHanders: ->
    self = @
    @editb = $(@el).find('.editButton')
    @foldb = $(@el).find('.foldButton')
    @notEditingButtons = $(@el).find('.notEditing')
    @editingButtons = $(@el).find('.editing')
    if not _.contains(Wiki.currentUser.get('actions'), "Edit")
      @editb.hide()
    else
      @editb.click( -> self.initedit())

  insertHTML : (html) ->
    $(@el).find('.section-content-parsed').html(html).find("h2").remove()

  initedit: ->
    self = @
    @editb.unbind('click').bind('click', -> self.edit())
    @toggleEdit(true)
    editordiv = $(@el).find('.editor')[0]
    editorid = @model.get('title').replace(' ', '-') + 'editor'
    $(editordiv).attr('id', editorid)
    @editor = ace.edit(editordiv)
    @editor.setTheme("ace/theme/chrome")
    @editor.getSession().setMode("ace/mode/text")
    @editor.getSession().setUseWrapMode(true)
    @editor.setValue(@model.get('content'))
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
      $.ajax({
        type: "POST"
        url: "/api/parse/"
        data: {content: text, pagetitle: Wiki.pageTitle}
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

