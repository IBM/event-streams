---
title: "UI does not open when using Chrome on Ubuntu"
permalink: /troubleshooting/chrome-ubuntu-issue/
excerpt: "When using Google Chrome browser on Ubuntu operating systems, the Event Streams UI does not open."
last_modified_at:
toc: true
---

## Symptoms

When using a Google Chrome browser on Ubuntu operating systems, the {{site.data.reuse.long_name}} UI does not open, and the browser displays an error message about invalid certificates, similar to the following example:

```
192.0.2.24 normally uses encryption to protect your information.
When Google Chrome tried to connect to 192.0.2.24 this time, the website sent back unusual and incorrect credentials.
This may happen when an attacker is trying to pretend to be 192.0.2.24, or a Wi-Fi sign-in screen has interrupted the connection.
Your information is still secure because Google Chrome stopped the connection before any data was exchanged.

You cannot visit 192.0.2.24 at the moment because the website sent scrambled credentials that Google Chrome cannot process.
Network errors and attacks are usually temporary, so this page will probably work later.
```

## Causes

The Google Chrome browser on Ubuntu systems requires a certificate that {{site.data.reuse.long_name}} does not currently provide.

## Resolving the problem

Use a different browser, such as Firefox, or launch Google Chrome with the following option: `--ignore-certificate-errors`
