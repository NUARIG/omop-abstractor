import { Controller } from "stimulus"
import WorkflowStatus from '../omop_abstractor/workflow_status'

export default class AbstractorAbstractionController extends Controller {
  static targets = []

  initialize() {
  }

  connect() {
  }

  render(event) {
    var controller, currentTarget, abstractor_abstraction_group, detail, status, xhr;
    controller = this;
    currentTarget = event.currentTarget;
    detail = event.detail;
    xhr = detail[0];
    status = detail[1];

    abstractor_abstraction_group = $(event.currentTarget).closest('.abstractor_abstraction_group');
    $(event.currentTarget).closest(".abstractor_abstraction").html(xhr.responseText);
    WorkflowStatus.toggleGroupWorkflowStatus(abstractor_abstraction_group);
    WorkflowStatus.toggleWorkflowStatus();
    return;
  }

  clear() {
    event.preventDefault();
    var controller, currentTarget;
    controller = this;
    currentTarget = event.currentTarget;
    Rails.ajax({
      url: $(currentTarget).attr('href'),
      type: "PUT",
      data: {
        format: 'html',
        '_method': 'put',
        'abstractor_abstraction': {}
      },
      success: function(data) {
        var abstractor_abstraction_group;
        abstractor_abstraction_group = $(currentTarget).closest('.abstractor_abstraction_group');
        $(currentTarget).closest(".abstractor_abstraction").html(new XMLSerializer().serializeToString(data));
        WorkflowStatus.toggleGroupWorkflowStatus(abstractor_abstraction_group);
        WorkflowStatus.toggleWorkflowStatus();
      }
    });
  }

  edit() {
    event.preventDefault();
    var controller, abstractor_abstraction_group, parent_div, parent_div_new;
    controller = this;
    $('.abstractor_update_workflow_status_link').removeClass('abstractor_update_workflow_status_link_enabled');

    $('.abstractor_update_workflow_status_link').addClass('abstractor_update_workflow_status_link_disabled');

    $('.abstractor_update_workflow_status_link').prop('disabled', true);

    abstractor_abstraction_group = $(event.currentTarget).closest('.abstractor_abstraction_group');

    parent_div = $(event.currentTarget).closest(".abstractor_abstraction");

    parent_div_new = (event.currentTarget).closest(".abstractor_abstraction");

    parent_div.load($(event.currentTarget).attr("href"), function() {
      $('select').formSelect();
      $(".abstractor_datepicker").datepicker({
        altFormat: "yy-mm-dd",
        dateFormat: "yy-mm-dd",
        changeMonth: true,
        changeYear: true
      });
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').removeClass('abstractor_group_update_workflow_status_link_enabled');
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').addClass('abstractor_group_update_workflow_status_link_disabled');
      $(abstractor_abstraction_group).find('.abstractor_group_update_workflow_status_link').prop('disabled', true);
      parent_div_new.querySelector("form.edit_abstractor_abstractor_abstraction").addEventListener('ajax:success', function(event) {
        var data, detail, status, xhr;
        detail = event.detail;
        data = detail[0];
        status = detail[1];
        xhr = detail[2];
        abstractor_abstraction_group = $(event.currentTarget).closest('.abstractor_abstraction_group');
        parent_div = $(event.currentTarget).closest(".abstractor_abstraction");
        parent_div.html(xhr.responseText);
        parent_div.removeClass("highlighted");
        WorkflowStatus.toggleGroupWorkflowStatus(abstractor_abstraction_group);
        WorkflowStatus.toggleWorkflowStatus();
      });
    });
    parent_div.addClass("highlighted");
    return;
  }

  validateWorkflowStatus() {
    var controller, abstractionWorkflowStatus;
    controller = this;

    abstractionWorkflowStatus = $(".abstraction_workflow_status_form input[name='abstraction_workflow_status']").val();
    if (!WorkflowStatus.allAnswered() && abstractionWorkflowStatus !== 'pending') {
      WorkflowStatus.toggleWorkflowStatus();
      alert('Validation Error: please set a value for all data points before submission.');
      event.preventDefault();
      return false;
    } else {
      return true;
    }
  }
}