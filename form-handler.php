<?php
/**
 * Receives POST submissions from the Contact and Proposal forms (English
 * and Russian versions) and emails them to the GREEN MED inbox.
 */

header('Content-Type: application/json; charset=UTF-8');

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

$to       = 'support@greenmedltduk.com';
$formType = field('_form') === 'proposal' ? 'Proposal Form' : 'Contact Form';
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

$headers  = "From: Website <no-reply@greenmedltduk.com>\r\n";
$headers .= "Reply-To: " . $name . " <" . $email . ">\r\n";
$headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

$sent = @mail($to, $subjectLine, $body, $headers);

if (!$sent) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Mail delivery failed']);
    exit;
}

echo json_encode(['ok' => true]);
