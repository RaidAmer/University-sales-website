import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  received(data) {
    console.log("📨 New notification received:", data);

    const badge = document.getElementById("notification-count");
    const list = document.getElementById("notification-list");

    // Make sure the badge is visible
    if (badge) {
      const badgeWrapper = badge.parentElement;
      if (badgeWrapper) {
        badgeWrapper.style.display = "inline-block";
      }
    }

    // Prepend new notification to dropdown list
    if (list) {
      const li = document.createElement("li");
      li.innerHTML = `<strong>${data.actor}</strong> ${data.action}`;
      list.prepend(li);
    }

    // Optional: Toast alert
    alert(`${data.actor} ${data.action}`);
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const dropdown = document.getElementById("notificationsDropdown");
  if (dropdown) {
    dropdown.addEventListener("click", () => {
      const badge = document.getElementById("notification-count");
      if (badge) {
        fetch("/notifications/mark_all_read", { method: "POST" }).then(() => {
          badge.textContent = "0";
          const badgeWrapper = badge.closest(".badge-wrapper");
          if (badgeWrapper) {
            badgeWrapper.style.display = "none";
          }
        });
      }
    });
  }
});