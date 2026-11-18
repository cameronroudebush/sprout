function updateCopyrightYear() {
  const yearEl = document.getElementById("copyright-year");
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }
}

// Supports both standard page loads and Zensical's instant navigation.
if (typeof document$ !== "undefined") {
  document$.subscribe(updateCopyrightYear);
} else {
  document.addEventListener("DOMContentLoaded", updateCopyrightYear);
}
