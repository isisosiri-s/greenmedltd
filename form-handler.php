<?php
/**
 * Receives POST submissions from the Contact, Proposal, and per-product
 * quote-request forms (English and Russian versions) and emails them to
 * the GREEN MED inbox.
 */

header('Content-Type: application/json; charset=UTF-8');

require __DIR__ . '/smtp-mailer.php';

$smtpConfigFile = __DIR__ . '/smtp-config.php';
if (!file_exists($smtpConfigFile)) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'SMTP not configured']);
    exit;
}
$smtpConfig = require $smtpConfigFile;

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

// Honeypot: real visitors never see or fill this field, bots often do.
if (!empty($_POST['website'])) {
    echo json_encode(['ok' => true]);
    exit;
}

function field(string $key): string {
    if (!isset($_POST[$key]) || is_array($_POST[$key])) return '';
    return trim(str_replace(["\r", "\n"], ' ', (string) $_POST[$key]));
}

function fieldMulti(string $key): string {
    if (empty($_POST[$key]) || !is_array($_POST[$key])) return '';
    $clean = array_map(fn($v) => trim(str_replace(["\r", "\n"], ' ', (string) $v)), $_POST[$key]);
    return implode(', ', array_filter($clean, fn($v) => $v !== ''));
}

$formTypes = [
    'proposal' => 'Proposal Form',
    'quote'    => 'Product Quote Request',
];

$to       = 'support@greenmedltduk.com';
$formType = $formTypes[field('_form')] ?? 'Contact Form';
$name     = field('name');
$email    = field('email');

if ($name === '' || $email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Invalid submission']);
    exit;
}

$skip  = ['_form', 'website'];
$lines = ["New " . $formType . " submission from greenmedltduk.com", str_repeat('-', 40), ''];

foreach ($_POST as $key => $value) {
    if (in_array($key, $skip, true)) continue;
    $label = ucfirst(str_replace('_', ' ', rtrim($key, '[]')));
    $val   = is_array($value) ? fieldMulti($key) : field($key);
    if ($val === '') continue;
    $lines[] = $label . ': ' . $val;
}

$body = implode("\n", $lines);
$subjectLine = '=?UTF-8?B?' . base64_encode('[GREEN MED Website] ' . $formType . ' - ' . $name) . '?=';

[$sent, $err] = smtp_send(
    $smtpConfig,
    $to,
    $smtpConfig['username'],
    'GREEN MED Website',
    $name . ' <' . $email . '>',
    $subjectLine,
    $body
);

if (!$sent) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Mail delivery failed']);
    exit;
}

echo json_encode(['ok' => true]);
