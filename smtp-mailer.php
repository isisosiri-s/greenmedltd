<?php
/**
 * Minimal dependency-free SMTP client (AUTH LOGIN, SSL/STARTTLS).
 * Used because the hosting account has PHP's mail() disabled.
 */

function smtp_send(array $cfg, string $to, string $fromEmail, string $fromName, string $replyTo, string $subject, string $body): array {
    $host = $cfg['host'];
    $port = (int) $cfg['port'];
    $encryption = $cfg['encryption'] ?? '';
    $transport = $encryption === 'ssl' ? 'ssl://' . $host : $host;

    $errno = 0; $errstr = '';
    $sock = @stream_socket_client($transport . ':' . $port, $errno, $errstr, 15);
    if (!$sock) {
        return [false, "Connect failed: $errstr ($errno)"];
    }
    stream_set_timeout($sock, 15);

    $read = function () use ($sock) {
        $data = '';
        while ($line = fgets($sock, 515)) {
            $data .= $line;
            if (isset($line[3]) && $line[3] === ' ') break;
        }
        return $data;
    };
    $write = function (string $cmd) use ($sock) {
        fwrite($sock, $cmd . "\r\n");
    };
    $expect = function (string $resp, string $code) {
        return substr($resp, 0, 3) === $code;
    };

    $resp = $read();
    if (!$expect($resp, '220')) { fclose($sock); return [false, "No greeting: $resp"]; }

    $write('EHLO greenmedltduk.com');
    $resp = $read();
    if (!$expect($resp, '250')) { fclose($sock); return [false, "EHLO failed: $resp"]; }

    if ($encryption === 'tls') {
        $write('STARTTLS');
        $resp = $read();
        if (!$expect($resp, '220')) { fclose($sock); return [false, "STARTTLS failed: $resp"]; }
        if (!@stream_socket_enable_crypto($sock, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
            fclose($sock); return [false, 'TLS negotiation failed'];
        }
        $write('EHLO greenmedltduk.com');
        $resp = $read();
        if (!$expect($resp, '250')) { fclose($sock); return [false, "EHLO after STARTTLS failed: $resp"]; }
    }

    $write('AUTH LOGIN');
    $resp = $read();
    if (!$expect($resp, '334')) { fclose($sock); return [false, "AUTH LOGIN not accepted: $resp"]; }

    $write(base64_encode($cfg['username']));
    $resp = $read();
    if (!$expect($resp, '334')) { fclose($sock); return [false, "Username rejected: $resp"]; }

    $write(base64_encode($cfg['password']));
    $resp = $read();
    if (!$expect($resp, '235')) { fclose($sock); return [false, "Auth failed: $resp"]; }

    $write('MAIL FROM:<' . $fromEmail . '>');
    $resp = $read();
    if (!$expect($resp, '250')) { fclose($sock); return [false, "MAIL FROM rejected: $resp"]; }

    $write('RCPT TO:<' . $to . '>');
    $resp = $read();
    if (!$expect($resp, '250')) { fclose($sock); return [false, "RCPT TO rejected: $resp"]; }

    $write('DATA');
    $resp = $read();
    if (!$expect($resp, '354')) { fclose($sock); return [false, "DATA rejected: $resp"]; }

    $headers = [];
    $headers[] = 'From: ' . $fromName . ' <' . $fromEmail . '>';
    $headers[] = 'To: <' . $to . '>';
    $headers[] = 'Reply-To: ' . $replyTo;
    $headers[] = 'Subject: ' . $subject;
    $headers[] = 'MIME-Version: 1.0';
    $headers[] = 'Content-Type: text/plain; charset=UTF-8';
    $headers[] = 'Date: ' . date('r');

    // Dot-stuff lines starting with '.' per SMTP spec.
    $escapedBody = preg_replace('/^\./m', '..', $body);

    $write(implode("\r\n", $headers) . "\r\n\r\n" . $escapedBody . "\r\n.");
    $resp = $read();
    if (!$expect($resp, '250')) { fclose($sock); return [false, "Message rejected: $resp"]; }

    $write('QUIT');
    fclose($sock);

    return [true, 'OK'];
}
