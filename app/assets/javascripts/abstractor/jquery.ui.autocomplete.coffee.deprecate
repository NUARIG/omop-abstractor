$.extend $.ui.autocomplete, filter: (array, term) ->
  if term
    regexes = $.ui.autocomplete.escapeRegex(term).split(' ')
    regexes = _.map(regexes, (t) ->
      regex = new RegExp([
        '.*'
        t
        '.*'
      ].join(''))
      regex.compile regex.source, 'im'
      regex
    )
    return $.grep array, (value) ->
      testOn = value.label or value.value or value
      return _(regexes).all (t) ->
        return t.test testOn
  else
    array