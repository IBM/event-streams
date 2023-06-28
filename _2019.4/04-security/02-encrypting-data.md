---
title: "Encrypting your data"
excerpt: "Encrypt your data to improve security."
categories: security
slug: encrypting-data
layout: redirects
toc: true
---

Network connections into the {{site.data.reuse.long_name}} deployment are secured using TLS. By default, data within the {{site.data.reuse.short_name}} deployment is not encrypted. To secure this data, you must ensure that any storage and communication channels are encrypted as follows:

* Encrypt data at rest by using disk encryption or encrypting volumes using [dm-crypt](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/installing/etcd.html){:target="_blank"}.
* Encrypt internal network traffic by using [TLS encryption](#enabling-encryption-between-pods) for communication between pods.
* Encrypt messages in applications.


## Enabling encryption between pods

By default, TLS encryption for communication between pods is disabled. You can enable it when installing {{site.data.reuse.short_name}}, or you can enable it later as described in this section.

To enable TLS encryption for your existing {{site.data.reuse.short_name}} installation, use the UI or the command line.

- To enable TLS by using the UI, follow the instructions in [modifying installation settings](../../administering/modifying-installation/#using-the-ui), and set the **Pod to pod encryption** field of the **Global install settings** section to **Enabled**.
- To enable TLS by using the command line, follow the instructions in [modifying installation settings](../../administering/modifying-installation/#using-the-cli), and set the `global.security.tlsInternal` parameter to `enabled` as follows:

   `helm upgrade --reuse-values --set global.security.tlsInternal=enabled <release_name> <charts.tgz> --tls`

   For example:\\
   `helm upgrade --reuse-values --set global.security.tlsInternal=enabled eventstreams ibm-eventstreams-prod-1.4.0.tgz --tls`

**Warning:** If you enable TLS encryption between pods, the message browser will not display message data from before the upgrade.

**Important:** Enabling TLS encryption between pods might impact the connection to {{site.data.reuse.short_name}}.
