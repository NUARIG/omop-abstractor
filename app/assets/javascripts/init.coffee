window.OmopAbstractor ||= {}

OmopAbstractor.init = ->
  $('select').formSelect();
  $('.datepicker').datepicker(format: 'mm/dd/yyyy')
  $('.sidenav').sidenav(edge: 'right')
  $('.modal').modal()
  if $('.abstractor_footer').length > 0
    $('.abstractor_abstractions').css('margin-top', $('.abstractor_footer').height()*-1)
  providersUrl = $('#providers_url').attr('href')
  $('.provider-select2').select2
    ajax:
      url: providersUrl
      dataType: 'json'
      delay: 250
      data: (params) ->
        {
          q: params.term
          page: params.page
        }
      processResults: (data, params) ->
        params.page = params.page or 1
        results = $.map(data.users, (obj) ->
          obj.id = obj.provider_name
          obj.text = obj.provider_name
          obj
        )

        {
          results: results
          pagination: more: params.page * 10 < data.total
        }
      cache: true
    escapeMarkup: (markup) ->
      markup
    minimumInputLength: 2

OmopAbstractor.destroy = ->
  $('.sidenav').sidenav('destroy')

$(document).on 'turbolinks:load', ->
  OmopAbstractor.init()

$(document).on 'turbolinks:before-cache', ->
  OmopAbstractor.destroy()