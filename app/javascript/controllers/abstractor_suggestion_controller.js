import { Controller } from "stimulus"
const controllers = new Set([]);
export default class AbstractorSuggestionController extends Controller {
  static targets = ['tooltip']

  initialize() {
  }

  connect() {
    controllers.add(this);
    this.highlightedRanges = [];
  }

  clearHighlights() {
    controllers.forEach(function(controller) {
      controller.removeHihighlightFromRanges(controller.highlightedRanges)
    });
  }

  highlight() {
    event.preventDefault();
    var controller, highlight, tab, target;
    controller = this;
    controller.clearHighlights();
    target = $(this.tooltipTarget).attr("rel");
    tab = $(target).find('.abstractor_source_tab');

    if (tab.length === 1) {
      tab = $(tab).html().trim();
      $('#' + tab + ' input[type=radio]').prop('checked', true);
      controller.removeHihighlightFromRanges(controller.highlightedRanges);
      this.highlightedRanges = [];
      if ($(this.tooltipTarget).hasClass('highlighted_suggestion')) {
        highlight = false;
        $(this.tooltipTarget).removeClass('highlighted_suggestion');
      } else {
        highlight = true;
        $('.highlighted_suggestion').removeClass('highlighted_suggestion');
        $(this.tooltipTarget).addClass('highlighted_suggestion');
      }
      $(target).find('.sentence').each(function(index) {
        var hashed_sentence, sentence_match_value;
        sentence_match_value = _.unescape($(this).find('.sentence_match_value').html().trim()).replace(/[.^$*+?()[{\\|\]-]/g, '\\$&');
        hashed_sentence = $(this).find('.sentence_match_value .hashed_sentence').html().trim();
        if (highlight) {
          $(this).find('.match_value').each(function(index) {
            var text_elements, that;
            that = this;
            text_elements = $('#' + tab + " .abstractor_source_tab_content ." + hashed_sentence);
            return text_elements.each(function(index) {
              var match, match_value, regex, text_element;
              text_element = $(this);
              match_value = $(that).html().trim().replace(/[-[\]{}()*+?.,\\^$|#]/g, "\\$&").replace(/\s+/g, "\\s*");
              regex = new RegExp(match_value, 'gi');
              while ((match = regex.exec(text_element.get(0).textContent)) !== null) {
                controller.highlightedRanges.push(controller.highlightRange(text_element.get(0), match.index, match.index + match[0].length));
              }
            });
          });
        } else {
          controller.removeHihighlightFromRanges(controller.highlightedRanges);
          controller.highlightedRanges = [];
        }
      });
    }
  }

  determine() {
    var controller, currentTarget, parentForm;
    controller = this;
    currentTarget = event.currentTarget;
    parentForm = currentTarget.closest("form");
    Rails.fire(parentForm, 'submit');
    $('.abstractor_footer').unhighlight();
    return;
  }

  getTextNodesIn(node) {
    var controller, children, i, len, textNodes;
    controller = this;
    textNodes = [];
    if (node.nodeType === 3) {
      textNodes.push(node);
    } else {
      children = node.childNodes;
      i = 0;
      len = children.length;
      while (i < len) {
        textNodes.push.apply(textNodes, controller.getTextNodesIn(children[i]));
        ++i;
      }
    }
    return textNodes;
  }

  setSelectionRange(el, start, end) {
    var controller, charCount, endCharCount, foundStart, i, range, sel, textNode, textNodes, textRange;
    controller = this;
    if (document.createRange && window.getSelection) {
      range = document.createRange();
      range.selectNodeContents(el);
      textNodes = controller.getTextNodesIn(el);
      foundStart = false;
      charCount = 0;
      endCharCount = void 0;
      i = 0;
      textNode = void 0;
      while (textNode = textNodes[i++]) {
        endCharCount = charCount + textNode.length;
        if (!foundStart && start >= charCount && (start < endCharCount || start === endCharCount && i <= textNodes.length)) {
          range.setStart(textNode, start - charCount);
          foundStart = true;
        }
        if (foundStart && end <= endCharCount) {
          range.setEnd(textNode, end - charCount);
          break;
        }
        charCount = endCharCount;
      }
      sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    } else if (document.selection && document.body.createTextRange) {
      textRange = document.body.createTextRange();
      textRange.moveToElementText(el);
      textRange.collapse(true);
      textRange.moveEnd('character', end);
      textRange.moveStart('character', start);
      textRange.select();
    }
  }

  serializeRange(range) {
    var controller;
    controller = this;
    if (!range || range.startContainer === range.endContainer && range.startOffset === range.endOffset) {
      return null;
    } else {
      return {
        startContainer: range.startContainer,
        startOffset: range.startOffset,
        endContainer: range.endContainer,
        endOffset: range.endOffset
      };
    }

  }

  restoreRange(serialized) {
    var range, sel;
    range = document.createRange();
    range.setStart(serialized.startContainer, serialized.startOffset);
    range.setEnd(serialized.endContainer, serialized.endOffset);
    sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  }

  makeEditableAndHighlight(colour) {
    var controller, is_ie, msie, range, sel, serializedRange, ua;
    controller = this;

    sel = window.getSelection();
    if (sel.rangeCount && sel.getRangeAt) {
      range = sel.getRangeAt(0);
    }
    ua = window.navigator.userAgent;
    msie = ua.indexOf("MSIE ");
    is_ie = msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./);
    if (is_ie) {
      range.commonAncestorContainer.contentEditable = true;
    } else {
      document.designMode = 'on';
    }
    if (range) {
      sel.removeAllRanges();
      sel.addRange(range);
    }
    if (!document.execCommand('HiliteColor', false, colour)) {
      document.execCommand('BackColor', false, colour);
    }
    serializedRange = controller.serializeRange(sel.getRangeAt(0));
    sel.removeAllRanges();
    if (is_ie) {
      range.commonAncestorContainer.contentEditable = false;
    } else {
      document.designMode = 'off';
    }
    return serializedRange;
  }

  removeHihighlightFromRanges(serializedRanges) {
    var controller, i, is_ie, len, msie, range, sel, serializedRange, ua;
    controller = this;

    ua = window.navigator.userAgent;
    msie = ua.indexOf("MSIE ");
    is_ie = msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./);
    for (i = 0, len = serializedRanges.length; i < len; i++) {
      serializedRange = serializedRanges[i];
      if (!is_ie) {
        document.designMode = 'on';
      }
      controller.restoreRange(serializedRange);
      serializedRange = null;
      sel = window.getSelection();
      range = sel.getRangeAt(0);
      if (is_ie) {
        range.commonAncestorContainer.contentEditable = true;
      }
      if (!document.execCommand('HiliteColor', false, '#fff')) {
        document.execCommand('BackColor', false, '#fff');
      }
      sel.removeAllRanges();
      if (is_ie) {
        range.commonAncestorContainer.contentEditable = false;
      } else {
        document.designMode = 'off';
      }
    }
  }

  highlightWithColor (colour) {
    var controller, range, serializedRange;
    controller = this;
    range = void 0;
    serializedRange = void 0;
    if (window.getSelection) {
      serializedRange = controller.makeEditableAndHighlight(colour);
    } else if (document.selection && document.selection.createRange) {
      range = document.selection.createRange();
      range.execCommand('BackColor', false, colour);
      serializedRange = controller.serializeRange(range);
    }
    return serializedRange;
  }

  highlightRange(el, start, end) {
    var controller, serializedRange;
    controller = this;
    controller.setSelectionRange(el, start, end);
    serializedRange = controller.highlightWithColor('yellow');
    return serializedRange;
  }
}