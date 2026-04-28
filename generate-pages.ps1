Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$OutDir = Join-Path $ProjectRoot 'products'

# ── Lookup tables ──────────────────────────────────────────────────────────
$CatLabel = @{
    'Genomik & Sekanslama' = 'Genomics'
    'Biyokimya'            = 'Biochemistry'
    'Genel Sarf'           = 'General'
    'Pipetleme'            = 'Pipetting'
    'Su Aritma'            = 'Water Purif.'
    'Su Ar?tma'            = 'Water Purif.'
}
$BadgeClass = @{
    'Genomik & Sekanslama' = 'badge-genomics'
    'Biyokimya'            = 'badge-biochem'
    'Genel Sarf'           = 'badge-general'
    'Pipetleme'            = 'badge-pipetting'
    'Su Aritma'            = 'badge-water'
    'Su Ar?tma'            = 'badge-water'
}
$CatPrefix = @{
    'Genomik & Sekanslama' = 'GRN01'
    'Biyokimya'            = 'GRN03'
    'Pipetleme'            = 'GRN05'
    'Su Aritma'            = 'GRN07'
    'Su Ar?tma'            = 'GRN07'
    'Genel Sarf'           = 'GRN10'
}

# ── Helpers ────────────────────────────────────────────────────────────────
function Get-Slug([string]$name) {
    $s = $name.ToLower([System.Globalization.CultureInfo]::InvariantCulture)
    $s = [regex]::Replace($s, '[^\w\s-]', '')
    $s = [regex]::Replace($s, '[\s_]+', '-')
    $s = [regex]::Replace($s, '-{2,}', '-')
    $s = $s.Trim('-')
    if ($s.Length -gt 80) { $s = $s.Substring(0, 80) }
    return $s
}
function Esc([string]$s) {
    if (!$s) { return '' }
    return $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}
function SpecsHtml([string]$s) {
    if (!$s) { return '' }
    $s = $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;')
    $s = $s.Replace("`r`n",'<br>').Replace("`n",'<br>')
    return $s
}
function FullRef($p) {
    $prefix = $CatPrefix[$p.cat]
    if ($p.catalog) { return "$prefix-$($p.catalog)" } else { return $prefix }
}
function MetaDesc($p) {
    $ref  = FullRef $p
    $desc = "$($p.name) — $($p.sub). Catalog: $ref. Brand: $($p.brand). Laboratory supply from Green Med Ltd."
    if ($desc.Length -gt 160) { $desc = $desc.Substring(0,157) + '...' }
    return $desc
}

