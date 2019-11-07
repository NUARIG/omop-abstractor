import { Controller } from "stimulus"

export default class Notes extends Controller {
  static targets = []

  initialize() {
    document.addEventListener('turbolinks:before-cache', () => {
      document.querySelectorAll('.provider-select2').forEach((select2) => {
        $(select2).select2();
        $(select2).select2('destroy');
      });
    })
  }

  connect() {
    var providersUrl;
    providersUrl = $('#providers_url').attr('href');
    $('.provider-select2').select2({
      ajax: {
        url: providersUrl,
        dataType: 'json',
        delay: 250,
        data: function(params) {
          return {
            q: params.term,
            page: params.page
          };
        },
        processResults: function(data, params) {
          var results;
          params.page = params.page || 1;
          results = $.map(data.users, function(obj) {
            obj.id = obj.provider_name;
            obj.text = obj.provider_name;
            return obj;
          });
          return {
            results: results,
            pagination: {
              more: params.page * 10 < data.total
            }
          };
        },
        cache: true
      },
      escapeMarkup: function(markup) {
        return markup;
      },
      minimumInputLength: 2
    });
  }
}