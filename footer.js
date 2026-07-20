/* Shared site footer — injected where the script tag sits.
   Self-contained: ships its own scoped CSS (gmf-*) and uses
   root-absolute URLs so it works at any directory depth. */
(function () {
  var css =
    '.gmf { background:#111111; padding:4rem 7vw 2.5rem; text-align:left; }\n' +
    '.gmf-wrap { max-width:1440px; margin:0 auto; }\n' +
    '.gmf-top { display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:3rem; margin-bottom:3rem; }\n' +
    '.gmf-brand { max-width:300px; }\n' +
    '.gmf-brand img { height:100px; width:auto; margin-bottom:1.25rem; display:block; }\n' +
    '.gmf-brand p { font-family:"IBM Plex Sans",sans-serif; font-weight:300; font-size:0.875rem; color:rgba(255,255,255,0.38); line-height:1.75; margin:0; }\n' +
    '.gmf-cols { display:flex; gap:4rem; flex-wrap:wrap; }\n' +
    '.gmf-head { font-family:"IBM Plex Mono",monospace; font-size:0.6875rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(255,255,255,0.25); margin-bottom:1.25rem; }\n' +
    '.gmf-link, .gmf-item { font-family:"Barlow Condensed",sans-serif; font-weight:600; font-size:0.9375rem; letter-spacing:0.05em; text-transform:uppercase; color:rgba(255,255,255,0.55); text-decoration:none; transition:color 0.2s; display:block; margin-bottom:0.75rem; }\n' +
    '.gmf-item { cursor:default; }\n' +
    'button.gmf-link { background:none; border:none; padding:0; font:inherit; letter-spacing:inherit; text-align:left; cursor:pointer; }\n' +
    'a.gmf-link:hover, a.gmf-link:focus-visible, button.gmf-link:hover, button.gmf-link:focus-visible { color:#A5CC48; }\n' +
    '.gmf-bottom { padding-top:2rem; border-top:1px solid rgba(255,255,255,0.07); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; }\n' +
    '.gmf-bottom p { font-family:"IBM Plex Mono",monospace; font-size:0.6875rem; color:rgba(255,255,255,0.28); margin:0; }\n' +
    '.gmf-tag { font-style:italic; color:rgba(255,255,255,0.18) !important; }\n' +
    '@media (max-width:900px) { .gmf { padding:4rem 1.5rem 2.5rem; } .gmf-top { flex-direction:column; } }';

  function col(head, items) {
    var out = '<div><div class="gmf-head">' + head + '</div>';
    for (var i = 0; i < items.length; i++) {
      var it = items[i];
      if (it.href) {
        out += '<a class="gmf-link" href="' + it.href + '">' + it.label + '</a>';
      } else if (it.id) {
        out += '<button type="button" class="gmf-link" id="' + it.id + '">' + it.label + '</button>';
      } else {
        out += '<span class="gmf-item">' + it.label + '</span>';
      }
    }
    return out + '</div>';
  }

  var html =
    '<footer class="gmf">' +
    '<div class="gmf-wrap">' +
    '<div class="gmf-top">' +
    '<div class="gmf-brand">' +
    '<img src="/brand_assets/GREENMED%20LOGO%20Vert.svg" alt="Green Med Ltd." loading="lazy">' +
    '<p>Principal Manufacturer, Systems Integrator &amp; Turnkey Laboratory Solutions Provider.</p>' +
    '</div>' +
    '<div class="gmf-cols">' +
    col('COMPANY', [
      { label: 'PRODUCTS',      href: '/products.html' },
      { label: 'MANUFACTURING', href: '/manufacturing.html' },
      { label: 'ABOUT US',      href: '/about.html' },
      { label: 'PROJECTS',      href: '/projects.html' },
      { label: 'CONTACT',       href: '/contact.html' }
    ]) +
    col('MANUFACTURING', [
      { label: 'MEDICAL DEVICES',           href: '/manufacturing.html' },
      { label: 'IVD & LABORATORY PRODUCTS', href: '/products.html' },
      { label: 'QUALITY & REGULATORY COMPLIANCE' }
    ]) +
    col('SERVICES', [
      { label: 'BIOMEDICAL ENGINEERING' },
      { label: 'LAB DESIGN & TURNKEY PROJECTS' },
      { label: 'INSTALLATION & COMMISSIONING' },
      { label: 'MAINTENANCE, CALIBRATION & VALIDATION' },
      { label: 'SPARE PARTS & TECHNICAL SUPPORT' }
    ]) +
    col('LEGAL', [
      { label: 'PRIVACY POLICY', href: '/privacy_policy/privacy-policy.html' },
      { label: 'COOKIE PREFERENCES', id: 'gmf-cookie-prefs' }
    ]) +
    '</div>' +
    '</div>' +
    '<div class="gmf-bottom">' +
    '<p>© ' + new Date().getFullYear() + ' Green Med Ltd. · Registered in England &amp; Wales No. 13350293 · All rights reserved.</p>' +
    '<p class="gmf-tag">"From Concept to Completion."</p>' +
    '</div>' +
    '</div>' +
    '</footer>';

  var style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  document.currentScript.insertAdjacentHTML('beforebegin', html);

  var cookiePrefsBtn = document.getElementById('gmf-cookie-prefs');
  if (cookiePrefsBtn) {
    cookiePrefsBtn.addEventListener('click', function () {
      if (typeof window.gmOpenConsentBanner === 'function') { window.gmOpenConsentBanner(); }
    });
  }
})();
