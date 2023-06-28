---
title: "UI does not open when using Chrome on macOS Catalina"
excerpt: "When using Google Chrome browser on the latest versions of macOS operating systems, the Event Streams UI does not open."
categories: troubleshooting
slug: chrome-macos-issue
layout: redirects
toc: true
---

## Symptoms

When using a Google Chrome browser on the latest versions of macOS operating systems, the {{site.data.reuse.long_name}} UI does not open, and the browser displays an error message about invalid certificates, similar to the following example:

```
192.0.2.24 normally uses encryption to protect your information.
When Google Chrome tried to connect to 192.0.2.24 this time, the website sent back unusual and incorrect credentials.
This may happen when an attacker is trying to pretend to be 192.0.2.24, or a Wi-Fi sign-in screen has interrupted the connection.
Your information is still secure because Google Chrome stopped the connection before any data was exchanged.

You cannot visit 192.0.2.24 at the moment because the website sent scrambled credentials that Google Chrome cannot process.
Network errors and attacks are usually temporary, so this page will probably work later.
```

## Causes

Security rules in macOS version 10.15 Catalina and later do not allow the certificate presented by {{site.data.reuse.short_name}} to be used.

## Resolving the problem

Use one of the following workarounds to avoid this problem:

- Install {{site.data.reuse.short_name}} with provided certificates, or [change](../../security/updating-certificates/) them to provided instead of using generated (self-signed) certificates.
- Use a different browser, such as Mozilla Firefox.
- Launch Google Chrome with the following option: `--ignore-certificate-errors`\\
   For example, launch a terminal and run the following command:\\
   `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --ignore-certificate-errors &> /dev/null &`
- Install the {{site.data.reuse.icp}} root CA in your macOS keychain. Obtain the certificate by using the following command:\\
   `kubectl get secret cluster-ca-cert -n kube-system -o jsonpath="{.data['tls\.crt']}" | base64 -D > cluster-ca-cert.pem`

   Use the [Keychain Access app](https://support.apple.com/guide/keychain-access/kyca1083/mac){:target="_blank"} in macOS to add the certificate and mark it as trusted.
