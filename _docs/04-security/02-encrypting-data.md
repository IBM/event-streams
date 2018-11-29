---
title: "Encrypting your data"
permalink: /security/encrypting-data/
excerpt: "Encrypt your data to improve security."
 
toc: false
---

Network connections into the {{site.data.reuse.long_name}} deployment are secured using TLS. By default, data within the {{site.data.reuse.long_name}} deployment is not encrypted. To secure this data, you must ensure that any storage and communication channels are encrypted as follows:

* Encrypt data at rest by using disk encryption or encrypting volumes using [dm-crypt](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/etcd.html).
* Encrypt internal network traffic within the cluster with [IPSec](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/ipsec_mesh.html).
* Encrypt messages in applications.
