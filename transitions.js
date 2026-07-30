/* Shared page-transition fade — dims the page before internal navigation,
   so link clicks don't cut straight to a blank flash of the next page. */
(function () {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  document.addEventListener('click', (e) => {
    const link = e.target.closest('a[href]');
    if (!link || link.target === '_blank' || link.hasAttribute('download')) return;
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button !== 0) return;
    const href = link.getAttribute('href');
    if (!href || href.startsWith('#') || href.startsWith('mailto:') || href.startsWith('tel:')) return;
    let url;
    try { url = new URL(href, window.location.href); } catch (err) { return; }
    if (url.origin !== window.location.origin) return;
    if (url.pathname === window.location.pathname && url.hash) return;
    e.preventDefault();
    document.body.classList.add('page-transitioning');
    setTimeout(() => { window.location.href = url.href; }, 260);
  });

  window.addEventListener('pageshow', () => {
    document.body.classList.remove('page-transitioning');
  });
})();
