/* Cookie / analytics consent gate — single source of truth for whether
   non-essential trackers (Microsoft Clarity, Google Analytics) may run.
   Nothing below loads until the visitor accepts; their choice is stored
   in localStorage under gm_consent ("accepted" | "rejected") and is not
   asked again until cleared. Reopen via window.gmOpenConsentBanner(). */
(function () {
  var STORAGE_KEY = 'gm_consent';
  var GA_MEASUREMENT_ID = 'G-4QCBHK4098';
  var CLARITY_PROJECT_ID = 'ximldvfgop';
  var bannerEl = null;

  function getConsent() {
    try { return localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
  }
  function setConsent(value) {
    try { localStorage.setItem(STORAGE_KEY, value); } catch (e) {}
  }

  function loadClarity() {
    (function (c, l, a, r, i, t, y) {
      c[a] = c[a] || function () { (c[a].q = c[a].q || []).push(arguments); };
      t = l.createElement(r); t.async = 1; t.src = 'https://www.clarity.ms/tag/' + i;
      y = l.getElementsByTagName(r)[0]; y.parentNode.insertBefore(t, y);
    })(window, document, 'clarity', 'script', CLARITY_PROJECT_ID);
  }

  function loadGA4() {
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.googletagmanager.com/gtag/js?id=' + GA_MEASUREMENT_ID;
    document.head.appendChild(s);
    window.dataLayer = window.dataLayer || [];
    function gtag() { window.dataLayer.push(arguments); }
    window.gtag = gtag;
    gtag('js', new Date());
    gtag('config', GA_MEASUREMENT_ID);
  }

  function loadAnalytics() {
    loadClarity();
    loadGA4();
  }

  function buildBanner() {
    var css =
      '.gmc { position:fixed; left:0; right:0; bottom:0; z-index:9999; background:#1C1C1C;\n' +
        'border-top:1px solid rgba(255,255,255,0.08); padding:1.5rem 7vw;\n' +
        'box-shadow:0 -12px 32px rgba(0,0,0,0.28); }\n' +
      '.gmc[hidden] { display:none; }\n' +
      '.gmc-inner { max-width:1440px; margin:0 auto; display:flex; align-items:center; justify-content:space-between; gap:2rem; flex-wrap:wrap; }\n' +
      '.gmc-text { font-family:"IBM Plex Sans",sans-serif; font-weight:300; font-size:0.875rem; line-height:1.7; color:rgba(255,255,255,0.72); max-width:760px; margin:0; }\n' +
      '.gmc-text a { color:#A5CC48; text-decoration:underline; text-underline-offset:2px; }\n' +
      '.gmc-text a:hover, .gmc-text a:focus-visible { color:#7EB828; }\n' +
      '.gmc-actions { display:flex; gap:0.75rem; flex-shrink:0; }\n' +
      '.gmc-btn { font-family:"Barlow Condensed",sans-serif; font-weight:600; font-size:0.9375rem; letter-spacing:0.04em;\n' +
        'text-transform:uppercase; padding:0.7rem 1.5rem; border-radius:2px; cursor:pointer; border:1px solid transparent;\n' +
        'transition:transform 0.15s ease, background 0.15s ease, border-color 0.15s ease; }\n' +
      '.gmc-btn:active { transform:translateY(1px); }\n' +
      '.gmc-accept { background:#7EB828; color:#111111; }\n' +
      '.gmc-accept:hover, .gmc-accept:focus-visible { background:#A5CC48; }\n' +
      '.gmc-reject { background:transparent; color:rgba(255,255,255,0.75); border-color:rgba(255,255,255,0.24); }\n' +
      '.gmc-reject:hover, .gmc-reject:focus-visible { border-color:rgba(255,255,255,0.5); color:#fff; }\n' +
      '.gmc-btn:focus-visible { outline:2px solid #A5CC48; outline-offset:2px; }\n' +
      '@media (max-width:720px) { .gmc-inner { flex-direction:column; align-items:flex-start; } .gmc-actions { width:100%; } .gmc-btn { flex:1; } }';

    var style = document.createElement('style');
    style.textContent = css;
    document.head.appendChild(style);

    var el = document.createElement('div');
    el.className = 'gmc';
    el.setAttribute('role', 'dialog');
    el.setAttribute('aria-label', 'Cookie consent');
    el.hidden = true;
    el.innerHTML =
      '<div class="gmc-inner">' +
        '<p class="gmc-text">We use essential cookies to run this site. With your consent, we also use analytics ' +
        '(Microsoft Clarity, Google Analytics) to understand how visitors use our site — these only load if you accept. ' +
        'See our <a href="/privacy_policy/privacy-policy.html#cookies">Privacy Policy</a> for details.</p>' +
        '<div class="gmc-actions">' +
          '<button type="button" class="gmc-btn gmc-reject" id="gmc-reject">Reject</button>' +
          '<button type="button" class="gmc-btn gmc-accept" id="gmc-accept">Accept</button>' +
        '</div>' +
      '</div>';
    document.body.appendChild(el);

    el.querySelector('#gmc-accept').addEventListener('click', function () {
      setConsent('accepted');
      el.hidden = true;
      loadAnalytics();
    });
    el.querySelector('#gmc-reject').addEventListener('click', function () {
      setConsent('rejected');
      el.hidden = true;
    });

    bannerEl = el;
    return el;
  }

  function init() {
    var consent = getConsent();
    if (consent === 'accepted') { loadAnalytics(); return; }
    if (consent === 'rejected') { return; }
    buildBanner().hidden = false;
  }

  window.gmOpenConsentBanner = function () {
    (bannerEl || buildBanner()).hidden = false;
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
