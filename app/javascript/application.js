// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import Rails from "@rails/ujs"
Rails.start()

import "controllers"
import "@popperjs/core"
import "bootstrap"
import autosize from "autosize"

// ✅ Import confetti manually from lib (make sure path matches your file location)
import "./lib/confetti.browser.min"

// ✅ Import your custom confetti logic
import "./controllers/success_confetti"

document.addEventListener("turbo:load", () => {
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  popoverTriggerList.forEach(el => new bootstrap.Popover(el))

  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  tooltipTriggerList.forEach(el => new bootstrap.Tooltip(el))

  autosize(document.querySelectorAll('textarea'))
})
