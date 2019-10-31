allAnswered = ->
  abstractor_abstractions = $('.abstractor_abstraction')
  set_abstractions = $('.abstractor_abstractions').find('.abstractor_abstraction input:checkbox:checked').map(->
    $(this).val()
  ).get()
  if abstractor_abstractions.length == set_abstractions.length
    return true
  else
    return false

toggleWorkflowStatus = ->
  if allAnswered()
    $('.abstractor_update_workflow_status_link').removeClass('abstractor_update_workflow_status_link_disabled')
    $('.abstractor_update_workflow_status_link').addClass('abstractor_update_workflow_status_link_enabled')
    $('.abstractor_update_workflow_status_link').prop('disabled', false)
  else
    $('.abstractor_update_workflow_status_link').removeClass('abstractor_update_workflow_status_link_enabled')
    $('.abstractor_update_workflow_status_link').addClass('abstractor_update_workflow_status_link_disabled')
    $('.abstractor_update_workflow_status_link').prop('disabled', true)

toggleGroupWorkflowStatus = (abstractor_abstraction_group) ->
  abstractor_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction')
  set_abstractions = $(abstractor_abstraction_group).find('.abstractor_abstraction input:checkbox:checked').map(->
    $(this).val()
  ).get()
  if abstractor_abstractions.length == set_abstractions.length
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_disabled')
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_enabled')
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', false)
  else
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
    $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)

# based on https://stackoverflow.com/questions/6240139/highlight-text-range-using-javascript
# https://stackoverflow.com/questions/21441524/remove-added-highlight-from-dom
# https://stackoverflow.com/questions/14028773/javascript-execcommandremoveformat-doesnt-strip-h2-tag

getTextNodesIn = (node) ->
  textNodes = []
  if node.nodeType == 3
    textNodes.push node
  else
    children = node.childNodes
    i = 0
    len = children.length
    while i < len
      textNodes.push.apply textNodes, getTextNodesIn(children[i])
      ++i
  textNodes

setSelectionRange = (el, start, end) ->
  if document.createRange and window.getSelection
    range = document.createRange()
    range.selectNodeContents el
    textNodes = getTextNodesIn(el)
    foundStart = false
    charCount = 0
    endCharCount = undefined
    i = 0
    textNode = undefined
    while textNode = textNodes[i++]
      endCharCount = charCount + textNode.length
      if !foundStart and start >= charCount and (start < endCharCount or start == endCharCount and i <= textNodes.length)
        range.setStart textNode, start - charCount
        foundStart = true
      if foundStart and end <= endCharCount
        range.setEnd textNode, end - charCount
        break
      charCount = endCharCount
    sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange range
  else if document.selection and document.body.createTextRange
    textRange = document.body.createTextRange()
    textRange.moveToElementText el
    textRange.collapse true
    textRange.moveEnd 'character', end
    textRange.moveStart 'character', start
    textRange.select()
  return

## Serializes and returns the specified range
# (ignoring it if its length is zero)
##
serializeRange = (range) ->
  if !range or range.startContainer == range.endContainer and range.startOffset == range.endOffset then null else
    startContainer: range.startContainer
    startOffset: range.startOffset
    endContainer: range.endContainer
    endOffset: range.endOffset

### Restores the specified serialized version
# (removing any ranges currently seleted)
###
restoreRange = (serialized) ->
  range = document.createRange()
  range.setStart serialized.startContainer, serialized.startOffset
  range.setEnd serialized.endContainer, serialized.endOffset
  sel = window.getSelection()
  sel.removeAllRanges()
  sel.addRange range
  return

makeEditableAndHighlight = (colour) ->
  sel = window.getSelection()
  if sel.rangeCount and sel.getRangeAt
    range = sel.getRangeAt(0)

  ua = window.navigator.userAgent;
  msie = ua.indexOf("MSIE ");
  is_ie = (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))

  if is_ie # If Internet Explorer
    range.commonAncestorContainer.contentEditable = true
  else # If another browser
    document.designMode = 'on'

  if range
    sel.removeAllRanges()
    sel.addRange range
      # Use HiliteColor since some browsers apply BackColor to the whole block

  if !document.execCommand 'HiliteColor', false, colour
    document.execCommand 'BackColor', false, colour
  # it is important to serialize the range *after* hiliting,
  # because `execCommand` will change the DOM affecting the
  # range's start-/endContainer and offsets.
  serializedRange = serializeRange(sel.getRangeAt(0))
  sel.removeAllRanges()

  if is_ie  # If Internet Explorer
    range.commonAncestorContainer.contentEditable = false
  else  # If another browser
    document.designMode = 'off'

  return serializedRange

