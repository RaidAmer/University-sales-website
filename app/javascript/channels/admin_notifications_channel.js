import consumer from "channels/consumer"

consumer.subscriptions.create("AdminNotificationsChannel", {
  connected() {
    console.log("✅ Connected to AdminNotificationsChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("📩 Notification received:", data);
    const container = document.getElementById("admin-alert-box");
    if (container) {
      const li = document.createElement("li");
      li.innerHTML = `<strong>${data.email}</strong> just signed up at <em>${data.created_at}</em>`;
      container.prepend(li);

      // Play notification sound
      const audio = new Audio('/audios/notification.mp3');
      audio.play();
    }
  }
});

document.addEventListener("turbo:load", () => {
  if (window.location.pathname === "/notifications") {
    const badge = document.getElementById("notification-count");
    if (badge) {
      badge.textContent = "";
      badge.style.display = "none";
    }
  }
});
