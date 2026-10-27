/* ============================================================
   Siccsegv Blog — post page behaviour
   ------------------------------------------------------------
   Loaded with `defer` on post pages only.

   Responsibilities
     1. Copy buttons for code blocks
     2. Reading progress bar
     3. Back-to-top visibility
     4. Table-of-contents scrollspy

   No frameworks, no dependencies. Every feature degrades
   gracefully if JavaScript is disabled.
   ============================================================ */

(function () {
  "use strict";

  /* ----------------------------------------------------------
     1. Copy buttons
     ---------------------------------------------------------- */

  document.querySelectorAll("[data-copy]").forEach(function (button) {
    button.addEventListener("click", async function () {
      var block = button.closest(".code-block");
      if (!block) return;

      // With line numbers enabled, Chroma renders a table. Copy only the
      // code column so the numbers never end up on the clipboard.
      var code =
        block.querySelector("td.lntd:last-child code") ||
        block.querySelector("code");

      if (!code) return;

      try {
        await navigator.clipboard.writeText(code.textContent);
        button.textContent = "Copied";
      } catch (error) {
        button.textContent = "Failed";
      }

      window.setTimeout(function () {
        button.textContent = "Copy";
      }, 1500);
    });
  });

  /* ----------------------------------------------------------
     2. Reading progress bar
     3. Back-to-top visibility
     ---------------------------------------------------------- */

  var progressBar = document.querySelector("[data-reading-progress]");
  var backToTop = document.querySelector("[data-back-to-top]");

  function updateScrollState() {
    var root = document.documentElement;
    var maxScroll = root.scrollHeight - root.clientHeight;

    if (progressBar) {
      var percent = maxScroll > 0 ? (root.scrollTop / maxScroll) * 100 : 0;
      progressBar.style.width = percent + "%";
    }

    if (backToTop) {
      backToTop.classList.toggle("is-visible", root.scrollTop > 600);
    }
  }

  document.addEventListener("scroll", updateScrollState, { passive: true });
  updateScrollState();

  /* ----------------------------------------------------------
     3a. Collapse the table of contents on small screens
     ---------------------------------------------------------- */

  var toc = document.querySelector(".toc");

  if (toc && window.matchMedia("(max-width: 1279px)").matches) {
    toc.removeAttribute("open");
  }

  /* ----------------------------------------------------------
     4. Table-of-contents scrollspy
     ---------------------------------------------------------- */

  var tocLinks = Array.prototype.slice.call(
    document.querySelectorAll(".toc__link")
  );

  if (tocLinks.length === 0 || !("IntersectionObserver" in window)) return;

  // Map each heading element to its matching TOC link.
  var linkByHeading = new Map();

  tocLinks.forEach(function (link) {
    var id = link.getAttribute("href");
    if (!id || id.charAt(0) !== "#") return;

    var heading = document.getElementById(id.slice(1));
    if (heading) linkByHeading.set(heading, link);
  });

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;

        tocLinks.forEach(function (link) {
          link.classList.remove("is-active");
          link.removeAttribute("aria-current");
        });

        var activeLink = linkByHeading.get(entry.target);
        if (activeLink) {
          activeLink.classList.add("is-active");
          activeLink.setAttribute("aria-current", "location");
        }
      });
    },
    // Treat a heading as "current" once it reaches the upper third.
    { rootMargin: "0px 0px -70% 0px", threshold: 0 }
  );

  linkByHeading.forEach(function (_link, heading) {
    observer.observe(heading);
  });
})();
