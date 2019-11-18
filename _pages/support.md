---
layout: collection
title: "Support"
collection: support
permalink: /support/
author_profile: false
mastheadNavItem: Support
sort_by: title
# toc: true
sections:
  - name: IBM Event Streams support
    description: Let us know what you think about IBM Event Streams.
---

## Support matrix

{{site.data.reuse.short_name}} version | Helm chart version | Kafka version shipped | Container platform               | Systems
---------------------------------------|--------------------|-----------------------|----------------------------------|--------------------
2019.4.1                               | 1.4.0              | 2.3.0                 |  {{site.data.reuse.openshift}} 3.11 with IBM cloud foundational services 3.2.1* | - Linux® 64-bit (x86_64) systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)
2019.2.3 <br> **Note:** Only available in <br>[IBM Cloud Pak for Integration](../2019.2.1/about/whats-new/).  | 1.3.2   | 2.2.0 | {{site.data.reuse.openshift}} 3.11 with IBM cloud foundational services 3.2.0.1907* (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"})  | &nbsp;
 2019.2.2 <br> **Note:** Only available in <br>[IBM Cloud Pak for Integration](../2019.2.1/about/whats-new/).  | 1.3.1  | 2.2.0 | {{site.data.reuse.openshift}} 3.11 with IBM cloud foundational services 3.2.0.1907* (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"})  | &nbsp;
2019.2.1                               | 1.3.0          | 2.2.0      | {{site.data.reuse.openshift}} 3.11 with IBM cloud foundational services 3.2.0.1907* (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"}) and 3.2.1 *  | &nbsp; |
 &nbsp;             |         |       | {{site.data.reuse.openshift}} 3.10 with IBM cloud foundational services 3.1.2* | &nbsp; |
2019.1.1                              |  1.2.0          | 2.1.1      | {{site.data.reuse.openshift}} 3.9 and 3.10 with IBM cloud foundational services 3.1.2*  | &nbsp; |

 *Provided by {{site.data.reuse.icp}}

## Historically supported Kubernetes platforms

{{site.data.reuse.short_name}} version | Helm chart version | Kafka version shipped | Container platform               | Systems
---------------------------------------|--------------------|-----------------------|----------------------------------|--------------------
2019.4.1                               | 1.4.0              | 2.3.0                 | {{site.data.reuse.icp}} 3.2.1  |   - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® z13 or later systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)
2019.2.3 <br> **Note:** Only available in <br>[IBM Cloud Pak for Integration](../2019.2.1/about/whats-new/).  | 1.3.2   | 2.2.0 | {{site.data.reuse.icp}} 3.2.0.1907 (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"}) | - Linux® 64-bit (x86_64) system <br/>- Linux on IBM® z13 or later systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)
 2019.2.2 <br> **Note:** Only available in <br>[IBM Cloud Pak for Integration](../2019.2.1/about/whats-new/).  | 1.3.1  | 2.2.0 | {{site.data.reuse.icp}} 3.2.0.1907 (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"})  | - Linux® 64-bit (x86_64) system <br/>- Linux on IBM® z13 or later systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)
2019.2.1                               | 1.3.0          | 2.2.0      | {{site.data.reuse.icp}} 3.1.2, 3.2.0.1907 (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"}), and 3.2.1 |  - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® z13 or later systems <br> - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS)
2019.1.1                              |  1.2.0          | 2.1.1      | {{site.data.reuse.icp}} 3.1.1, 3.1.2, and 3.2.0.1907 (or later [fix pack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_cluster/patching_cluster.html){:target="_blank"}) |  - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® Z systems                                                                               |               |
 &nbsp;             |   |   | {{site.data.reuse.icp}} 3.1.2  | - Microsoft Azure (IaaS) <br> - Amazon Web Services (IaaS) |
 2018.3.1  | 1.1.0  | 2.0.1  | {{site.data.reuse.icp}} 3.1.1 and 3.1.2  | - Linux® 64-bit (x86_64) systems <br/>- Linux on IBM® Z systems
  |   |   | {{site.data.reuse.icp}} 3.1.0  | Linux® 64-bit (x86_64) systems
 2018.3.0  | 1.0.0  | 2.0  | {{site.data.reuse.icp}} 3.1.0  | Linux® 64-bit (x86_64) systems

## Support policy

{{site.data.reuse.long_name}} incorporates both IBM proprietary and open source components, including Apache Kafka. In case of a problem with any of these components, IBM will investigate, identify, and provide a fix when possible. Where the fix applies to an open source component, IBM will work with the open source community to contribute the fix to the open source project as appropriate.

If you encounter client-side issues when using {{site.data.reuse.short_name}} with clients that are not provided by IBM, IBM can assist you in working with the open source community to resolve those issues.

## Continuous Delivery (CD) support model

{{site.data.reuse.long_name}} uses the continuous delivery (CD) support model.

Ensure you stay current with the installation of CD update packages, as described in [the continuous delivery life cycle policy](https://www.ibm.com/support/docview.wss?uid=ibm10718163){:target="_blank"}. Product defect fixes and security updates are only available for the two most current CD update packages.
