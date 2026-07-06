const fs = require('fs');
const path = require('path');

// ── Product data ─────────────────────────────────────────────────────────
// products.html owns the canonical PRODUCTS array (name/cat/sub/catalog/brand/
// pkg/url/specs) — edit it there. This script extracts it at build time so
// product detail pages and the catalog listing can never drift apart.
function loadProducts() {
  const html = fs.readFileSync(path.join(__dirname, 'products.html'), 'utf8');
  const m = html.match(/const PRODUCTS = (\[[\s\S]*?\n {4}\]);/);
  if (!m) throw new Error('Could not find PRODUCTS array in products.html');
  return eval(m[1]);
}
const PRODUCTS = loadProducts();

// ── Russian translations (name/sub/specs per product `no`) ──────────────────
// Edit translations.ru.json to update Russian product copy — this file is
// the single source of truth for RU product pages, just like PRODUCTS above
// is for EN. Re-run this script after editing either file.
const RU = require('./translations.ru.json');

// ── Helpers ────────────────────────────────────────────────────────────────
const CAT_PREFIX = {
  "Genomik & Sekanslama": "GRN01",
  "Biyokimya":            "GRN03",
  "Pipetleme":            "GRN05",
  "Su Arıtma":            "GRN07",
  "Genel Sarf":           "GRN10",
};
const CAT_LABEL = {
  "Genomik & Sekanslama": "Genomics",
  "Biyokimya":            "Biochemistry",
  "Genel Sarf":           "General",
  "Pipetleme":            "Pipetting",
  "Su Arıtma":            "Water Purif.",
};
const CAT_LABEL_RU = {
  "Genomik & Sekanslama": "Геномика",
  "Biyokimya":            "Биохимия",
  "Genel Sarf":           "Общий",
  "Pipetleme":            "Пипетирование",
  "Su Arıtma":            "Водоочистка",
};
const BADGE_CLASS = {
  "Genomik & Sekanslama": "badge-genomics",
  "Biyokimya":            "badge-biochem",
  "Genel Sarf":           "badge-general",
  "Pipetleme":            "badge-pipetting",
  "Su Arıtma":            "badge-water",
};

// One product's live URL slug doesn't match slugify(name) because the name
// includes "7/15" (kept in the displayed title) which was dropped from the
// folder name when the page was first created. Preserve that on regen.
const SLUG_OVERRIDE = {
  33: 'reverse-osmosis-cartridge-for-purelab-option-r',
};

const DOMAIN = 'https://www.greenmedltduk.com';
const OG_IMAGE = `${DOMAIN}/Photos/og-image.jpg`;

function fullCatalog(p) {
  return p.catalog || CAT_PREFIX[p.cat];
}

function slugify(name) {
  return name
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')   // strip non-word chars (keep hyphens)
    .replace(/[\s_]+/g, '-')    // spaces/underscores → hyphens
    .replace(/-{2,}/g, '-')     // collapse multiple hyphens
    .replace(/^-+|-+$/g, '')    // trim leading/trailing hyphens
    .substring(0, 80);          // keep URLs reasonable
}

