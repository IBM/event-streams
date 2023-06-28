---
title: "Encrypting your data"
excerpt: "Encrypt your data to improve security."
categories: security
slug: encrypting-data
layout: redirects
toc: true
---

The following encryption is always provided in {{site.data.reuse.long_name}}:

- Network connections into the {{site.data.reuse.short_name}} deployment from external clients are secured using TLS.
- Kafka replication between brokers is also TLS encrypted.

Consider the following for encryption as well:
- Internal Kafka listeners can be configured with or without encryption as described in [configuring access](../../installing/configuring/#configuring-access).
- The REST producer endpoint can be configured with or without encryption as described in [configuring access](../../installing/configuring/#configuring-access).

In addition, you can supplement the existing data encryption with disk encryption where supported by your chosen storage provider. You can also encrypt messages within your applications before producing them.
