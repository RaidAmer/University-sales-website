import confetti from "https://cdn.skypack.dev/canvas-confetti";

document.addEventListener("turbo:load", () => {
  const confettiArea = document.getElementById("confetti-container");

  if (confettiArea) {
    confetti({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
    });

    setTimeout(() => {
      confetti({
        particleCount: 150,
        spread: 100,
        angle: 60,
        origin: { x: 0 },
      });

      confetti({
        particleCount: 150,
        spread: 100,
        angle: 120,
        origin: { x: 1 },
      });
    }, 300);
  }
});
