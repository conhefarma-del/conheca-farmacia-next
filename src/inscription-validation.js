// Validação Inline para Formulário de Inscrição
// Adiciona feedback visual em tempo real nos campos do formulário

export function initInlineValidation() {
  const form = document.getElementById("inscription-form");
  if (!form) return;

  const inputs = form.querySelectorAll(
    "input[required], select[required], textarea[required]"
  );

  // Criador de elementos de erro
  function createErrorElement(input) {
    let errorEl = input.parentElement.querySelector(".error-message");
    if (!errorEl) {
      errorEl = document.createElement("div");
      errorEl.className = "error-message";
      errorEl.id = `${input.id}-error`;
      input.parentElement.appendChild(errorEl);
    }
    return errorEl;
  }

  // Validar campo individual
  function validateField(input) {
    const errorEl = createErrorElement(input);
    const value = input.value.trim();
    let isValid = true;
    let errorMessage = "";

    // Validação de vazio
    if (input.required && !value) {
      isValid = false;
      errorMessage = "Este campo é obrigatório";
    }
    // Validação de email
    else if (input.type === "email" && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(value)) {
        isValid = false;
        errorMessage = "Email inválido";
      }
    }
    // Validação de telefone (Angola)
    else if (input.id === "telefone" && value) {
      const phoneRegex = /^(\+244)?9[1-9]\d{7}$/;
      if (!phoneRegex.test(value.replace(/\s/g, ""))) {
        isValid = false;
        errorMessage = "Telefone inválido (ex: +244925696002)";
      }
    }
    // Validação de tamanho mínimo
    else if (
      value.length > 0 &&
      input.minLength &&
      value.length < input.minLength
    ) {
      isValid = false;
      errorMessage = `Mínimo de ${input.minLength} caracteres`;
    }

    // Aplicar estado visual
    if (isValid && value) {
      input.classList.remove("error");
      input.classList.add("success");
      errorEl.classList.remove("visible");
    } else {
      input.classList.remove("success");
      if (errorMessage) {
        input.classList.add("error");
        errorEl.textContent = errorMessage;
        errorEl.classList.add("visible");
      } else {
        errorEl.classList.remove("visible");
      }
    }

    return isValid;
  }

  // Adicionar listeners
  inputs.forEach((input) => {
    // Validação ao perder foco
    input.addEventListener("blur", () => validateField(input));

    // Validação ao digitar (apenas após primeira tentativa)
    input.addEventListener("input", () => {
      if (
        input.classList.contains("error") ||
        input.classList.contains("success")
      ) {
        validateField(input);
      }
    });

    // Limpar erro ao começar a digitar
    input.addEventListener("focus", () => {
      if (input.classList.contains("error")) {
        input.classList.remove("error");
        const errorEl = input.parentElement.querySelector(".error-message");
        if (errorEl) errorEl.classList.remove("visible");
      }
    });
  });

  // Validação no submit
  form.addEventListener("submit", (e) => {
    let isFormValid = true;
    inputs.forEach((input) => {
      if (!validateField(input)) {
        isFormValid = false;
      }
    });

    if (!isFormValid) {
      e.preventDefault();
      e.stopPropagation();
      // Rolar para o primeiro campo inválido
      const firstInvalid = form.querySelector(".error");
      if (firstInvalid) {
        firstInvalid.scrollIntoView({ behavior: "smooth", block: "center" });
        firstInvalid.focus();
      }
    }
  });

  console.log("✓ Validação inline inicializada");
}