function Build-Page($p) {
    $T   = Esc $p.name
    $MD  = Esc (MetaDesc $p)
    $N   = Esc $p.name
    $S   = Esc $p.sub
    $CL  = $CatLabel[$p.cat]
    $BC  = $BadgeClass[$p.cat]
    $REF = FullRef $p
    $RE  = Esc $REF
    $PK  = Esc $p.pkg
    $NUM = $p.no.ToString().PadLeft(2,'0')
    $ProductId = Esc "$REF — $($p.name)"

    $specsBlock = ''
    if ($p.specs) {
        $sh = SpecsHtml $p.specs
        $specsBlock = "      <div class=`"specs-section`">`n        <p class=`"specs-title`">Technical Specifications</p>`n        <div class=`"specs-body`">$sh</div>`n      </div>`n"
    }

    return @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$T &mdash; Green Med Ltd.</title>
  <meta name="description" content="$MD">
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
  <style>
    :root{--c-black:#1C1C1C;--c-anthra:#2B2B2B;--c-dark:#4A4A4A;--c-muted:#8A8A8A;--c-rule:#E8E8E8;--c-bg:#F7F8F2;--c-white:#FFFFFF;--c-footer:#111111;--gm-300:#A5CC48;--gm-400:#7EB828;--gm-500:#619A18;--gm-600:#487A10;--gm-800:#193C04;--px:7vw}
    *,*::before,*::after{box-sizing:border-box}
    html{scroll-behavior:smooth}
    body{font-family:'IBM Plex Sans',sans-serif;font-weight:300;background:var(--c-bg);color:var(--c-dark);line-height:1.8;-webkit-font-smoothing:antialiased}
    .nav{position:fixed;top:0;left:0;right:0;height:64px;z-index:100;backdrop-filter:blur(16px);background:rgba(247,248,242,0.96);border-bottom:1px solid rgba(232,232,232,0.8)}
    .nav-inner{max-width:1440px;margin:0 auto;padding:0 var(--px);height:100%;display:flex;align-items:center;justify-content:space-between;gap:2rem}
    .nav-links{display:flex;align-items:center;gap:2.5rem}
    .nav-link{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.875rem;letter-spacing:.1em;text-transform:uppercase;color:var(--c-dark);text-decoration:none;transition:color .2s}
    .nav-link:hover{color:var(--gm-500)}
    .nav-link:focus-visible{outline:2px solid var(--gm-400);outline-offset:3px}
    .nav-link.active{color:var(--gm-500)}
    .btn-nav{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.875rem;letter-spacing:.08em;text-transform:uppercase;background:var(--gm-400);color:#fff;padding:.5rem 1.375rem;text-decoration:none;transition:background .2s}
    .btn-nav:hover{background:var(--gm-600)}
    .page-header{background:var(--c-anthra);padding:7rem var(--px) 4rem;position:relative;overflow:hidden}
    .page-header::before{content:'';position:absolute;inset:0;background-image:linear-gradient(rgba(126,184,40,.07) 1px,transparent 1px),linear-gradient(90deg,rgba(126,184,40,.07) 1px,transparent 1px);background-size:52px 52px;pointer-events:none}
    .page-header-inner{position:relative;z-index:1;max-width:1440px;margin:0 auto}
    .eyebrow{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.8125rem;letter-spacing:.18em;text-transform:uppercase;color:var(--gm-300);display:flex;align-items:center;gap:.875rem;margin-bottom:1.25rem}
    .eyebrow::before{content:'';display:block;width:2rem;height:2px;background:var(--gm-300);flex-shrink:0}
    .content-wrap{max-width:1440px;margin:0 auto;padding:3rem var(--px) 6rem;display:grid;grid-template-columns:1fr 360px;gap:3rem;align-items:start}
    .details-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:0;border:1px solid var(--c-rule);margin-bottom:2rem}
    .detail-item{padding:1.25rem 1.5rem;border-right:1px solid var(--c-rule);display:flex;flex-direction:column;gap:.375rem}
    .detail-item:last-child{border-right:none}
    .detail-label{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.6875rem;letter-spacing:.15em;text-transform:uppercase;color:var(--c-muted)}
    .detail-value{font-family:'IBM Plex Mono',monospace;font-size:.8125rem;color:var(--c-dark);line-height:1.4}
    .card-badge{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.6875rem;letter-spacing:.1em;text-transform:uppercase;padding:.25rem .625rem;display:inline-block}
    .badge-genomics{background:rgba(126,184,40,.12);color:var(--gm-600)}
    .badge-biochem{background:rgba(25,60,4,.07);color:var(--gm-800)}
    .badge-general{background:rgba(74,74,74,.08);color:var(--c-dark)}
    .badge-pipetting{background:rgba(165,204,72,.15);color:var(--gm-600)}
    .badge-water{background:rgba(72,122,16,.10);color:var(--gm-700)}
    .pricing-note{padding:1.25rem 1.5rem;border-left:3px solid var(--gm-400);background:rgba(126,184,40,.05);margin-top:2rem;font-size:.9375rem;color:var(--c-dark);line-height:1.65}
    .specs-section{margin-bottom:0}
    .specs-title{font-family:'Barlow Condensed',sans-serif;font-weight:700;font-size:.8125rem;letter-spacing:.15em;text-transform:uppercase;color:var(--gm-500);display:flex;align-items:center;gap:.75rem;margin-bottom:1rem}
    .specs-title::after{content:'';flex:1;height:1px;background:var(--c-rule)}
    .specs-body{font-size:.9rem;color:var(--c-dark);line-height:1.75}
    .sidebar{display:flex;flex-direction:column;gap:1.25rem}
    .back-link{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.8125rem;letter-spacing:.1em;text-transform:uppercase;color:var(--c-muted);text-decoration:none;display:inline-flex;align-items:center;gap:.5rem;transition:color .18s}
    .back-link:hover{color:var(--c-dark)}
    .quote-card{background:var(--c-white);border:1px solid var(--c-rule);padding:1.75rem}
    .quote-card-title{font-family:'Barlow Condensed',sans-serif;font-weight:700;font-size:.8125rem;letter-spacing:.15em;text-transform:uppercase;color:var(--gm-500);display:flex;align-items:center;gap:.75rem;margin-bottom:1.25rem}
    .quote-card-title::after{content:'';flex:1;height:1px;background:var(--c-rule)}
    .qform{display:flex;flex-direction:column;gap:.875rem}
    .qform label{font-family:'Barlow Condensed',sans-serif;font-weight:600;font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;color:var(--c-muted);display:block;margin-bottom:.375rem}
    .qform input,.qform textarea{font-family:'IBM Plex Sans',sans-serif;font-size:.875rem;font-weight:300;width:100%;background:var(--c-bg);border:1px solid var(--c-rule);color:var(--c-dark);padding:.625rem .875rem;outline:none;transition:border-color .18s;resize:vertical}
    .qform input::placeholder,.qform textarea::placeholder{color:var(--c-muted)}
    .qform input:focus,.qform textarea:focus{border-color:var(--gm-400)}
    .qform textarea{min-height:90px}
    .qform-submit{font-family:'Barlow Condensed',sans-serif;font-weight:700;font-size:.9375rem;letter-spacing:.1em;text-transform:uppercase;background:var(--gm-400);color:#fff;padding:.875rem 1.75rem;border:none;cursor:pointer;width:100%;transition:background .18s}
    .qform-submit:hover{background:var(--gm-600)}
    .qform-submit:focus-visible{outline:2px solid var(--gm-400);outline-offset:2px}
    .qform-success{display:none;padding:1.25rem 1.5rem;background:rgba(126,184,40,.08);border-left:3px solid var(--gm-400);font-size:.9375rem;color:var(--c-dark);line-height:1.6}
    .qform-success.visible{display:block}
    footer{background:var(--c-footer);padding:2.5rem var(--px)}
    .footer-inner{max-width:1440px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;gap:2rem;flex-wrap:wrap}
    .footer-copy{font-size:.8125rem;color:rgba(255,255,255,.35)}
    .hamburger{display:none;flex-direction:column;gap:5px;cursor:pointer;background:none;border:none;padding:4px}
    .hamburger span{display:block;width:22px;height:2px;background:var(--c-black);transition:transform .2s,opacity .2s}
    .hamburger.open span:nth-child(1){transform:translateY(7px) rotate(45deg)}
    .hamburger.open span:nth-child(2){opacity:0}
    .hamburger.open span:nth-child(3){transform:translateY(-7px) rotate(-45deg)}
    .mobile-nav{display:none;position:fixed;top:64px;left:0;right:0;z-index:99;background:rgba(247,248,242,.98);backdrop-filter:blur(16px);border-bottom:1px solid var(--c-rule);padding:1.75rem var(--px);flex-direction:column;gap:1.25rem}
    .mobile-nav.open{display:flex}
    @media(max-width:1024px){.nav-links{display:none}.btn-nav{display:none}.hamburger{display:flex}}
    @media(max-width:900px){.content-wrap{grid-template-columns:1fr}.details-grid{grid-template-columns:1fr 1fr}.detail-item:nth-child(3){border-right:none}}
    @media(max-width:768px){:root{--px:1.5rem}.details-grid{grid-template-columns:1fr}.detail-item{border-right:none;border-bottom:1px solid var(--c-rule)}.detail-item:last-child{border-bottom:none}}
  </style>
</head>
<body>

<nav class="nav" role="navigation" aria-label="Main navigation">
  <div class="nav-inner">
    <a href="../index.html" style="display:flex;align-items:center;flex-shrink:0;text-decoration:none;">
      <img src="../brand_assets/GREENMED LOGO Horz.svg" alt="Green Med Ltd." style="height:69px;width:auto;" loading="eager">
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
  <a href="../index.html#contact"  class="btn-nav" style="width:fit-content;margin-top:.5rem;" onclick="toggleNav()">GET IN TOUCH</a>
</div>

<header class="page-header">
  <div class="page-header-inner">
    <div class="eyebrow">Product Detail</div>
    <h1 style="font-family:'Barlow Condensed',sans-serif;font-weight:800;font-size:clamp(1.75rem,4vw,3rem);color:#fff;line-height:1.1;letter-spacing:-.025em;margin:0 0 .75rem;">$N</h1>
    <p style="font-size:1rem;color:rgba(255,255,255,.5);max-width:640px;margin:0;">$S</p>
  </div>
</header>

<div class="content-wrap">
  <div>
    <div style="display:flex;align-items:center;gap:1rem;margin-bottom:1.5rem;flex-wrap:wrap;">
      <span class="card-badge $BC">$CL</span>
      <span style="font-family:'IBM Plex Mono',monospace;font-size:.75rem;color:var(--c-muted);">#$NUM</span>
    </div>
    <div class="details-grid">
      <div class="detail-item"><span class="detail-label">Category</span><span class="detail-value">$CL</span></div>
      <div class="detail-item"><span class="detail-label">Reference No</span><span class="detail-value">$RE</span></div>
      <div class="detail-item"><span class="detail-label">Packaging</span><span class="detail-value">$PK</span></div>
    </div>
$specsBlock
    <div class="pricing-note">
      Pricing information is available upon request. Fill in the form and our team will get back to you with a personalised quote.
    </div>
  </div>

  <div class="sidebar">
    <a href="../products.html" class="back-link">&#8592; Back to Catalogue</a>
    <div class="quote-card">
      <p class="quote-card-title">Request a Quote</p>
      <div class="qform-success" id="quoteSuccess">Thank you &mdash; your request has been received. Our team will contact you shortly.</div>
      <form class="qform" id="quoteForm" onsubmit="submitQuote(event)">
        <div><label for="qName">Full Name *</label><input type="text" id="qName" name="name" placeholder="Your name" required></div>
        <div><label for="qEmail">Email *</label><input type="email" id="qEmail" name="email" placeholder="your@email.com" required></div>
        <div><label for="qCompany">Organisation</label><input type="text" id="qCompany" name="company" placeholder="Lab / Institution"></div>
        <div><label for="qPhone">Phone</label><input type="tel" id="qPhone" name="phone" placeholder="+44 ..."></div>
        <div><label for="qMessage">Message</label><textarea id="qMessage" name="message" placeholder="Additional requirements, quantity, delivery info&hellip;"></textarea></div>
        <input type="hidden" name="product" value="$ProductId">
        <div style="display:flex;align-items:flex-start;gap:.75rem;">
          <input type="checkbox" id="gdpr-consent" name="gdpr_consent" required style="margin-top:3px;width:16px;height:16px;accent-color:var(--gm-500);flex-shrink:0;cursor:pointer;">
          <label for="gdpr-consent" style="font-size:.8125rem;color:var(--c-muted);line-height:1.6;cursor:pointer;text-transform:none;letter-spacing:0;">
            I agree to be contacted by Green Med Ltd. and for my personal data to be processed in accordance with the
            <a href="../privacy_policy/privacy-policy.html" style="color:var(--gm-500);text-decoration:underline;">Privacy Policy</a>. *
          </label>
        </div>
        <button type="submit" class="qform-submit">Send Request</button>
      </form>
    </div>
  </div>
</div>

<footer>
  <div class="footer-inner">
    <img src="../brand_assets/GREENMED LOGO Vert.svg" alt="Green Med Ltd." style="height:60px;width:auto;opacity:.55;" loading="lazy">
    <p class="footer-copy">&copy; 2025 Green Med Ltd. &middot; Registered in England &amp; Wales No. 13350293 &middot; All rights reserved.</p>
    <a href="../privacy_policy/privacy-policy.html" style="font-family:'IBM Plex Mono',monospace;font-size:.75rem;color:rgba(255,255,255,.35);text-decoration:none;letter-spacing:.06em;transition:color .2s;" onmouseover="this.style.color='rgba(165,204,72,.8)'" onmouseout="this.style.color='rgba(255,255,255,.35)'">Privacy Policy</a>
  </div>
</footer>

<script>
  function submitQuote(e) {
    e.preventDefault();
    var name    = document.getElementById('qName').value;
    var email   = document.getElementById('qEmail').value;
    var company = document.getElementById('qCompany').value;
    var phone   = document.getElementById('qPhone').value;
    var message = document.getElementById('qMessage').value;
    var product = '$ProductId';
    var body = encodeURIComponent('Product: ' + product + '\nName: ' + name + '\nCompany: ' + company + '\nPhone: ' + phone + '\n\n' + message);
    window.location.href = 'mailto:support@greenmed.ltd?subject=' + encodeURIComponent('Quote Request — ' + product) + '&body=' + body;
    document.getElementById('quoteForm').style.display = 'none';
    document.getElementById('quoteSuccess').classList.add('visible');
  }
  function toggleNav() {
    document.getElementById('mob-nav').classList.toggle('open');
    document.getElementById('ham').classList.toggle('open');
  }
</script>
</body>
</html>
"@
}

# ── Product data ───────────────────────────────────────────────────────────
$Products = @(
  @{ no=1;  name="POP-4 Polymer for 3500 analyzer";                                    cat="Genomik & Sekanslama"; sub="Capillary electrophoresis polymer";   catalog="4393715";      brand="Thermo Fisher Scientific";     pkg="pack";  specs="POP-4 separation matrix is optimized for HID/forensic applications. POP polymers dynamically coat the capillary wall to control electro-osmotic flow, ensuring reproducibility across runs.`n`n• Pre-formulated single-use pouch — saves time and ensures consistency`n• RFID label: tracks part/lot number, samples remaining, and expiry date`n• Robust formulation for sequencing and fragment analysis applications`n• Replenishable — allows capillaries to be reused multiple times`n• Compatible with 3500 and SeqStudio Flex series genetic analyzers`n`nFor Research Use Only. Not for use in diagnostic procedures." }
  @{ no=2;  name="Anode Buffer Container for 3500 analyzer";                           cat="Genomik & Sekanslama"; sub="Capillary electrophoresis buffer";    catalog="4393927";      brand="Life Technologies Corporation"; pkg="pack";  specs="Contains 1X running buffer to support all electrophoresis applications on the Applied Biosystems 3500 and SeqStudio Flex series genetic analyzers.`n`n• Ready-to-use, disposable container with RFID tag for easy tracking`n• Heat-sealed top must be removed prior to direct installation on the instrument`n• 4 individual containers per package`n• Replace every 14 days or before each run`n• Store at 2-8°C`n`nFor Research Use Only. Not for use in diagnostic procedures." }
  @{ no=3;  name="Cathode Buffer Container for 3500 analyzer";                         cat="Genomik & Sekanslama"; sub="Capillary electrophoresis buffer";    catalog="4408256";      brand="Life Technologies Corporation"; pkg="pack";  specs="Contains 1X running buffer for all electrophoresis applications on the 3500 and SeqStudio Flex series.`n`n• Dual-compartment design: left side provides cathode buffer for electrophoresis; right side enables capillary wash and spent polymer waste ejection between injections`n• Ready-to-use, disposable container with RFID tag`n• Heat-sealed top must be removed prior to installation`n• 4 containers per package`n• Replace every 14 days or before each run; store at 2-8°C`n`nFor Research Use Only. Not for use in diagnostic procedures." }
  @{ no=4;  name="Hi-Di Formamide reagent 5 ml";                                      cat="Genomik & Sekanslama"; sub="Formamide denaturation reagent";      catalog="4401457";      brand="Life Technologies Corporation"; pkg="pack";  specs="Highly deionized (Hi-Di) formamide used to resuspend samples before electrokinetic injection in capillary electrophoresis systems.`n`n• 5 mL format minimizes the number of freeze/thaw cycles compared to larger volumes`n• Denatures DNA prior to CE injection for accurate fragment analysis`n• Store at -20°C; protect from light`n`nFor Research Use Only." }
  @{ no=5;  name="Conditioning Reagent for 3500 Genetic Analyzer";                    cat="Genomik & Sekanslama"; sub="Instrument conditioning reagent";     catalog="4393718";      brand="Life Technologies Corporation"; pkg="pack";  specs="Ready-to-use pouch compatible with 3500 and SeqStudio Flex series genetic analyzers.`n`n• Used for: priming the polymer pump, washing the polymer pump between polymer type changes, and instrument shutdown`n• Single-use volume per pouch ensures consistency`n• RFID-tagged for lot and expiry traceability`n• Store at RT; use before each polymer change`n`nFor Research Use Only. Not for use in diagnostic procedures." }
  @{ no=6;  name="GeneScan 600 LIZ laboratory reagent for 3500 analyzer";             cat="Genomik & Sekanslama"; sub="Size standard";                       catalog="4408399";      brand="Thermo Fisher Scientific";     pkg="pack";  specs="GeneScan 600 LIZ Size Standard v2.0 — a fifth dye-labeled high-density size standard for reproducible sizing of fragment analysis data.`n`n• Contains 36 LIZ-labeled single-stranded DNA fragments covering the 20-600 bp range`n• Improved lot-to-lot consistency and peak height balance vs. previous version`n• Required for normalization on the 3500 Series Genetic Analyzers`n• Compatible with all Applied Biosystems CE systems`n• Store at -20°C; protect from light`n`nFor Research Use Only. Not for use in diagnostic procedures." }
  @{ no=7;  name="Quantifiler Trio DNA Quantification Kit";                           cat="Genomik & Sekanslama"; sub="DNA quantification kit";              catalog="4482910";      brand="Thermo Fisher Scientific";     pkg="kit";   specs="Simultaneously quantifies total human and human male DNA in a single, highly sensitive real-time PCR reaction.`n`n• Sensitivity: <1 pg/µL limit of detection; quantifies 0.005 ng/µL to >50 ng/µL`n• Three target loci: Small Autosomal, Large Autosomal, and Y-chromosome`n• Determines male-to-female DNA ratio even at 1:4000 or greater`n• Quality Index predicts STR amplification performance`n• Results in ~1 hour on Applied Biosystems 7500 Real-Time PCR System`n• ISO 18385 compliant`n`nFor Forensic/Paternity Use Only." }
  @{ no=8;  name="GlobalFiler Express PCR Amplification Kit";                         cat="Genomik & Sekanslama"; sub="STR PCR amplification kit";           catalog="4476609";      brand="Thermo Fisher Scientific";     pkg="kit";   specs="First 6-dye, 24-locus STR kit optimized for database and single-source samples.`n`n• Up to 5x faster amplification than previous-generation kits`n• DNA results in <2 hours using current CE platforms`n• Includes all markers recommended by the CODIS Core Loci Working Group`n• Includes all markers commonly used in Europe`n• Store at -15°C to -25°C; after opening store at 2-8°C for up to 6 months`n`nFor casework samples, use the GlobalFiler PCR Amplification Kit." }
  @{ no=9;  name="GlobalFiler PCR Amplification Kit";                                 cat="Genomik & Sekanslama"; sub="STR PCR amplification kit";           catalog="4476135";      brand="Thermo Fisher Scientific";     pkg="kit";   specs="First 6-dye, 24-locus STR kit optimized for challenging casework samples.`n`n• Includes 10 mini-STRs for maximum results from highly degraded samples`n• Enhanced intracolor balance simplifies interpretation of mixture samples`n• Optimized buffer system with expanded DNA input volume`n• Includes all markers recommended by the CODIS Core Loci Working Group`n• Store at -15°C to -25°C; after opening store at 2-8°C for up to 6 months" }
  @{ no=10; name="Prep-n-Go Buffer for buccal swabs";                                 cat="Genomik & Sekanslama"; sub="Direct PCR buffer";                   catalog="4471406";      brand="Life Technologies Corporation"; pkg="pack";  specs="Best-in-class buffer enabling high-quality direct PCR amplification of single-source samples collected on buccal swabs. No purification, extraction, or quantification required.`n`n• Compatible with AmpFLSTR Identifiler Direct PCR Amplification Kit`n• Delivers consistent, interpretable peaks above the detection threshold`n• Produces high-quality, well-balanced STR profiles`n• 200 reactions per pack`n• Store at -20°C`n`nFor Research Use Only." }
  @{ no=11; name="Forensic DNA Extraction Kit PrepFiler Express";                     cat="Genomik & Sekanslama"; sub="DNA extraction kit";                  catalog="4441352";      brand="Life Technologies Corporation"; pkg="kit";   specs="For use with the AutoMate Express Forensic DNA Extraction System. Suitable for standard forensic sample types including bodily fluids on FTA paper, cotton swabs, cotton cloth, and denim.`n`n• High yield and purity of DNA, free of PCR inhibitors`n• PrepFiler LySep Column: rapid substrate-lysate separation by centrifugation`n• Ready-to-use pre-filled cartridges minimize setup time`n• Processes 1 to 13 samples per run`n• Store at RT`n• ISO 18385 compliant`n`nFor Research, Forensic, or Paternity Use Only." }
  @{ no=12; name="Forensic DNA Extraction Kit PrepFiler Express BTA";                 cat="Genomik & Sekanslama"; sub="DNA extraction kit";                  catalog="4441351";      brand="Life Technologies Corporation"; pkg="kit";   specs="For use with the AutoMate Express Forensic DNA Extraction System. Specifically designed for challenging forensic matrices: bones, teeth, cigarette butts, tape lifts, and other adhesive-based samples.`n`n• High yield and purity of DNA, free of PCR inhibitors`n• PrepFiler BTA Lysis Buffer formulated for hard tissue and adhesive sample types`n• PrepFiler LySep Column: rapid substrate-lysate separation by centrifugation`n• Processes 1 to 13 samples per run`n• Store at RT`n• ISO 18385 compliant`n`nFor Research, Forensic, or Paternity Use Only." }
  @{ no=13; name="PMB test for blood stain identification";                           cat="Biyokimya";            sub="Blood stain identification test";     catalog="240032";       brand="Seratec GmbH";                 pkg="pack";  specs="Monoclonal antibody test that detects the presence of human hemoglobin and D-dimer (a degradation protein found in menstrual blood).`n`n• 30 individually sealed cassettes and 30 tubes with 1.5 mL each of dilution buffer`n• Fast and reliable: results in only 10 minutes`n• Sensitive: detects as little as 20 ng/mL of human hemoglobin and 400 ng/mL of D-dimer`n• Simple: no special training necessary`n• Compatible with DNA extraction and typing" }
  @{ no=14; name="Antiserum against human serum proteins";                            cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of human serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=15; name="Antiserum against porcine serum proteins";                          cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of porcine serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=16; name="Antiserum against cattle serum proteins";                           cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of bovine serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=17; name="Antiserum against equine serum proteins";                           cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of equine serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=18; name="Antiserum against avian serum proteins";                            cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of avian serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=19; name="Antiserum against dog serum proteins";                              cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of canine serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=20; name="Antiserum against cat serum proteins";                              cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="20.59.52.199"; brand="Gematolog, Russia";            pkg="mL";    specs="Rabbit antibodies for detecting the presence of feline serum proteins in forensic material. Packaging: glass bottle of 1-2 mL." }
  @{ no=21; name="Antiserum against rabbit serum proteins";                           cat="Biyokimya";            sub="Antiserum / immunodiffusion reagent"; catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=22; name="Anti-M hemagglutinating serum";                                    cat="Biyokimya";            sub="Hemagglutinating serum";              catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=23; name="Anti-N hemagglutinating serum";                                    cat="Biyokimya";            sub="Hemagglutinating serum";              catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=24; name="Anti-P hemagglutinating serum";                                    cat="Biyokimya";            sub="Hemagglutinating serum";              catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=25; name="Kell hemagglutinating serum";                                      cat="Biyokimya";            sub="Hemagglutinating serum";              catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=26; name="Anti-A Monoclonal Antibodies for Blood Typing";                    cat="Biyokimya";            sub="Monoclonal blood grouping reagent";   catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=27; name="Anti-B Monoclonal Antibodies for Blood Typing";                    cat="Biyokimya";            sub="Monoclonal blood grouping reagent";   catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=28; name="Anti-H Monoclonal Antibodies for Blood Typing";                    cat="Biyokimya";            sub="Monoclonal blood grouping reagent";   catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=29; name="Anti-D monoclonal blood grouping reagent";                         cat="Biyokimya";            sub="Monoclonal blood grouping reagent";   catalog="";             brand="Gematolog, Russia";            pkg="mL";    specs="" }
  @{ no=30; name="Microtome blades 50pcs per pack";                                  cat="Genel Sarf";           sub="Histology blade";                     catalog="28407004";     brand="Plasma Blade LPH";             pkg="pack";  specs="Disposable plasma-coated microtome blades.`n`n• Coating: Plasma (LPH type)`n• Low-profile blade optimised for hard specimens`n• 100 blades per pack" }
  @{ no=31; name="Mayers Hematoxylin 1 L";                                           cat="Biyokimya";            sub="Histological staining reagent";       catalog="HE-G0-DL01";  brand="BioWitrum, Russia";            pkg="liter"; specs="" }
  @{ no=32; name="Eosin water-alcoholic concentrated";                               cat="Biyokimya";            sub="Histological staining reagent";       catalog="HE-EK-A500";  brand="BioWitrum, Russia";            pkg="liter"; specs="" }
  @{ no=33; name="Reverse Osmosis cartridge for PURELAB Option-R";                   cat="Su Aritma";            sub="Reverse osmosis membrane cartridge";  catalog="LC143";        brand="ELGA VEOLIA";                  pkg="pcs";   specs="RO membrane cartridge for PURELAB Option-R 7/15 and Medica systems.`n`n• Removes inorganic and organic compounds`n• Feed water source: tap water`n• Service life: approximately 24 months (replace when flow rate drops)" }
  @{ no=34; name="UV Lamp for PURELAB Option-R";                                     cat="Su Aritma";            sub="UV lamp for water purifier";          catalog="LC105";        brand="ELGA VEOLIA";                  pkg="pcs";   specs="UV germicidal lamp (LC105) for PURELAB Option-R and Pulse water purification systems.`n`n• Wavelength: 254 nm`n• Destroys bacteria and microorganisms`n• Service life: approximately 18 months`n• Replace every 12 months" }
  @{ no=35; name="Purification Pack for PURELAB Option-R";                           cat="Su Aritma";            sub="Purification cartridge pack";         catalog="LC214";        brand="ELGA VEOLIA";                  pkg="pcs";   specs="LC214 DI purification pack for PURELAB flex 3/4 water purification systems.`n`n• Material: mixed-bed ion exchange resin`n• Removes dissolved ions`n• Service life: approximately 6 months`n• Replace every 6 months" }
  @{ no=36; name="UV Lamp 185/254 nm";                                               cat="Su Aritma";            sub="UV lamp for water purifier";          catalog="LC210-02";     brand="ELGA VEOLIA";                  pkg="pcs";   specs="UV lamp 185/254 nm (LC210-02) for PURELAB flex 3/4 water purification systems.`n`n• Dual wavelength: destroys organic compounds (185 nm) and bacteria (254 nm)`n• Service life: approximately 12-18 months`n• Replace every 12-18 months" }
  @{ no=37; name="Glycerin";                                                         cat="Genel Sarf";           sub="Glycerol / sample mounting medium";   catalog="VKTN-138";     brand="Siemens Healthcare Diagnostics";pkg="pcs";  specs="Glycerol (Glycerin) 99.5% purity, pharmaceutical grade.`n`n• Used as a sample mounting medium and preservative in histology`n• CAS No.: 56-81-5`n• Pharmaceutical grade`n`nStore at room temperature." }
  @{ no=38; name="Ethyl Alcohol Reagent";                                            cat="Biyokimya";            sub="EMIT ethanol assay reagent";          catalog="REF 9K309";    brand="Siemens Healthcare Diagnostics";pkg="pack"; specs="EMIT II Plus Ethyl Alcohol reagent for quantitative ethanol determination in serum/plasma.`n`n• Application: Toxicology Reagent`n• For Use With: Chemistry Analysers (Viva / Dimension)`n• Test Name: Ethanol`n• Volume: 115 mL`n`nStore at 2-8°C." }
  @{ no=39; name="Alcohol High Control";                                             cat="Biyokimya";            sub="EMIT ethanol control";                catalog="REF 9K079";    brand="Siemens Healthcare Diagnostics";pkg="pack"; specs="EMIT Alcohol High Control — 300 mg/dL; 1x3 mL; for QC of ethanol assay on clinical analysers.`n`n• Level: High (300 mg/dL)`n• Specialty: Toxicology`n• Volume: 3 mL`n`nStorage: Keep frozen." }
  @{ no=40; name="Ethyl Alcohol Low Control";                                        cat="Biyokimya";            sub="EMIT ethanol control";                catalog="REF 9K049";    brand="Siemens Healthcare Diagnostics";pkg="pack"; specs="EMIT Ethyl Alcohol Low Control — 40 mg/dL; 1x3 mL; for QC of ethanol assay.`n`n• Level: Low (40 mg/dL)`n• Test Category: Drugs of Abuse`n• Volume: 3 mL`n`nStore at 2-8°C." }
  @{ no=41; name="Alcohol Negative Calibrator";                                      cat="Biyokimya";            sub="EMIT ethanol calibrator";             catalog="REF 9K029";    brand="Siemens Healthcare Diagnostics";pkg="pack"; specs="EMIT Alcohol Negative Calibrator — zero-level calibrator for ethanol assay; 1x3 mL.`n`n• Level: Negative (0 mg/dL)`n• Specialty: Toxicology`n• Volume: 3 mL`n`nStorage: Keep frozen." }
  @{ no=42; name="Alcohol Calibrator";                                               cat="Biyokimya";            sub="EMIT ethanol calibrator";             catalog="REF 9K059";    brand="Elitech Clinical Systems";     pkg="pack";  specs="EMIT Alcohol Calibrator — mid-level calibrator for ethanol assay; 1x3 mL.`n`n• Level: 100 mg/dL`n• Specialty: Toxicology`n• Volume: 3 mL`n`nStorage: Keep frozen." }
  @{ no=43; name="Ribbon Cartridge for EPSON ERC-09";                               cat="Genel Sarf";           sub="Printer ribbon cartridge";            catalog="ERC-09";       brand="Epson";                        pkg="pack";  specs="Epson ERC-09B black ribbon cartridge.`n`n• Compatible models: HX-20, M-160, M-180, M-190 series printers`n• Colour: Black" }
  @{ no=44; name="Pipette Tips Filtered 1000 uL";                                   cat="Pipetleme";            sub="Filtered pipette tip";               catalog="94420713";     brand="Thermo Fisher Scientific";     pkg="pack";  specs="Thermo Scientific ClipTip Filtered Pipette Tips — 1000 µL; sterile; rack format; 8x96 tips/pack.`n`n• Interlocking clip technology ensures a complete seal on every channel`n• Filter design: ideal for PCR and critical samples to prevent cross-contamination`n• Low retention: minimises liquid retention for maximum sample recovery`n• Certified free of RNase, DNase, DNA, ATP and endotoxin`n`nStore at room temperature." }
  @{ no=45; name="Pipette Tips Non-Filtered 1000 uL";                               cat="Pipetleme";            sub="Non-filtered pipette tip";           catalog="94410713";     brand="Thermo Fisher Scientific";     pkg="pack";  specs="Thermo Scientific ClipTip Non-Filtered Pipette Tips — sterile; rack format.`n`n• Interlocking clip technology ensures a complete seal on every channel`n• Low retention: minimises liquid retention for maximum sample recovery`n• Certified free of RNase, DNase, DNA, ATP and endotoxin`n`nStore at room temperature." }
  @{ no=46; name="Helium Gas 50 L for Gas Chromatography";                          cat="Genel Sarf";           sub="Laboratory gas - Helium";             catalog="CAS 7440-59-7";brand="Asalgaz, Turkey";              pkg="pcs";   specs="" }
  @{ no=47; name="Argon Gas 50 L for Gas Chromatography";                           cat="Genel Sarf";           sub="Laboratory gas - Argon";              catalog="CAS 7440-37-1";brand="Asalgaz, Turkey";              pkg="pcs";   specs="" }
  @{ no=48; name="Sodium Chloride 99.5% 1 kg";                                      cat="Biyokimya";            sub="Inorganic salt";                      catalog="Art. 3957.1";  brand="Carl Roth, Germany";           pkg="pack";  specs="Sodium chloride 99.5%, analytical grade; without anti-caking agent; for cell culture and biochemistry.`n`n• Empirical formula: NaCl`n• Molar mass: 58.44 g/mol`n• Density: 2.17 g/cm³`n• CAS No.: 7647-14-5`n`nStore at room temperature in dry conditions." }
  @{ no=49; name="Ammonium Formate 100g";                                           cat="Biyokimya";            sub="LC-MS reagent";                       catalog="Art. 17843";   brand="Carl Roth, Germany";           pkg="pack";  specs="Ammonium formate 99%, HPLC grade; for LC-MS mobile phase preparation.`n`n• Linear formula: HCO2NH4`n• Formula weight: 63.06 g/mol`n• Density: 1.26 g/mL at 25°C`n`nStore at room temperature." }
  @{ no=50; name="Formic acid 99% 50 ml";                                           cat="Biyokimya";            sub="LC-MS reagent";                       catalog="Art. 4724";    brand="Carl Roth, Germany";           pkg="pack";  specs="Formic acid Rotipuran 99%, p.a.; for LC-MS mobile phase preparation. Corrosive.`n`n• Empirical formula: CH2O2 (Methanoic acid)`n• Molar mass: 46.02 g/mol`n• Density: 1.22 g/cm³`n• Boiling point: 101°C | Flash point: 49°C`n• CAS No.: 64-18-6 | UN-Nr.: 1779 | ADR 8 II`n`nCorrosive. Store at room temperature." }
  @{ no=51; name="Buffer Solution pH 4 500 mL";                                     cat="Biyokimya";            sub="pH buffer solution";                  catalog="P712.3";       brand="Carl Roth, Germany";           pkg="pack";  specs="ROTI Buffer Solution pH 4.00 ±0.02; certified reference material; 500 mL.`n`n• Density: 1.007 g/cm³`n• Components: Citric acid, sodium hydroxide, sodium chloride`n`nStore at room temperature." }
  @{ no=52; name="Buffer solution pH 10 500 ml";                                    cat="Biyokimya";            sub="pH buffer solution";                  catalog="P716.2";       brand="Carl Roth, Germany";           pkg="pack";  specs="ROTI Buffer Solution pH 10.00 ±0.02; certified reference material; 500 mL.`n`n• Density: 1.008 g/cm³`n• Components: Boric acid, sodium hydroxide, potassium chloride`n`nStore at room temperature." }
  @{ no=53; name="Electrolytic Cell Block for Hydrogen Trace Generator";            cat="Genel Sarf";           sub="Hydrogen generator electrolytic cell";catalog="08-9412";      brand="Peak Scientific, UK";          pkg="pcs";   specs="Electrolytic cell block / cell stack for Peak Hydrogen Trace generator. Spare part for routine replacement.`n`n• Compatible art. numbers: 08-9412, 08-3609, 08-3644, 08-3543`n• Handle carefully; high-purity electrolyte" }
  @{ no=54; name="Electrolytic Cell Block for Precision Hydrogen Trace Generator";  cat="Genel Sarf";           sub="Hydrogen generator electrolytic cell";catalog="05-1007";      brand="Peak Scientific, UK";          pkg="pcs";   specs="Electrolytic cell block for Precision Hydrogen Trace generator. Replacement spare part.`n`n• Art. No.: 05-1007`n• For Precision Hydrogen Trace generator series" }
  @{ no=55; name="Service Kit for Precision Hydrogen Trace";                        cat="Genel Sarf";           sub="Hydrogen generator service kit";      catalog="08-3609";      brand="Peak Scientific, UK";          pkg="kit";   specs="Annual service kit for Precision Hydrogen Trace generator. Art. No.: 08-3609.`n`n• Includes: Valve (Art. 02-6051) x2`n• Includes: Double cylinder assembly (Art. 05-1047) x2`n• Annual maintenance interval" }
  @{ no=56; name="Service Kit II for Precision Hydrogen Trace";                     cat="Genel Sarf";           sub="Hydrogen generator service kit";      catalog="08-9412";      brand="Peak Scientific, UK";          pkg="kit";   specs="Annual service kit for Precision Hydrogen Trace generator. Art. No.: 08-9412.`n`n• Includes valves and cylinder assembly`n• Annual maintenance interval" }
  @{ no=57; name="Blood Alcohol Standard sample 10 ml";                             cat="Biyokimya";            sub="Blood alcohol standard";              catalog="";             brand="LGC Standards / Cerilliant";  pkg="pack";  specs="" }
  @{ no=58; name="Ethanol calibration Solution 10 x 1.2 mL";                       cat="Biyokimya";            sub="Ethanol calibration kit";             catalog="CERE-034";     brand="LGC Standards / Cerilliant";  pkg="pack";  specs="Cerilliant ethanol calibration kit; 10x1.2 mL ampules; for GC headspace blood alcohol analysis.`n`n• Storage Temperature: +4°C`n• Shipping Temperature: No freezing`n• Product Format: Single Solution`n• Matrix: Water" }
  @{ no=59; name="Ethanol calibration Solution";                                    cat="Biyokimya";            sub="Ethanol calibration kit";             catalog="E-034-1KIT";   brand="LGC Standards / Cerilliant";  pkg="pack";  specs="Cerilliant ethanol calibration kit; 10x1.2 mL ampules; CAS 64-17-5.`n`n• Storage Temperature: +4°C`n• Product Format: Single Solution`n• Matrix: Water`n• 1.2 mL per ampoule, 2 ampoules of each concentration, 10 ampoules/kit" }
  @{ no=60; name="Urine Containers 100 mL 500 pcs per pack";                       cat="Genel Sarf";           sub="Sample collection container";         catalog="75.1354.001";  brand="Kabe Labortechnik, Germany";  pkg="pack";  specs="Polypropylene urine sample container with screw cap for collection and storage of urine.`n`n• Maximum working volume: 100 mL`n• Opening diameter: 58 mm`n• Material: PP (polypropylene)`n• Transparent, graduated, with screw cap`n• Single use; sterile" }
  @{ no=61; name="Vacuum tubes 4 ml 1200 pcs";                                     cat="Genel Sarf";           sub="Vacuum blood collection tube";        catalog="234704";       brand="Disera, Turkey";               pkg="pack";  specs="Sodium fluoride + K3 EDTA — single-use vacuum blood collection tubes.`n`n• Additive: Sodium fluoride (NaF) + Potassium EDTA (K3 EDTA)`n• Application: Suitable for glucose analysis within 48 hours of collection`n• Mixing: 8-10 inversions after collection`n• Centrifugation: 1300 g, 10 min`n• Shelf life: 18 months" }
  @{ no=62; name="Service Kit for LC System";                                       cat="Genel Sarf";           sub="HPLC maintenance kit";                catalog="G2571-67001";  brand="Agilent Technologies";         pkg="kit";   specs="Agilent LC annual service kit with Jet Clean. Part No.: G2571-67001.`n`n• Canted coil spring, 8.9 mm OD`n• Classified as a consumable part for LC-MS instrument repair and maintenance`n• Annual preventive maintenance" }
  @{ no=63; name="Service kit including Jet Clean";                                 cat="Genel Sarf";           sub="HPLC maintenance kit";                catalog="G2571-67001";  brand="Agilent Technologies";         pkg="kit";   specs="QuickPick PM kit for Agilent split inlet and split vent.`n`n• 1x split liner (5183-4647)`n• 5x Non-Stick BTO septa (5183-4757)`n• 1x Non-Stick inlet liner O-ring (5188-5365)`n• 1x Gold Seal and washer kit (5188-5367)`n• 1x split vent cartridge`n• 2x O-rings for split vent (5188-6495)`n`nAnnual preventive maintenance." }
  @{ no=64; name="Service Kit for Agilent GC";                                     cat="Genel Sarf";           sub="GC maintenance kit";                  catalog="5188-6496";    brand="Agilent Technologies";         pkg="kit";   specs="QuickPick PM kit for Agilent GC 7890 split inlet and vent. Part No.: 5188-6496.`n`n• 1x split liner (5183-4647)`n• 5x Non-Stick BTO septa (5183-4757)`n• 1x Non-Stick inlet liner O-ring (5188-5365)`n• 1x Gold Seal and washer kit (5188-5367)`n• 1x split vent cartridge`n`nAnnual preventive maintenance." }
  @{ no=65; name="Filament Assembly for GC/MS 7890";                               cat="Genel Sarf";           sub="GC spare part - filament";            catalog="G7005-60061";  brand="Agilent Technologies";         pkg="pack";  specs="High-temperature EI filament replacement for Agilent GC/MS systems. Part No.: G7005-60061.`n`n• Type: High-temperature electron ionization (EI) filament`n• Filament element: Four-coil rhenium wire`n• Base: Alumina`n• Compatible instruments: 5973, 5975, 5977, 7000A, 7000B, 7000C, 7200`n`nFragile; handle with care." }
  @{ no=66; name="Vial Inserts with Polymer Feet 100 pcs";                         cat="Genel Sarf";           sub="GC vial insert";                      catalog="5181-1270";    brand="Agilent Technologies";         pkg="pack";  specs="Agilent 250 µL conical vial inserts with polymer feet for GC and LC autosampler use.`n`n• Volume: 250 µL`n• Material: Glass insert with polymer feet`n• Dimensions: 5.6 x 30 mm`n• Insert type: Conical, for wide-opening vials`n• 100 inserts per pack" }
  @{ no=67; name="AP Board for Agilent GC 7890";                                   cat="Genel Sarf";           sub="GC spare part - circuit board";       catalog="G3430-60151";  brand="Agilent Technologies";         pkg="pack";  specs="Agilent 7890 Analog and Power Printed Circuit Board (AP Board). Part No.: G3430-60151. Refurbished unit.`n`nNote: Obsolete part — no replacement recommendation from Agilent." }
  @{ no=68; name="Mainboard for Agilent GC 7890";                                  cat="Genel Sarf";           sub="GC spare part - mainboard";           catalog="G1099-65010";  brand="Agilent Technologies";         pkg="pack";  specs="Mainboard PCA for Agilent GC 7890 system. OEM Ref.: G1099-65010.`n`n• For GC/MS printed circuit board replacement`n• Used with 5973 series GC/MS systems`n`nESD sensitive; handle with appropriate precautions." }
  @{ no=69; name="Service Kit for 1290 Infinity II autosampler";                   cat="Genel Sarf";           sub="HPLC autosampler service kit";        catalog="G7161-68740";  brand="Agilent Technologies";         pkg="pack";  specs="Preventive maintenance kit for Agilent 1290 Infinity II Preparative Binary Pump (G7161B). Part No.: G7161-68740.`n`n• Designed for 200 mL/min pump heads`n• Includes needle, seals, and rotor`n• Annual maintenance interval" }
  @{ no=70; name="Service Kit for 1260 Infinity II autosampler";                   cat="Genel Sarf";           sub="HPLC autosampler service kit";        catalog="G1329B";       brand="Agilent Technologies";         pkg="pack";  specs="PM kit for Agilent 1100/1120/1200/1220/1260 HPLC systems.`n`n• 1x Pump seal`n• 1x Needle assembly`n• 1x 2-Position/6-Port Rotor Seal, Vespel 600 bar`n• 1x Needle seat, Std., PEEK`n`nAnnual maintenance." }
  @{ no=71; name="Service Kit for Agilent 1290 Infinity II Pump";                  cat="Genel Sarf";           sub="HPLC pump service kit";               catalog="G1310-68741";  brand="Agilent Technologies";         pkg="pack";  specs="PM kit for Agilent 1220 and 1260 HPLC pump systems. Part No.: G1310-68741.`n`n• 1x Black piston seals, 2/pk`n• 1x Seal cap assembly`n• 1x PTFE frits, 5/pk`n`nAnnual maintenance." }
  @{ no=72; name="PM Kit for 1290 Infinity II Autosampler";                        cat="Genel Sarf";           sub="HPLC autosampler PM kit";             catalog="G1313-68719";  brand="Agilent Technologies";         pkg="pack";  specs="Preventive maintenance kit for Agilent 1290 Infinity II autosampler. Comparable to Part No.: G1313-68719.`n`n• 1x Pump seal`n• 1x Needle assembly`n• 1x 2-Position/6-Port Rotor Seal, Vespel 600 bar`n• 1x Needle seat, Std., PEEK`n`nAnnual maintenance." }
  @{ no=73; name="Neutral Density Glass Filter Set for Cary 60";                   cat="Genel Sarf";           sub="UV-Vis spectrophotometer filter";      catalog="218006500";    brand="Agilent Technologies";         pkg="pack";  specs="Certified neutral density glass filters for Agilent Cary 60 UV-Vis spectrophotometer. Art. No.: 218006500.`n`n• Type: Neutral density screen, tested`n• For spectrophotometer wavelength and absorbance calibration`n• 1 filter per pack" }
  @{ no=74; name="Deactivated FS column 0.53mm for GC Headspace";                 cat="Genel Sarf";           sub="GC column";                           catalog="160-2535-5";   brand="Agilent Technologies";         pkg="pack";  specs="Deactivated fused silica (FS) transfer line for GC headspace analysis. Part No.: 160-2535-5.`n`n• Material: Deactivated fused silica capillary tubing`n• Length: 5 m`n• Inner diameter (ID): 0.53 mm`n• Outer diameter (OD): 0.67 mm" }
  @{ no=75; name="Ferrules 0.53mm for Agilent Headspace Sampler";                 cat="Genel Sarf";           sub="GC ferrule";                          catalog="0100-2595";    brand="Agilent Technologies";         pkg="pack";  specs="Polyamide/graphite ferrules for Agilent headspace sampler. Art. No.: 0100-2595.`n`n• Size: 1/32 inch`n• Compatible column ID: 0.53 mm`n• Material: Graphite`n• 5 ferrules per pack" }
  @{ no=76; name="Ferrules 0.53 mm for Headspace";                                cat="Genel Sarf";           sub="GC ferrule";                          catalog="8002-0217";    brand="ELGA VEOLIA";                  pkg="pack";  specs="Graphite ferrules for GC headspace sampler. Art. No.: 8002-0217.`n`n• Inner diameter: 0.8 mm (for 0.53 mm ID columns or smaller)`n• Material: Graphite`n• Maximum temperature: 350°C`n• 10 ferrules per pack" }
  @{ no=77; name="Cartridge LC-140 for Elga Deionizer";                           cat="Su Aritma";            sub="Water purifier pre-treatment cartridge";catalog="LC-140";     brand="ELGA VEOLIA";                  pkg="pack";  specs="LC-140 pre-treatment cartridge for ELGA Medica/Option-R deionizer systems.`n`n• Feed water source: tap water`n• Removes: chlorine, particles, and organic compounds`n• Filtration: 5 µm`n• Material: Activated carbon`n• Service life: 6 months`n`nReplace every 6 months." }
  @{ no=78; name="Cartridge LC-214 for Purelab Deionizer";                        cat="Su Aritma";            sub="Water purifier DI cartridge";         catalog="LC-214";       brand="ELGA VEOLIA";                  pkg="pack";  specs="LC-214 mixed-bed DI purification cartridge for PURELAB flex/Deionizer systems.`n`n• Feed water source: tap water`n• Removes: dissolved ions`n• Material: Mixed-bed resin`n`nReplace every 6 months." }
  @{ no=79; name="UV Lamp 185/254nm LC-210-02 for Purelab";                       cat="Su Aritma";            sub="UV lamp for water purifier";          catalog="LC-210-02";    brand="ELGA VEOLIA";                  pkg="pack";  specs="UV lamp 185/254 nm (LC-210-02) for PURELAB water purification systems.`n`n• Dual wavelength: destroys organic compounds (185 nm) and microorganisms (254 nm)`n• Service life: 12-18 months`n`nReplace every 12-18 months." }
  @{ no=80; name="Composite Air Filter LC 136 M2 for Purelab";                    cat="Su Aritma";            sub="Composite air vent filter";           catalog="LC 136 M2";    brand="ELGA VEOLIA";                  pkg="pack";  specs="LC 136 M2 composite vent filter for PURELAB water purification systems.`n`n• Removes: dissolved gases`n• Filtration: 0.2 µm`n• Prevents recontamination of purified water`n• Service life: 12 months`n`nReplace every 12 months." }
  @{ no=81; name="DI Cartridge Pack LC-141 for Purelab";                          cat="Su Aritma";            sub="Water purifier DI cartridge pack";    catalog="LC-141";       brand="ELGA VEOLIA";                  pkg="pack";  specs="LC-141 DI cartridge pack for PURELAB Medica/Option water purification systems.`n`n• Feed water source: tap water`n• Removes: dissolved ions`n• Material: Mixed-bed resin`n`nReplace every 6 months." }
  @{ no=82; name="Centrifuge tubes 15 ml 500 pcs";                                cat="Genel Sarf";           sub="Centrifuge tube";                     catalog="02-502-8001";  brand="Nerbe Plus, Germany";          pkg="pack";  specs="Centrifuge tubes, 15 mL, with PP tube and PE screw cap.`n`n• Material: Tube — polypropylene (PP); Cap — polyethylene (PE)`n• Dimensions: 17 mm x 120 mm`n• Bottom: Conical`n• Transparent tube with graduated markings`n• Sterile; CE/IVD marked`n• Max. RCF: 17,000 g`n• 500 tubes per pack" }
  @{ no=83; name="Immunochromatographic Test Strips COC mAMP BZO";                cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="00065752";    brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=84; name="Immunochromatographic Test Strips BAR MDMA MTD";                cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="96694";       brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=85; name="Immunochromatographic Test Strips Synthetic cannabinoids";      cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="100299";      brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=86; name="Immunochromatographic Test Strips Ethanol ETG";                 cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="";            brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=87; name="Roll thermal paper";                                             cat="Genel Sarf";           sub="Thermal paper roll";                  catalog="";             brand="T&D Innovationen GmbH";        pkg="pack";  specs="Thermal paper roll for R1-IK-200609-19 analyzer printer.`n`n• Width: 57 mm`n• Length: 10 m per roll`n• Core inner diameter: 12 mm`n• 20 rolls per pack" }
  @{ no=88; name="Immunochromatographic Test Strips COC mAMP BZO set 2";         cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="";            brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=89; name="Immunochromatographic Test Strips BAR MDMA MTD set 2";         cat="Biyokimya";            sub="Immunochromatographic drug test strips";catalog="";            brand="T&D Innovationen GmbH";        pkg="pack";  specs="" }
  @{ no=90; name="Optical Filter D-K-18752-01-00";                                cat="Genel Sarf";           sub="Optical filter";                      catalog="D-K-18752-01-00";brand="Hellma Analytics";           pkg="pack";  specs="Certified neutral density optical filter for spectrophotometer calibration.`n`n• Absorbance: 0.5 Abs`n• For use with Hellma cuvette systems and UV-Vis spectrophotometers`n• Certified reference material for wavelength and absorbance verification" }
  @{ no=91; name="Paraffin for histology";                                        cat="Biyokimya";            sub="Tissue embedding medium";             catalog="X881";         brand="Leica Biosystems";             pkg="kg";    specs="Paraplast Plus — tissue embedding paraffin in pellet/droplet form.`n`n• Density: 0.8 g/cm³`n• Melting point: 56°C`n• Highly purified paraffin with complex elastomers of regulated molecular weights`n• DMSO addition improves infiltration of large and difficult-to-infiltrate tissue samples`n• Superior section quality with minimal compression`n`nStore at room temperature." }
  @{ no=92; name="Formalin 37% non-acidic for histology";                         cat="Biyokimya";            sub="Histological fixative";               catalog="P733";         brand="Carl Roth, Germany";           pkg="liter"; specs="Formaldehyde solution 37% for histological fixation.`n`n• Empirical formula: CH2O | Molar mass: 30.03 g/mol`n• Density: 1.09 g/cm³ | Boiling point: 96°C | Flash point: 62°C`n• CAS No.: 50-00-0 | UN-Nr.: 2209 | ADR 8 III`n• Stabilised with calcium carbonate and methanol (8-12%)`n• Non-acidic formulation`n`nStorage temp: +15 to +25°C. Do not store below 15°C." }
  @{ no=93; name="Abbott IMMTOX 270 Chemistry Analyser Complete System";          cat="Biyokimya";            sub="Clinical chemistry analyzer system";  catalog="IMMTOX 270";   brand="Abbott";                       pkg="set";   specs="ImmTox 270 — benchtop clinical chemistry analyser for toxicology screening.`n`n• Throughput: up to 270 tests/hour; 3 hours continuous unattended operation`n• Sample capacity: 30 patient samples simultaneously`n• Reagent capacity: up to 24 different tests`n• Ideal for 150-1,200 patient samples per month`n• Bidirectional LIS interface`n• 510K cleared`n`nInstallation, CLIA certification and post-commissioning support provided." }
  @{ no=94; name="SoToxa Oral Fluid Mobile Test System";                          cat="Biyokimya";            sub="Oral fluid drug testing system";      catalog="";             brand="Abbott";                       pkg="set";   specs="SoToxa Oral Fluid Mobile Test System — designed for law enforcement field use.`n`n• Objective on-site results eliminating subjective test interpretation`n• Lightweight, portable, compact; full-colour touchscreen`n• Non-invasive oral fluid collection`n• Stores 10,000+ results; printable on demand`n`nDetection cut-off values (ng/mL):`n• Amphetamines: 50 | Benzodiazepines: 20 | Cannabis (THC): 25`n• Cocaine: 30 | Fentanyl: 4 | Methamphetamine: 50 | Opiates: 40`n`nIncludes: 1x SoToxa device, 250x test kits, 25x Quantisal oral fluid collection devices." }
  @{ no=95; name="BIOSENS 900 Trace Detecting Analyzer with all consumables";     cat="Biyokimya";            sub="Trace narcotics and explosives detector";catalog="";           brand="Biosensor";                    pkg="set";   specs="BIOSENS 900 — portable trace detection analyser for narcotics and explosives.`n`n• Detection technology: Immunoassay on S.A.W. sensor`n• Start-up time: 10 min | Analysis time: 30-60 sec per sample`n• Display: 10.1 inch colour TFT touchscreen | Built-in thermal printer`n• Weight: 11.5 kg | Connectivity: Ethernet + USB`n• Operating: 10-40°C | Humidity: 95% non-condensing`n`nSubstances detected: Amphetamines, Methamphetamine, MDA, MDMA, Cocaine, Opiates, THC, Buprenorphine, Fentanyl, Ketamine, TNT, RDX, PETN and more.`n`nConsumables: Sensor cartridge (30-60 days), Activator cartridge (50 runs), Annual maintenance kit." }
)

# ── Generate pages ─────────────────────────────────────────────────────────
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$slugMap     = @{}
$productRows = @()

foreach ($p in $Products) {
    $slug = Get-Slug $p.name
    if ($slugMap.ContainsKey($slug)) { $slugMap[$slug]++; $slug = "$slug-$($slugMap[$slug])" }
    else { $slugMap[$slug] = 1 }
    $productRows += [PSCustomObject]@{ p = $p; slug = $slug }

    $html = Build-Page $p
    [System.IO.File]::WriteAllText("$OutDir\$slug.html", $html, [System.Text.Encoding]::UTF8)
    Write-Host "  OK  products/$slug.html"
}

# ── sitemap.xml ────────────────────────────────────────────────────────────
$base  = 'https://www.greenmed.ltd'
$today = (Get-Date).ToString('yyyy-MM-dd')

$staticUrls = @(
    "  <url>`n    <loc>$base/</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>monthly</changefreq>`n    <priority>1.0</priority>`n  </url>",
    "  <url>`n    <loc>$base/about.html</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>monthly</changefreq>`n    <priority>0.8</priority>`n  </url>",
    "  <url>`n    <loc>$base/projects.html</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>monthly</changefreq>`n    <priority>0.8</priority>`n  </url>",
    "  <url>`n    <loc>$base/products.html</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>weekly</changefreq>`n    <priority>0.9</priority>`n  </url>",
    "  <url>`n    <loc>$base/privacy_policy/privacy-policy.html</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>yearly</changefreq>`n    <priority>0.3</priority>`n  </url>"
)

$productUrls = $productRows | ForEach-Object {
    "  <url>`n    <loc>$base/products/$($_.slug).html</loc>`n    <lastmod>$today</lastmod>`n    <changefreq>monthly</changefreq>`n    <priority>0.7</priority>`n  </url>"
}

$sitemap = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$($staticUrls -join "`n")
$($productUrls -join "`n")
</urlset>
"@

[System.IO.File]::WriteAllText("$ProjectRoot\sitemap.xml", $sitemap, [System.Text.Encoding]::UTF8)
Write-Host "  OK  sitemap.xml"

Write-Host "`nDone — $($Products.Count) product pages + sitemap.xml generated."
Write-Host "Next step: update products.html card links to point to products/<slug>.html"
