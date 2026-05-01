import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["videoInput", "preview", "previewVideo", "duration"]

  connect() {
    this.previewUrl = null
    this.resetPreview()
  }

  disconnect() {
    this.revokePreviewUrl()
  }

  onVideoChange() {
    if (!this.hasVideoInputTarget || this.videoInputTarget.files.length === 0) {
      this.resetPreview()
      return
    }

    const [file] = this.videoInputTarget.files

    this.revokePreviewUrl()
    this.previewUrl = URL.createObjectURL(file)
    if (this.hasPreviewVideoTarget) {
      this.previewVideoTarget.src = this.previewUrl
      this.previewVideoTarget.load()
    }
    if (this.hasPreviewTarget) this.previewTarget.hidden = false
  }

  captureDuration() {
    if (!this.hasDurationTarget || !this.hasPreviewVideoTarget) return

    this.durationTarget.textContent = this.formatDuration(this.previewVideoTarget.duration)
  }

  resetPreview() {
    if (this.hasVideoInputTarget) this.videoInputTarget.value = ""
    if (this.hasPreviewVideoTarget) {
      this.previewVideoTarget.removeAttribute("src")
      this.previewVideoTarget.load()
    }
    if (this.hasDurationTarget) this.durationTarget.textContent = ""
    if (this.hasPreviewTarget) this.previewTarget.hidden = true
    this.revokePreviewUrl()
  }

  revokePreviewUrl() {
    if (!this.previewUrl) return

    URL.revokeObjectURL(this.previewUrl)
    this.previewUrl = null
  }

  formatDuration(durationInSeconds) {
    const total = Math.max(0, Math.floor(durationInSeconds || 0))
    const hours = Math.floor(total / 3600)
    const minutes = Math.floor((total % 3600) / 60)
    const seconds = total % 60
    if (hours > 0) return `${hours}:${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`

    return `${minutes}:${String(seconds).padStart(2, "0")}`
  }
}
