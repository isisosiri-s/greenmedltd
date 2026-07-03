<?php
/**
 * Copy this file to smtp-config.php (same directory) and fill in the real
 * values. smtp-config.php is gitignored — it holds a real mailbox password
 * and must never be committed. Upload it to the server manually via FTP.
 */

return [
    'host'       => 'mail.greenmedltduk.com', // SMTP server hostname from cPanel
    'port'       => 465,                       // 465 = SSL, 587 = STARTTLS
    'encryption' => 'ssl',                     // 'ssl' or 'tls' (STARTTLS) or '' for none
    'username'   => 'no-reply@greenmedltduk.com',
    'password'   => 'REPLACE_WITH_REAL_PASSWORD',
];
