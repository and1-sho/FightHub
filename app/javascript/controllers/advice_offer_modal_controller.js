import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "backdrop",
    "menuArea",
    "error",
    "acceptsInput",
    "textMenuInput",
    "textVideoMenuInput",
    "textMenuCheckbox",
    "textVideoMenuCheckbox"
  ]

  connect() {
    // 初期表示や再描画時に意図せずモーダルが開かないように固定する
    if (this.hasBackdropTarget) this.backdropTarget.hidden = true
    if (this.hasMenuAreaTarget) this.menuAreaTarget.hidden = true
    if (this.hasAcceptsInputTarget) this.acceptsInputTarget.value = "0"
    if (this.hasTextMenuInputTarget) this.textMenuInputTarget.value = "0"
    if (this.hasTextVideoMenuInputTarget) this.textVideoMenuInputTarget.value = "0"
  }

  open() {
    this.errorTarget.hidden = true
    this.errorTarget.textContent = ""
    this.backdropTarget.hidden = false
  }

  close() {
    this.backdropTarget.hidden = true
  }

  toggle(event) {
    const enabled = event.target.value === "on"
    this.menuAreaTarget.hidden = !enabled
    if (!enabled) {
      this.textMenuCheckboxTarget.checked = false
      this.textVideoMenuCheckboxTarget.checked = false
      this.syncMenus()
    }
  }

  syncMenus() {
    this.textMenuInputTarget.value = this.textMenuCheckboxTarget.checked ? "1" : "0"
    this.textVideoMenuInputTarget.value = this.textVideoMenuCheckboxTarget.checked ? "1" : "0"
  }

  submit() {
    const enabled = !this.menuAreaTarget.hidden
    this.acceptsInputTarget.value = enabled ? "1" : "0"
    this.syncMenus()

    const textSelected = this.textMenuInputTarget.value === "1"
    const textVideoSelected = this.textVideoMenuInputTarget.value === "1"
    if (enabled && !textSelected && !textVideoSelected) {
      this.errorTarget.textContent = "ONの場合は受け付ける内容を1つ以上選択してください"
      this.errorTarget.hidden = false
      return
    }

    this.close()
    this.element.querySelector("form")?.requestSubmit()
  }
}