removeHihighlightFromRanges = (serializedRanges) ->
  ua = window.navigator.userAgent;
  msie = ua.indexOf("MSIE ");
  is_ie = (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))

  for serializedRange in serializedRanges
    if !is_ie # If not IE
      document.designMode = 'on'

    restoreRange serializedRange
    serializedRange = null
    sel = window.getSelection()
    range = sel.getRangeAt(0)

    if is_ie # If Internet Explorer
      range.commonAncestorContainer.contentEditable = true

    if !document.execCommand 'HiliteColor', false, '#fff'
      document.execCommand 'BackColor', false, '#fff'
    sel.removeAllRanges()

    if is_ie  # If Internet Explorer
      range.commonAncestorContainer.contentEditable = false
    else  # If another browser
      document.designMode = 'off'
  return

highlightWithColor = (colour) ->
  range           = undefined
  serializedRange = undefined
  if window.getSelection
    # IE9 and non-IE
    serializedRange = makeEditableAndHighlight colour
  else if document.selection and document.selection.createRange
    # IE <= 8 case
    range = document.selection.createRange()
    range.execCommand 'BackColor', false, colour
    serializedRange = serializeRange(range)
  return serializedRange

highlightRange = (el, start, end) ->
  setSelectionRange el, start, end
  serializedRange = highlightWithColor 'yellow'
  return serializedRange