function escHtml(str) {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function specsToHtml(specs) {
  if (!specs) return '';
  return specs
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br>');
}

// Plain-text (no markup) rendering of specs, for JSON-LD / OG descriptions.
function descPlain(specs) {
  if (!specs) return '';
  return specs.replace(/\n\n/g, ' ').replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
}

function metaDesc(p) {
  const base = `${p.name} — ${p.sub}. Catalog: ${fullCatalog(p)}. Brand: ${p.brand}. Laboratory supply from Green Med Ltd.`;
  return base.substring(0, 160);
}

function metaDescRu(ru, catLabelRu, refNo) {
  const base = `${ru.name} — ${catLabelRu}. Артикул: ${refNo}. Лабораторные реагенты и оборудование от Green Med Ltd.`;
  return base.substring(0, 160);
}

// Shared <head> block: Yandex Metrika, favicon, canonical/OG/Twitter, hreflang.
function headExtras({ canonicalUrl, altUrl, lang, title, desc }) {
  const locale = lang === 'ru' ? 'ru_RU' : 'en_GB';
  const enUrl = lang === 'ru' ? altUrl : canonicalUrl;
  const ruUrl = lang === 'ru' ? canonicalUrl : altUrl;
  return `  <!-- Yandex.Metrika counter -->
  <script type="text/javascript">
      (function(m,e,t,r,i,k,a){
          m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
          m[i].l=1*new Date();
          for (var j = 0; j < document.scripts.length; j++) {if (document.scripts[j].src === r) { return; }}
          k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a)
      })(window, document,'script','https://mc.yandex.ru/metrika/tag.js?id=108990520', 'ym');

      ym(108990520, 'init', {ssr:true, webvisor:true, clickmap:true, ecommerce:"dataLayer", referrer: document.referrer, url: location.href, accurateTrackBounce:true, trackLinks:true});
  </script>
  <noscript><div><img src="https://mc.yandex.ru/watch/108990520" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
  <!-- /Yandex.Metrika counter -->
  <meta charset="UTF-8">
  <link rel="icon" type="image/svg+xml" href="/brand_assets/fav_icon-02.svg">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <meta name="description" content="${escHtml(desc)}">
  <link rel="canonical" href="${canonicalUrl}">

  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Green Med Ltd.">
  <meta property="og:locale" content="${locale}">
  <meta property="og:title" content="${escHtml(title.replace(/ &mdash; Green Med Ltd\.$/, ''))}">
  <meta property="og:description" content="${escHtml(desc)}">
  <meta property="og:image" content="${OG_IMAGE}">
  <meta property="og:url" content="${canonicalUrl}">

  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escHtml(title.replace(/ &mdash; Green Med Ltd\.$/, ''))}">
  <meta name="twitter:description" content="${escHtml(desc)}">
  <meta name="twitter:image" content="${OG_IMAGE}">
    <link rel="alternate" hreflang="en" href="${enUrl}" />
  <link rel="alternate" hreflang="ru" href="${ruUrl}" />
  <link rel="alternate" hreflang="ru-TM" href="${ruUrl}" />
  <link rel="alternate" hreflang="x-default" href="${enUrl}" />`;
}

// Shared CSS shared between EN/RU product pages (identical either way).
const PAGE_STYLE = `  <style>
    :root {
      --c-black:  #1C1C1C;
      --c-anthra: #2B2B2B;
      --c-dark:   #4A4A4A;
      --c-muted:  #8A8A8A;
      --c-rule:   #E8E8E8;
      --c-bg:     #F7F8F2;
      --c-white:  #FFFFFF;
      --c-footer: #111111;
      --gm-300:   #A5CC48;
      --gm-400:   #7EB828;
      --gm-500:   #619A18;
      --gm-600:   #487A10;
      --gm-800:   #193C04;
      --px: 7vw;
    }
    *, *::before, *::after { box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body {
      font-family: 'IBM Plex Sans', sans-serif;
      font-weight: 300;
      background: var(--c-bg);
      color: var(--c-dark);
      line-height: 1.8;
      -webkit-font-smoothing: antialiased;
    }

    /* Nav */
    .nav {
      position: fixed; top: 0; left: 0; right: 0;
      height: 64px; z-index: 100;
      backdrop-filter: blur(16px);
      background: rgba(247, 248, 242, 0.96);
      border-bottom: 1px solid rgba(232, 232, 232, 0.8);
    }
    .nav-inner {
      max-width: 1440px; margin: 0 auto;
      padding: 0 var(--px); height: 100%;
      display: flex; align-items: center;
      justify-content: space-between; gap: 2rem;
    }
    .nav-links { display: flex; align-items: center; gap: 2.5rem; }
    .nav-link {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.875rem;
      letter-spacing: 0.1em; text-transform: uppercase;
      color: var(--c-dark); text-decoration: none;
      transition: color 0.2s;
    }
    .nav-link:hover { color: var(--gm-500); }
    .nav-link:focus-visible { outline: 2px solid var(--gm-400); outline-offset: 3px; }
    .nav-link.active { color: var(--gm-500); }
    .btn-nav {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.875rem;
      letter-spacing: 0.08em; text-transform: uppercase;
      background: var(--gm-400); color: #fff;
      padding: 0.5rem 1.375rem; text-decoration: none;
      transition: background 0.2s;
    }
    .btn-nav:hover { background: var(--gm-600); }

    /* Page header */
    .page-header {
      background: var(--c-anthra);
      padding: 7rem var(--px) 4rem;
      position: relative; overflow: hidden;
    }
    .page-header::before {
      content: '';
      position: absolute; inset: 0;
      background-image:
        linear-gradient(rgba(126,184,40,0.07) 1px, transparent 1px),
        linear-gradient(90deg, rgba(126,184,40,0.07) 1px, transparent 1px);
      background-size: 52px 52px;
      pointer-events: none;
    }
    .page-header-inner { position: relative; z-index: 1; max-width: 1440px; margin: 0 auto; }
    .eyebrow {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.8125rem;
      letter-spacing: 0.18em; text-transform: uppercase;
      color: var(--gm-300);
      display: flex; align-items: center; gap: 0.875rem;
      margin-bottom: 1.25rem;
    }
    .eyebrow::before {
      content: ''; display: block;
      width: 2rem; height: 2px;
      background: var(--gm-300); flex-shrink: 0;
    }

    /* Content */
    .content-wrap {
      max-width: 1440px; margin: 0 auto;
      padding: 3rem var(--px) 6rem;
      display: grid;
      grid-template-columns: 1fr 360px;
      gap: 3rem;
      align-items: start;
    }

    /* Details grid */
    .details-grid {
      display: grid; grid-template-columns: repeat(3, 1fr);
      gap: 0;
      border: 1px solid var(--c-rule);
      margin-bottom: 2rem;
    }
    .detail-item {
      padding: 1.25rem 1.5rem;
      border-right: 1px solid var(--c-rule);
      display: flex; flex-direction: column; gap: 0.375rem;
    }
    .detail-item:last-child { border-right: none; }
    .detail-label {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.6875rem;
      letter-spacing: 0.15em; text-transform: uppercase;
      color: var(--c-muted);
    }
    .detail-value {
      font-family: 'IBM Plex Mono', monospace;
      font-size: 0.8125rem; color: var(--c-dark);
      line-height: 1.4;
    }

    /* Badge */
    .card-badge {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.6875rem;
      letter-spacing: 0.1em; text-transform: uppercase;
      padding: 0.25rem 0.625rem;
      display: inline-block;
    }
    .badge-genomics  { background: rgba(126,184,40,0.12); color: var(--gm-600); }
    .badge-biochem   { background: rgba(25,60,4,0.07);    color: var(--gm-800); }
    .badge-general   { background: rgba(74,74,74,0.08);   color: var(--c-dark); }
    .badge-pipetting { background: rgba(165,204,72,0.15); color: var(--gm-600); }
    .badge-water     { background: rgba(72,122,16,0.10);  color: var(--gm-700); }

    /* Pricing note */
    .pricing-note {
      padding: 1.25rem 1.5rem;
      border-left: 3px solid var(--gm-400);
      background: rgba(126,184,40,0.05);
      margin-top: 2rem;
      font-size: 0.9375rem; color: var(--c-dark); line-height: 1.65;
    }

    /* Specs */
    .specs-section { margin-bottom: 0; }
    .specs-title {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 700; font-size: 0.8125rem;
      letter-spacing: 0.15em; text-transform: uppercase;
      color: var(--gm-500);
      display: flex; align-items: center; gap: 0.75rem;
      margin-bottom: 1rem;
    }
    .specs-title::after { content: ''; flex: 1; height: 1px; background: var(--c-rule); }
    .specs-body {
      font-size: 0.9rem; color: var(--c-dark);
      line-height: 1.75;
    }

    /* Sidebar / quote form */
    .sidebar { display: flex; flex-direction: column; gap: 1.25rem; }
    .back-link {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.8125rem;
      letter-spacing: 0.1em; text-transform: uppercase;
      color: var(--c-muted); text-decoration: none;
      display: inline-flex; align-items: center; gap: 0.5rem;
      transition: color 0.18s;
    }
    .back-link:hover { color: var(--c-dark); }
    .quote-card {
      background: var(--c-white);
      border: 1px solid var(--c-rule);
      padding: 1.75rem;
    }
    .quote-card-title {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 700; font-size: 0.8125rem;
      letter-spacing: 0.15em; text-transform: uppercase;
      color: var(--gm-500);
      display: flex; align-items: center; gap: 0.75rem;
      margin-bottom: 1.25rem;
    }
    .quote-card-title::after { content: ''; flex: 1; height: 1px; background: var(--c-rule); }
    .qform { display: flex; flex-direction: column; gap: 0.875rem; }
    .qform label {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 600; font-size: 0.75rem;
      letter-spacing: 0.12em; text-transform: uppercase;
      color: var(--c-muted); display: block; margin-bottom: 0.375rem;
    }
    .qform input, .qform textarea {
      font-family: 'IBM Plex Sans', sans-serif;
      font-size: 0.875rem; font-weight: 300;
      width: 100%; background: var(--c-bg);
      border: 1px solid var(--c-rule); color: var(--c-dark);
      padding: 0.625rem 0.875rem; outline: none;
      transition: border-color 0.18s; resize: vertical;
    }
    .qform input::placeholder, .qform textarea::placeholder { color: var(--c-muted); }
    .qform input:focus, .qform textarea:focus { border-color: var(--gm-400); }
    .qform textarea { min-height: 90px; }
    .qform-submit {
      font-family: 'Barlow Condensed', sans-serif;
      font-weight: 700; font-size: 0.9375rem;
      letter-spacing: 0.1em; text-transform: uppercase;
      background: var(--gm-400); color: #fff;
      padding: 0.875rem 1.75rem; border: none; cursor: pointer;
      width: 100%; transition: background 0.18s;
    }
    .qform-submit:hover { background: var(--gm-600); }
    .qform-submit:focus-visible { outline: 2px solid var(--gm-400); outline-offset: 2px; }
    .qform-success {
      display: none; padding: 1.25rem 1.5rem;
      background: rgba(126,184,40,0.08);
      border-left: 3px solid var(--gm-400);
      font-size: 0.9375rem; color: var(--c-dark); line-height: 1.6;
    }
    .qform-success.visible { display: block; }
    .consent-check { position: relative; }
    .consent-check input[type="checkbox"] {
      position: absolute; left: 0; top: 2px;
      width: 16px; height: 16px; margin: 0;
      opacity: 0; cursor: pointer; z-index: 1;
    }
    .consent-check label {
      position: relative; display: block;
      padding-left: 26px; cursor: pointer;
    }
    .consent-check label::before {
      content: ''; position: absolute; left: 0; top: 1px;
      width: 16px; height: 16px;
      border: 1.5px solid var(--c-muted); border-radius: 3px;
      background: #fff;
      transition: background 0.15s, border-color 0.15s;
    }
    .consent-check input:checked + label::before {
      background: var(--gm-400); border-color: var(--gm-400);
    }
    .consent-check input:checked + label::after {
      content: ''; position: absolute; left: 5px; top: 5px;
      width: 5px; height: 9px;
      border: solid #fff; border-width: 0 2px 2px 0;
      transform: rotate(45deg);
    }
    .consent-check input:focus-visible + label::before {
      outline: 2px solid var(--gm-400); outline-offset: 2px;
    }

    /* Footer */
    footer { background: var(--c-footer); padding: 2.5rem var(--px); }
    .footer-inner {
      max-width: 1440px; margin: 0 auto;
      display: flex; align-items: center;
      justify-content: space-between; gap: 2rem; flex-wrap: wrap;
    }
    .footer-copy { font-size: 0.8125rem; color: rgba(255,255,255,0.35); }

    /* Mobile nav */
    .hamburger {
      display: none; flex-direction: column; gap: 5px;
      cursor: pointer; background: none; border: none; padding: 4px;
    }
    .hamburger span {
      display: block; width: 22px; height: 2px;
      background: var(--c-black); transition: transform 0.2s, opacity 0.2s;
    }
    .hamburger.open span:nth-child(1) { transform: translateY(7px) rotate(45deg); }
    .hamburger.open span:nth-child(2) { opacity: 0; }
    .hamburger.open span:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }
    .mobile-nav {
      display: none;
      position: fixed; top: 64px; left: 0; right: 0; z-index: 99;
      background: rgba(247,248,242,0.98); backdrop-filter: blur(16px);
      border-bottom: 1px solid var(--c-rule);
      padding: 1.75rem var(--px);
      flex-direction: column; gap: 1.25rem;
    }
    .mobile-nav.open { display: flex; }

    @media (max-width: 1024px) {
      .nav-links { display: none; }
      .btn-nav   { display: none; }
      .hamburger { display: flex; }
    }
    @media (max-width: 900px) {
      .content-wrap { grid-template-columns: 1fr; }
      .details-grid { grid-template-columns: 1fr 1fr; }
      .detail-item:nth-child(3) { border-right: none; }
    }
    @media (max-width: 768px) {
      :root { --px: 1.5rem; }
      .details-grid { grid-template-columns: 1fr; }
      .detail-item { border-right: none; border-bottom: 1px solid var(--c-rule); }
      .detail-item:last-child { border-bottom: none; }
    }
  </style>`;

function jsonLd({ name, descriptionPlain, catLabel, refNo, canonicalUrl }) {
  return `  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Product",
    "name": "${name.replace(/"/g, '\\"')}",
    "image": "${DOMAIN}/Photos/header-lab.webp",
    "description": "${descriptionPlain.replace(/"/g, '\\"')}",
    "category": "${catLabel}",
    "sku": "${refNo}",
    "brand": {
      "@type": "Brand",
      "name": "Green Med Ltd"
    },
    "offers": {
      "@type": "Offer",
      "availability": "https://schema.org/InStock",
      "priceSpecification": {
        "@type": "PriceSpecification",
        "description": "Available upon request"
      },
      "url": "${canonicalUrl}",
      "seller": {
        "@type": "Organization",
        "name": "Green Med Ltd",
        "url": "${DOMAIN}"
      }
    }
  }
  </script>`;
}

// ── EN page template ─────────────────────────────────────────────────────
function buildPage(p, slug) {
  const refNo     = fullCatalog(p);
  const catLabel  = CAT_LABEL[p.cat];
  const badgeCls  = BADGE_CLASS[p.cat];
  const hasSpecs  = !!p.specs;

  const canonicalUrl = `${DOMAIN}/products/${slug}.html`;
  const altUrl = `${DOMAIN}/ru/products/${slug}/`;
  const title = `${escHtml(p.name)} &mdash; Green Med Ltd.`;

  return `<!DOCTYPE html>
<html lang="en">
<head>
${headExtras({ canonicalUrl, altUrl, lang: 'en', title, desc: metaDesc(p) })}
<link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=IBM+Plex+Mono:wght@400&family=IBM+Plex+Sans:wght@300;400&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        fontFamily: {
          barlow: ['Barlow Condensed', 'sans-serif'],
          ibm:    ['IBM Plex Sans',    'sans-serif'],
          mono:   ['IBM Plex Mono',    'monospace'],
        },
        extend: { colors: { 'gm-300':'#A5CC48','gm-400':'#7EB828','gm-500':'#619A18','gm-600':'#487A10','gm-800':'#193C04' } }
      }
    }
  </script>
${PAGE_STYLE}
${jsonLd({ name: p.name, descriptionPlain: descPlain(p.specs), catLabel, refNo, canonicalUrl })}
</head>
<body>

<nav class="nav" role="navigation" aria-label="Main navigation">
  <div class="nav-inner">
    <a href="../index.html" style="display:flex; align-items:center; flex-shrink:0; text-decoration:none;">
      <img src="../brand_assets/GREENMED LOGO Horz.svg" alt="Green Med Ltd." style="height:69px; width:auto;" loading="eager">
    </a>
    <div class="nav-links">
      <a href="../about.html"          class="nav-link">ABOUT</a>
      <a href="../index.html#services" class="nav-link">SERVICES</a>
      <a href="../projects.html"       class="nav-link">PROJECTS</a>
      <a href="../products.html"       class="nav-link active">PRODUCTS</a>
      <a href="../index.html#contact"  class="nav-link">CONTACT</a>
    </div>
    <a href="../index.html#contact" class="btn-nav" style="flex-shrink:0;">GET IN TOUCH</a>
    <button class="hamburger" id="ham" aria-label="Toggle menu" onclick="toggleNav()">
      <span></span><span></span><span></span>
    </button>
  </div>
</nav>

<div class="mobile-nav" id="mob-nav">
  <a href="../about.html"          class="nav-link" onclick="toggleNav()">ABOUT</a>
  <a href="../index.html#services" class="nav-link" onclick="toggleNav()">SERVICES</a>
  <a href="../projects.html"       class="nav-link" onclick="toggleNav()">PROJECTS</a>
  <a href="../products.html"       class="nav-link active" onclick="toggleNav()">PRODUCTS</a>
  <a href="../index.html#contact"  class="nav-link" onclick="toggleNav()">CONTACT</a>
  <a href="../index.html#contact"  class="btn-nav" style="width:fit-content; margin-top:0.5rem;" onclick="toggleNav()">GET IN TOUCH</a>
</div>

<header class="page-header">
  <div class="page-header-inner">
    <div class="eyebrow">Product Detail</div>
    <h1 style="font-family:'Barlow Condensed',sans-serif; font-weight:800; font-size:clamp(1.75rem,4vw,3rem); color:#fff; line-height:1.1; letter-spacing:-0.025em; margin:0 0 0.75rem;">${escHtml(p.name)}</h1>
    <p style="font-size:1rem; color:rgba(255,255,255,0.5); max-width:640px; margin:0;">${escHtml(p.sub)}</p>
  </div>
</header>

<div class="content-wrap">
  <div>
    <div style="display:flex; align-items:center; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap;">
      <span class="card-badge ${badgeCls}">${catLabel}</span>
      <span style="font-family:'IBM Plex Mono',monospace; font-size:0.75rem; color:var(--c-muted);">#${String(p.no).padStart(2,'0')}</span>
    </div>
    <div class="details-grid">
      <div class="detail-item"><span class="detail-label">Category</span><span class="detail-value">${catLabel}</span></div>
      <div class="detail-item"><span class="detail-label">Reference No</span><span class="detail-value">${escHtml(refNo)}</span></div>
      <div class="detail-item"><span class="detail-label">Packaging</span><span class="detail-value">${escHtml(p.pkg)}</span></div>
    </div>
${hasSpecs ? `      <div class="specs-section">
        <p class="specs-title">Technical Specifications</p>
        <div class="specs-body">${specsToHtml(p.specs)}</div>
      </div>

` : ''}    <div class="pricing-note">
      Pricing information is available upon request. Fill in the form and our team will get back to you with a personalised quote.
    </div>
  </div>

  <div class="sidebar">
    <a href="../products.html" class="back-link">&#8592; Back to Catalogue</a>
    <div class="quote-card">
      <p class="quote-card-title">Request a Quote</p>
      <div class="qform-success" id="quoteSuccess">Thank you &mdash; your request has been received. Our team will contact you shortly.</div>
      <form class="qform" id="quoteForm" onsubmit="submitQuote(event)">
        <input type="hidden" name="_form" value="quote">
        <input type="text" name="website" tabindex="-1" autocomplete="off" style="position:absolute; left:-9999px; width:1px; height:1px; opacity:0;" aria-hidden="true">
        <div><label for="qName">Full Name *</label><input type="text" id="qName" name="name" placeholder="Your name" required></div>
        <div><label for="qEmail">Email *</label><input type="email" id="qEmail" name="email" placeholder="your@email.com" required></div>
        <div><label for="qCompany">Organisation</label><input type="text" id="qCompany" name="company" placeholder="Lab / Institution"></div>
        <div><label for="qPhone">Phone</label><input type="tel" id="qPhone" name="phone" placeholder="+44 ..."></div>
        <div><label for="qMessage">Message</label><textarea id="qMessage" name="message" placeholder="Additional requirements, quantity, delivery info&hellip;"></textarea></div>
        <input type="hidden" name="product" value="${escHtml(refNo + ' — ' + p.name)}">
        <div class="consent-check">
          <input type="checkbox" id="gdpr-consent" name="gdpr_consent" required>
          <label for="gdpr-consent" style="font-size:0.8125rem; color:var(--c-muted); line-height:1.6; text-transform:none; letter-spacing:0;">
            I agree to be contacted by Green Med Ltd. and for my personal data to be processed in accordance with the
            <a href="../privacy_policy/privacy-policy.html" style="color:var(--gm-500); text-decoration:underline;">Privacy Policy</a>. *
          </label>
        </div>
        <button type="submit" class="qform-submit">Send Request</button>
      </form>
    </div>
  </div>
</div>

<footer>
  <div class="footer-inner">
    <img src="../brand_assets/GREENMED LOGO Vert.svg" alt="Green Med Ltd." style="height:60px; width:auto; opacity:0.55;" loading="lazy">
    <p class="footer-copy">&copy; 2025 Green Med Ltd. &middot; Registered in England &amp; Wales No. 13350293 &middot; All rights reserved.</p>
    <a href="../privacy_policy/privacy-policy.html" style="font-family:'IBM Plex Mono',monospace; font-size:0.75rem; color:rgba(255,255,255,0.35); text-decoration:none; letter-spacing:0.06em; transition:color 0.2s;" onmouseover="this.style.color='rgba(165,204,72,0.8)'" onmouseout="this.style.color='rgba(255,255,255,0.35)'">Privacy Policy</a>
  </div>
</footer>

<script>
  function submitQuote(e) {
    e.preventDefault();
    var form = document.getElementById('quoteForm');
    var btn = form.querySelector('.qform-submit');
    var originalLabel = btn.textContent;
    btn.disabled = true;
    btn.textContent = 'SENDING…';
    fetch('/form-handler.php', { method: 'POST', body: new FormData(form) })
      .then(function(res) { return res.json().catch(function () { return { ok: false }; }); })
      .then(function(data) {
        if (!data.ok) throw new Error(data.error || 'Send failed');
        document.getElementById('quoteForm').style.display = 'none';
        document.getElementById('quoteSuccess').classList.add('visible');
      })
      .catch(function() {
        alert('Sorry — your request could not be sent. Please email us directly at support@greenmedltduk.com.');
        btn.disabled = false;
        btn.textContent = originalLabel;
      });
  }
  function toggleNav() {
    document.getElementById('mob-nav').classList.toggle('open');
    document.getElementById('ham').classList.toggle('open');
  }
</script>
</body>
</html>`;
}

// ── RU page template ─────────────────────────────────────────────────────
function buildPageRu(p, slug, ru) {
  const refNo     = fullCatalog(p);
  const catLabel  = CAT_LABEL_RU[p.cat];
  const badgeCls  = BADGE_CLASS[p.cat];
  const hasSpecs  = !!ru.specs;

  const canonicalUrl = `${DOMAIN}/ru/products/${slug}/`;
  const altUrl = `${DOMAIN}/products/${slug}.html`;
  const title = `${escHtml(ru.name)} — Green Med Ltd.`;

  return `<!DOCTYPE html>
<html lang="ru">
<head>
${headExtras({ canonicalUrl, altUrl, lang: 'ru', title, desc: metaDescRu(ru, catLabel, refNo) })}
<link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;800&family=IBM+Plex+Mono:wght@400&family=IBM+Plex+Sans:wght@300;400&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        fontFamily: {
          barlow: ['Barlow Condensed', 'sans-serif'],
          ibm:    ['IBM Plex Sans',    'sans-serif'],
          mono:   ['IBM Plex Mono',    'monospace'],
        },
        extend: { colors: { 'gm-300':'#A5CC48','gm-400':'#7EB828','gm-500':'#619A18','gm-600':'#487A10','gm-800':'#193C04' } }
      }
    }
  </script>
${PAGE_STYLE}
${jsonLd({ name: ru.name, descriptionPlain: descPlain(ru.specs), catLabel, refNo, canonicalUrl })}
</head>
<body>

<nav class="nav" role="navigation" aria-label="Основная навигация">
  <div class="nav-inner">
    <a href="../../../index.html" style="display:flex; align-items:center; flex-shrink:0; text-decoration:none;">
      <img src="../../../brand_assets/GREENMED LOGO Horz.svg" alt="Green Med Ltd." style="height:69px; width:auto;" loading="eager">
    </a>
    <div class="nav-links">
      <a href="../../../about.html"          class="nav-link">О НАС</a>
      <a href="../../../index.html#services" class="nav-link">УСЛУГИ</a>
      <a href="../../../projects.html"       class="nav-link">ПРОЕКТЫ</a>
      <a href="../../../products.html"       class="nav-link active">ПРОДУКТЫ</a>
      <a href="../../../index.html#contact"  class="nav-link">КОНТАКТ</a>
    </div>
    <a href="../../../index.html#contact" class="btn-nav" style="flex-shrink:0;">СВЯЗАТЬСЯ</a>
    <button class="hamburger" id="ham" aria-label="Открыть меню" onclick="toggleNav()">
      <span></span><span></span><span></span>
    </button>
  </div>
</nav>

<div class="mobile-nav" id="mob-nav">
  <a href="../../../about.html"          class="nav-link" onclick="toggleNav()">О НАС</a>
  <a href="../../../index.html#services" class="nav-link" onclick="toggleNav()">УСЛУГИ</a>
  <a href="../../../projects.html"       class="nav-link" onclick="toggleNav()">ПРОЕКТЫ</a>
  <a href="../../../products.html"       class="nav-link active" onclick="toggleNav()">ПРОДУКТЫ</a>
  <a href="../../../index.html#contact"  class="nav-link" onclick="toggleNav()">КОНТАКТ</a>
  <a href="../../../index.html#contact"  class="btn-nav" style="width:fit-content; margin-top:0.5rem;" onclick="toggleNav()">СВЯЗАТЬСЯ</a>
</div>

<header class="page-header">
  <div class="page-header-inner">
    <div class="eyebrow">Описание продукта</div>
    <h1 style="font-family:'Barlow Condensed',sans-serif; font-weight:800; font-size:clamp(1.75rem,4vw,3rem); color:#fff; line-height:1.1; letter-spacing:-0.025em; margin:0 0 0.75rem;">${escHtml(ru.name)}</h1>
    <p style="font-size:1rem; color:rgba(255,255,255,0.5); max-width:640px; margin:0;">${escHtml(ru.sub)}</p>
  </div>
</header>

<div class="content-wrap">
  <div>
    <div style="display:flex; align-items:center; gap:1rem; margin-bottom:1.5rem; flex-wrap:wrap;">
      <span class="card-badge ${badgeCls}">${catLabel}</span>
      <span style="font-family:'IBM Plex Mono',monospace; font-size:0.75rem; color:var(--c-muted);">#${String(p.no).padStart(2,'0')}</span>
    </div>
    <div class="details-grid">
      <div class="detail-item"><span class="detail-label">Категория</span><span class="detail-value">${catLabel}</span></div>
      <div class="detail-item"><span class="detail-label">Артикул</span><span class="detail-value">${escHtml(refNo)}</span></div>
      <div class="detail-item"><span class="detail-label">Упаковка</span><span class="detail-value">${escHtml(p.pkg)}</span></div>
    </div>
${hasSpecs ? `      <div class="specs-section">
        <p class="specs-title">Технические характеристики</p>
        <div class="specs-body">${specsToHtml(ru.specs)}</div>
      </div>

` : ''}    <div class="pricing-note">
      Стоимость предоставляется по запросу. Заполните форму, и наша команда свяжется с вами с индивидуальным предложением.
    </div>
  </div>

  <div class="sidebar">
    <a href="../../../products.html" class="back-link">&#8592; Назад в каталог</a>
    <div class="quote-card">
      <p class="quote-card-title">Запросить предложение</p>
      <div class="qform-success" id="quoteSuccess">Спасибо — ваш запрос получен. Наша команда свяжется с вами в ближайшее время.</div>
      <form class="qform" id="quoteForm" onsubmit="submitQuote(event)">
        <input type="hidden" name="_form" value="quote">
        <input type="text" name="website" tabindex="-1" autocomplete="off" style="position:absolute; left:-9999px; width:1px; height:1px; opacity:0;" aria-hidden="true">
        <div><label for="qName">Полное имя *</label><input type="text" id="qName" name="name" placeholder="Ваше имя" required></div>
        <div><label for="qEmail">Электронная почта *</label><input type="email" id="qEmail" name="email" placeholder="your@email.com" required></div>
        <div><label for="qCompany">Организация</label><input type="text" id="qCompany" name="company" placeholder="Лаборатория / Учреждение"></div>
        <div><label for="qPhone">Телефон</label><input type="tel" id="qPhone" name="phone" placeholder="+44 ..."></div>
        <div><label for="qMessage">Сообщение</label><textarea id="qMessage" name="message" placeholder="Дополнительные требования, количество, информация о доставке&hellip;"></textarea></div>
        <input type="hidden" name="product" value="${escHtml(refNo + ' — ' + p.name)}">
        <div class="consent-check">
          <input type="checkbox" id="gdpr-consent" name="gdpr_consent" required>
          <label for="gdpr-consent" style="font-size:0.8125rem; color:var(--c-muted); line-height:1.6; text-transform:none; letter-spacing:0;">
            Я соглашаюсь на связь со стороны Green Med Ltd. и на обработку моих персональных данных в соответствии с
            <a href="../../../privacy_policy/privacy-policy.html" style="color:var(--gm-500); text-decoration:underline;">Политика конфиденциальности</a>. *
          </label>
        </div>
        <button type="submit" class="qform-submit">Отправить запрос</button>
      </form>
    </div>
  </div>
</div>

<footer>
  <div class="footer-inner">
    <img src="../../../brand_assets/GREENMED LOGO Vert.svg" alt="Green Med Ltd." style="height:60px; width:auto; opacity:0.55;" loading="lazy">
    <p class="footer-copy">&copy; 2025 Green Med Ltd. &middot; Зарегистрирована в Англии и Уэльсе № 13350293 &middot; Все права защищены.</p>
    <a href="../../../privacy_policy/privacy-policy.html" style="font-family:'IBM Plex Mono',monospace; font-size:0.75rem; color:rgba(255,255,255,0.35); text-decoration:none; letter-spacing:0.06em; transition:color 0.2s;" onmouseover="this.style.color='rgba(165,204,72,0.8)'" onmouseout="this.style.color='rgba(255,255,255,0.35)'">Политика конфиденциальности</a>
  </div>
</footer>

<script>
  function submitQuote(e) {
    e.preventDefault();
    var form = document.getElementById('quoteForm');
    var btn = form.querySelector('.qform-submit');
    var originalLabel = btn.textContent;
    btn.disabled = true;
    btn.textContent = 'ОТПРАВКА…';
    fetch('/form-handler.php', { method: 'POST', body: new FormData(form) })
      .then(function(res) { return res.json().catch(function () { return { ok: false }; }); })
      .then(function(data) {
        if (!data.ok) throw new Error(data.error || 'Send failed');
        document.getElementById('quoteForm').style.display = 'none';
        document.getElementById('quoteSuccess').classList.add('visible');
      })
      .catch(function() {
        alert('Извините — не удалось отправить запрос. Пожалуйста, напишите нам напрямую на support@greenmedltduk.com.');
        btn.disabled = false;
        btn.textContent = originalLabel;
      });
  }
  function toggleNav() {
    document.getElementById('mob-nav').classList.toggle('open');
    document.getElementById('ham').classList.toggle('open');
  }
</script>
</body>
</html>`;
}

// ── Main ───────────────────────────────────────────────────────────────────
const outDir = path.join(__dirname, 'products');
if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);
const ruOutDir = path.join(__dirname, 'ru', 'products');
if (!fs.existsSync(ruOutDir)) fs.mkdirSync(ruOutDir, { recursive: true });

