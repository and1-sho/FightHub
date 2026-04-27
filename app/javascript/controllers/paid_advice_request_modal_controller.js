import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop"]

  connect() {
    if (this.hasBackdropTarget) this.backdropTarget.hidden = true
  }

  open() {
    this.backdropTarget.hidden = false
  }

  close() {
    this.backdropTarget.hidden = true
  }
}
