class Wiki.Views.Triples extends Backbone.View

  expandableTemplate : JST['backbone/templates/expandable']

  render: ->
    self = @
    @setElement('#metasection')
    @internalTripleCount = 0
    $(@el).find('.section-content-parsed').fadeTo(200, 1)
    $(@el).find(' .loading-indicator').css('visibility', 'hidden')
    @model.fetch({
      url: self.model.urlBase + self.escapeURI(Wiki.page.get('title'))
      dataType: 'jsonp'
      jsonpCallback: 'callback'
      success: ->
        self.addAll()
    })

  escapeURI: (uri) ->
    decodeURIComponent(uri
      .replace(/\-/g, '-2D')
      .replace(/\:/g, "-3A")
      .replace(/\s/g, '_')
    )

  is101Triple: (triple) ->
    internalPrefix = 'http://101companies.org/'
    triple.get('node').substring(0, internalPrefix.length) == internalPrefix

  tripleOrdering: (a,b) ->
    if a.get('predicate') < b.get('predicate')
      -1
    else if a.get('predicate') > b.get('predicate')
      1
    else if a.get('node') < b.get('node')
      -1
    else if a.get('node') > b.get('node')
      1
    else
      0

  addInternalTriple: (triple) ->
    if @internalTripleCount < 13
      el = '#metasection .section-content-parsed'
    else
      if @internalTripleCount == 13
        $(@el).append(@expandableTemplate(name: "metasection-continued"))
      el =  '#metasection-continued'
    tripleview = new Wiki.Views.Triple(model: triple, el: el)
    tripleview.render()

  addExternalTriple: (triple) ->
    tripleview = new Wiki.Views.ExTriple(model: triple)
    tripleview.render()

  addTriple: (triple) ->
    if @is101Triple(triple)
      @internalTripleCount++;
      @addInternalTriple(triple)
    else
      @addExternalTriple(triple)

  addAll: ->
    self = @
    $(@el).find('.section-content-parsed').html('')
    $.each @model.models.sort(self.tripleOrdering), (i, triple) ->
      self.addTriple(triple)

