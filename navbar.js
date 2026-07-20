/* Shared site navigation — injected where the script tag sits.
   Uses root-absolute URLs so it works at any directory depth. */
(function () {
  var PAGES = [
    { label: 'PRODUCTS',      href: '/products.html' },
    { label: 'MANUFACTURING', href: '/manufacturing.html' },
    { label: 'ABOUT US',      href: '/about.html' },
    { label: 'PROJECTS',      href: '/projects.html' },
    { label: 'CONTACT',       href: '/contact.html' }
  ];

  var path = window.location.pathname.toLowerCase();
  function isActive(page) {
    if (page.href === '/products.html') {
      return path === '/products.html' || path.indexOf('/products/') === 0;
    }
    return path === page.href;
  }

  function linkTags(mobile) {
    var out = '';
    for (var i = 0; i < PAGES.length; i++) {
      var p = PAGES[i];
      out += '<a href="' + p.href + '" class="nav-link' + (isActive(p) ? ' active' : '') + '"' +
             (mobile ? ' onclick="toggleNav()"' : '') + '>' + p.label + '</a>\n';
    }
    return out;
  }

  var html =
    '<nav class="nav" role="navigation" aria-label="Main navigation">\n' +
    '  <div class="nav-inner">\n' +
    '    <a href="/index.html" aria-label="Green Med Ltd." style="display:flex; align-items:center; flex-shrink:0; text-decoration:none;">\n' +
    '      <img src="/brand_assets/GREENMED%20LOGO%20Horz.svg" alt="Green Med Ltd." style="height:69px; width:auto;" loading="eager">\n' +
    '    </a>\n' +
    '    <div class="nav-links">\n' + linkTags(false) + '</div>\n' +
    '    <a href="/contact.html" class="btn-nav" style="flex-shrink:0;">GET IN TOUCH</a>\n' +
    '    <button class="hamburger" id="ham" aria-label="Toggle menu" onclick="toggleNav()">\n' +
    '      <span></span><span></span><span></span>\n' +
    '    </button>\n' +
    '  </div>\n' +
    '</nav>\n' +
    '<div class="mobile-nav" id="mob-nav">\n' + linkTags(true) +
    '  <a href="/contact.html" class="btn-nav" style="width:fit-content; margin-top:0.5rem;" onclick="toggleNav()">GET IN TOUCH</a>\n' +
    '</div>\n';

  document.currentScript.insertAdjacentHTML('beforebegin', html);

  window.toggleNav = function () {
    document.getElementById('mob-nav').classList.toggle('open');
    document.getElementById('ham').classList.toggle('open');
  };
})();
