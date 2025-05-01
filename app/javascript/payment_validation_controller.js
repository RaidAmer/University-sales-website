document.addEventListener("DOMContentLoaded", function () {
    const form = document.querySelector("form");
    const methodSelect = document.getElementById("payment-method");
  
    const cardField = document.querySelector("[name='card_number']");
    const expField = document.querySelector("[name='expiration_date']");
    const cvvField = document.querySelector("[name='cvv']");
    const cardFieldsContainer = document.getElementById("card-fields");
  
    function updateCardFieldState() {
      const isCardRequired = !(methodSelect.value === "Campus" || methodSelect.value === "Apple pay");
  
      if (isCardRequired) {
        cardFieldsContainer.style.display = "block";
  
        cardField.removeAttribute("disabled");
        expField.removeAttribute("disabled");
        cvvField.removeAttribute("disabled");
  
        cardField.setAttribute("required", "required");
        expField.setAttribute("required", "required");
        cvvField.setAttribute("required", "required");
      } else {
        cardFieldsContainer.style.display = "none";
  
        cardField.removeAttribute("required");
        expField.removeAttribute("required");
        cvvField.removeAttribute("required");
  
        cardField.setAttribute("disabled", "disabled");
        expField.setAttribute("disabled", "disabled");
        cvvField.setAttribute("disabled", "disabled");
      }
    }
  
    methodSelect.addEventListener("change", updateCardFieldState);
    updateCardFieldState();
  
    form.addEventListener("submit", function (e) {
      const method = methodSelect.value;
      if (method === "Campus" || method === "Apple pay") return; // Skip all validation
  
      const card = cardField.value.trim().replace(/\s+/g, "");
      const exp = expField.value.trim();
      const cvv = cvvField.value.trim();
  
      if (!/^\d{16}$/.test(card)) {
        alert("Invalid card number. Must be 16 digits.");
        e.preventDefault();
        return;
      }
  
      const match = exp.match(/^(\d{2})\/(\d{2})$/);
      if (!match) {
        alert("Invalid expiration date format (MM/YY).");
        e.preventDefault();
        return;
      }
  
      const month = parseInt(match[1], 10);
      const year = parseInt("20" + match[2], 10);
      if (month < 1 || month > 12 || year < 2026) {
        alert("Expiration year must be 2026 or later.");
        e.preventDefault();
        return;
      }
  
      if (!/^\d{3,4}$/.test(cvv)) {
        alert("Invalid CVV.");
        e.preventDefault();
        return;
      }
    });
  });
  