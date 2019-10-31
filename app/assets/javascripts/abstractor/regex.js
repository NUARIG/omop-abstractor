$.extend($.expr[":"], {
  "regex": function(elem, i, match, array) {
      var array = new RegExp(match[3], 'i');
      return array.test(jQuery(elem).text());
  }
});