#-------------------------------------------------------------------------------------------
Abstractor = {}
Abstractor.AbstractionUI = ->
  highlightedRanges = []
  $(document).on "click", ".abstractor_abstraction .clear_link", (e) ->
    e.preventDefault()
    that = this
    Rails.ajax({
      url: $(this).attr('href'),
      type: "PUT",
      data: { format: 'html', '_method': 'put', 'abstractor_abstraction': { } },
      success: (data) ->
        abstractor_abstraction_group = $(that).closest('.abstractor_abstraction_group')
        $(that).closest(".abstractor_abstraction").html(new XMLSerializer().serializeToString(data))
        toggleGroupWorkflowStatus(abstractor_abstraction_group)
        toggleWorkflowStatus()
        return
    })

  $(document).on "click", ".abstractor_abstractions .show_hide_abstractor_history_link", (e) ->
    e.preventDefault()
    if $(this).hasClass('show_abstractor_history')
      $(this).removeClass('show_abstractor_history')
      $(this).addClass('hide_abstractor_history')
      $(this).closest(".abstractor_history").find('.abstactor_history_content').removeClass('hide')
      $(this).html('(Hide)')
    else
      $(this).addClass('show_abstractor_history')
      $(this).removeClass('hide_abstractor_history')
      $(this).closest(".abstractor_history").find('.abstactor_history_content').addClass('hide')
      $(this).html('(Show)')
    return false

  $(document).on "click", ".abstractor_abstraction_value a.edit_link", (e) ->
    e.preventDefault()
    $('.abstractor_update_workflow_status_link').removeClass('abstractor_update_workflow_status_link_enabled')
    $('.abstractor_update_workflow_status_link').addClass('abstractor_update_workflow_status_link_disabled')
    $('.abstractor_update_workflow_status_link').prop('disabled', true)
    abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
    parent_div = $(this).closest(".abstractor_abstraction")
    parent_div_new = this.closest(".abstractor_abstraction")
    parent_div.load $(this).attr("href"), ->
      $('select').formSelect();
      # parent_div.find(".combobox").combobox watermark: "a value"
      $(".abstractor_datepicker").datepicker
        altFormat: "yy-mm-dd"
        dateFormat: "yy-mm-dd"
        changeMonth: true
        changeYear: true
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled')
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true)

      parent_div_new.querySelector("form.edit_abstractor_abstractor_abstraction").addEventListener 'ajax:success', (event) ->
        detail = event.detail
        data = detail[0]
        status = detail[1]
        xhr = detail[2]

        abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
        parent_div = $(this).closest(".abstractor_abstraction")
        parent_div.html xhr.responseText
        parent_div.removeClass "highlighted"
        toggleGroupWorkflowStatus(abstractor_abstraction_group)
        toggleWorkflowStatus()
        return
      return

    parent_div.addClass "highlighted"
    return

  document.querySelectorAll('form.edit_abstractor_abstractor_abstraction').forEach (item) ->
    item.addEventListener 'ajax:success', (event) ->
      detail = event.detail
      data = detail[0]
      status = detail[1]
      xhr = detail[2]
      abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
      $(this).closest(".abstractor_abstraction").html(xhr.responseText)
      toggleGroupWorkflowStatus(abstractor_abstraction_group)
      toggleWorkflowStatus()

      return
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='radio']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='checkbox']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    $(this).siblings("input[type='text']").prop "value", ""
    autocompleters = $(this).siblings("select.combobox")
    autocompleters.combobox "setValue", ""
    autocompleters.change()
    $.each $(this).siblings("input[type='radio']"), ->
      if $(this).prop("value") is ""
        $(this).prop "checked", true
      else
        $(this).prop "checked", false
      return

    return

  $(document).on "change", ".edit_abstractor_abstraction select.combobox", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false  if $(this).find("option:selected").prop("value").length
    return

  $(document).on "change", ".edit_abstractor_abstraction input[type='text']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".abstractor_abstraction_source_tooltip_img", (e) ->
    e.preventDefault()
    target = $(this).attr("rel")
    tab = $(target).find('.abstractor_source_tab')
    if tab.length == 1
      tab = $(tab).html().trim()
      $('#' + tab + ' input[type=radio]').prop('checked', true)
      removeHihighlightFromRanges(highlightedRanges)
      highlightedRanges = []
      if $(this).hasClass('highlighted_suggestion')
        highlight = false
        $(this).removeClass('highlighted_suggestion')
      else
        highlight = true
        $('.highlighted_suggestion').removeClass('highlighted_suggestion')
        $(this).addClass('highlighted_suggestion')
      $(target).find('.sentence').each (index) ->
        sentence_match_value = _.unescape($(this).find('.sentence_match_value').html().trim()).replace(/[.^$*+?()[{\\|\]-]/g, '\\$&')
        hashed_sentence = $(this).find('.sentence_match_value .hashed_sentence').html().trim()
        if highlight
          $(this).find('.match_value').each (index) ->
            # replace empty spaces with regex matcher and match to the text
            that = this
            text_elements  = $('#' + tab + " .abstractor_source_tab_content ." + hashed_sentence)
            text_elements.each (index) ->
              text_element = $(this)
              match_value   = $(that).html().trim().replace(/[-[\]{}()*+?.,\\^$|#]/g, "\\$&").replace(/\s+/g, "\\s*")
              regex         = new RegExp(match_value, 'gi')
              while (match = regex.exec(text_element.get(0).textContent)) != null
                highlightedRanges.push(highlightRange(text_element.get(0), match.index, match.index + match[0].length))
              return
        else
          removeHihighlightFromRanges(highlightedRanges)
          highlightedRanges = []
        return

    return

  $(document).on "change", "select.indirect_source_list", ->
    source_type = $(this).attr("rel")
    value = $(this).find("option:selected").prop("value")
    $(this).siblings(".indirect_source_text").addClass "hidden"
    $(this).siblings("." + source_type + "_" + value).removeClass "hidden"
    return

  $(document).on "click", '.abstractor_update_workflow_status_link', (e) ->
    abstractionWorkflowStatus = $(".abstraction_workflow_status_form input[name='abstraction_workflow_status']").val()
    if !allAnswered() && abstractionWorkflowStatus != 'pending'
      toggleWorkflowStatus()
      alert('Validation Error: please set a value for all data points before submission.')
      e.preventDefault()
      return false
    else
      return true
  return

Abstractor.AbstractionSuggestionUI = ->
  $(document).on "change", ".abstractor_suggestion_status_selection", ->
    parentForm = this.closest("form")
    Rails.fire(parentForm, 'submit')
    $('.abstractor_footer').unhighlight()
    return

  $(document).on "ajax:success", "form.edit_abstractor_suggestion", (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]

    abstractor_abstraction_group = $(this).closest('.abstractor_abstraction_group')
    $(this).closest(".abstractor_abstraction").html xhr.responseText
    toggleGroupWorkflowStatus(abstractor_abstraction_group)
    toggleWorkflowStatus()
    return
  return

Abstractor.AbstractionGroupUI = ->
  validateCardinality = (group_container) ->
    group_cardinality = group_container.find('input[name="abstractor_subject_group_cardinality"]')
    add_group_link    = group_container.find('.abstractor_group_add_link')
    if (group_cardinality.length > 0) && (group_cardinality.val() == group_container.find('.abstractor_abstraction_group_member').length.toString())
      $(add_group_link).hide()
    else
      $(add_group_link).show()

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_delete_link", (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]

    subject_groups_container_div = $(this).closest(".abstractor_subject_groups_container")
    abstraction_group_div = $(this).closest(".abstractor_abstraction_group")
    abstraction_group_div.html xhr.responseText
    validateCardinality(subject_groups_container_div)
    toggleWorkflowStatus()
    return

  $(document).on "ajax:success", ".abstractor_subject_groups_container .abstractor_group_add_link", (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]

    parent_div = $(this).closest(".abstractor_subject_groups_container")
    parent_div.find(".abstractor_subject_groups").append xhr.responseText
    validateCardinality(parent_div)
    toggleWorkflowStatus()
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_not_applicable_all_link", (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_unknown_all_link", (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on 'ajax:success', '.abstraction_workflow_status_form', (event) ->
    detail = event.detail
    data = detail[0]
    status = detail[1]
    xhr = detail[2]
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  return

$(document).on 'DOMContentLoaded', (e) ->
  new Abstractor.AbstractionUI()
  new Abstractor.AbstractionSuggestionUI()
  new Abstractor.AbstractionGroupUI()