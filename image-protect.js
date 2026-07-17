/* Central image protection — deterrents against casual downloading.
   Managed in one place; included on every page like navbar.js/footer.js.
   Note: no client-side measure can fully prevent downloading. */
(function () {
  // 1. CSS layer: no drag, no select, no long-press save sheet on iOS
  var style = document.createElement('style');
  style.textContent =
    'img { -webkit-user-drag: none; user-drag: none; ' +
    '-webkit-user-select: none; user-select: none; ' +
    '-webkit-touch-callout: none; }';
  document.head.appendChild(style);

  // 2. Block right-click on images only (text/links keep their menu)
  document.addEventListener('contextmenu', function (e) {
    if (e.target && e.target.closest && e.target.closest('img, picture, figure, .team-avatar, .founder-portrait')) {
      e.preventDefault();
    }
  });

  // 3. Block drag-and-drop copying of images
  document.addEventListener('dragstart', function (e) {
    if (e.target && e.target.tagName === 'IMG') e.preventDefault();
  });
})();
