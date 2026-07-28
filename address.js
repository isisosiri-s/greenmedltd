/* Single source of truth for the company address.
   Mark any element with data-company-address="inline" or "multiline"
   and this script fills it in from ADDRESS below — update the address
   here once and every page that uses the attribute stays in sync. */
(function () {
  var ADDRESS = {
    street: '39 Charing Cross Road',
    city: 'London',
    postalCode: 'WC2H 0AR',
    country: 'United Kingdom'
  };

  function inline() {
    return ADDRESS.street + ', ' + ADDRESS.city + ', ' +
      ADDRESS.postalCode + ', ' + ADDRESS.country;
  }

  function multiline() {
    return ADDRESS.street + '<br>' + ADDRESS.city + ', ' + ADDRESS.postalCode +
      '<br>' + ADDRESS.country;
  }

  function fill() {
    var nodes = document.querySelectorAll('[data-company-address]');
    for (var i = 0; i < nodes.length; i++) {
      var format = nodes[i].getAttribute('data-company-address');
      nodes[i].innerHTML = format === 'multiline' ? multiline() : inline();
    }
  }

  window.COMPANY_ADDRESS = ADDRESS;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fill);
  } else {
    fill();
  }
})();