const productSlugs = [];

for (const p of PRODUCTS) {
  const slug = SLUG_OVERRIDE[p.no] || slugify(p.name);
  productSlugs.push({ p, slug });

  const html = buildPage(p, slug);
  fs.writeFileSync(path.join(outDir, `${slug}.html`), html, 'utf8');

  const ru = RU[String(p.no)];
  if (!ru) {
    console.warn(`  !  no:${p.no} missing from translations.ru.json — skipping RU page`);
    continue;
  }
  const ruDir = path.join(ruOutDir, slug);
  if (!fs.existsSync(ruDir)) fs.mkdirSync(ruDir, { recursive: true });
  const ruHtml = buildPageRu(p, slug, ru);
  fs.writeFileSync(path.join(ruDir, 'index.html'), ruHtml, 'utf8');

  console.log(`  ✓  products/${slug}.html + ru/products/${slug}/index.html`);
}

// ── sitemap.xml ──────────────────────────────────────────────────────────
const today = new Date().toISOString().split('T')[0];

const staticPages = [
  { loc: '/',                                    priority: '1.0', freq: 'monthly' },
  { loc: '/ru/',                                 priority: '1.0', freq: 'monthly' },
  { loc: '/about.html',                          priority: '0.8', freq: 'monthly' },
  { loc: '/ru/about.html',                       priority: '0.8', freq: 'monthly' },
  { loc: '/projects.html',                       priority: '0.8', freq: 'monthly' },
  { loc: '/ru/projects.html',                    priority: '0.8', freq: 'monthly' },
  { loc: '/products.html',                       priority: '0.9', freq: 'weekly'  },
  { loc: '/ru/products.html',                    priority: '0.9', freq: 'weekly'  },
  { loc: '/contact.html',                        priority: '0.8', freq: 'monthly' },
  { loc: '/ru/contact.html',                     priority: '0.8', freq: 'monthly' },
  { loc: '/proposal.html',                       priority: '0.7', freq: 'monthly' },
  { loc: '/ru/proposal.html',                    priority: '0.7', freq: 'monthly' },
  { loc: '/privacy_policy/privacy-policy.html',    priority: '0.3', freq: 'yearly'  },
  { loc: '/ru/privacy_policy/privacy-policy.html', priority: '0.3', freq: 'yearly'  },
];

const productEntries = productSlugs.flatMap(({ p, slug }) => {
  const entries = [
    `  <url>\n    <loc>${DOMAIN}/products/${slug}.html</loc>\n    <lastmod>${today}</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.7</priority>\n  </url>`,
  ];
  if (RU[String(p.no)]) {
    entries.push(`  <url>\n    <loc>${DOMAIN}/ru/products/${slug}/</loc>\n    <lastmod>${today}</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.7</priority>\n  </url>`);
  }
  return entries;
});

const staticEntries = staticPages.map(pg =>
  `  <url>\n    <loc>${DOMAIN}${pg.loc}</loc>\n    <lastmod>${today}</lastmod>\n    <changefreq>${pg.freq}</changefreq>\n    <priority>${pg.priority}</priority>\n  </url>`
).join('\n');

const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${staticEntries}
${productEntries.join('\n')}
</urlset>`;

fs.writeFileSync(path.join(__dirname, 'sitemap.xml'), sitemap, 'utf8');
console.log('\n  ✓  sitemap.xml');

console.log(`\nDone — ${PRODUCTS.length} EN product pages, ${Object.keys(RU).length} RU product pages, + sitemap.xml`);
