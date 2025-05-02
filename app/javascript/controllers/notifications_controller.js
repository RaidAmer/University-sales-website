

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("📢 NotificationsController connected")
  }

  notify(event) {
    const message = event.detail?.message || "🔔 You have a new notification"
    const toast = document.createElement("div")
    toast.className = "toast-notification"
    toast.innerText = message

    Object.assign(toast.style, {
      position: "fixed",
      top: "20px",
      right: "20px",
      background: "#343a40",
      color: "white",
      padding: "10px 20px",
      borderRadius: "5px",
      zIndex: 9999
    })

    document.body.appendChild(toast)

    setTimeout(() => toast.remove(), 4000)
  }
}