import { Controller } from "stimulus"

export default class AbstractorObjectValueVariantsController extends Controller {
  static targets =['abstractorObjectValueVariant', 'id', 'destroy', 'addAbstractorObjectValueVariant']

  connect() {
    if (typeof M.updateTextFields == 'function') {
       M.updateTextFields();
    }

    if (this.hasDestroyTarget) {
      if (this.destroyTarget.value == 'true') {
        this.abstractorObjectValueVariantTarget.style.display = 'none';
      }
    }
  }

  initialize() {
  }

  delete() {
    event.preventDefault();
    const confirmed = confirm('Are you sure?')
    if (confirmed) {
      if (this.idTarget.value) {
        this.destroyTarget.value = '1'
        this.abstractorObjectValueVariantTarget.style.display = 'none';
      }
      else {
        this.abstractorObjectValueVariantTarget.parentNode.removeChild(this.abstractorObjectValueVariantTarget);
      }
    }
  }
}