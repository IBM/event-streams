---
title: "Trying out Event Streams"
excerpt: "Install a basic deployment to try out IBM Event Streams."
categories: installing
slug: trying-out
layout: redirects
toc: false
---

To try out {{site.data.reuse.short_name}}, you can install a basic deployment of the {{site.data.reuse.ce_short}}.

{{site.data.reuse.ce_long}} is a free version intended for trial and demonstration purposes. It can be installed and used without charge.

**Note:** These instructions do not include setting up persistent storage, so your data and configuration settings are not retained in the event of a restart.

For more features and full IBM support, [install {{site.data.reuse.long_name}}](../installing).

1. If you do not have {{site.data.reuse.icp}} installed already, you can download and [install IBM Cloud Private-CE](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/installing/install_containers.html){:target="_blank"}.\\
   **Note:** {{site.data.reuse.ce_long}} is not supported on {{site.data.reuse.openshift}}.
2. {{site.data.reuse.icp_ui_login}}\\
   The default user name is `admin`, and the default password is `admin`.
3. Create a namespace where you will install your {{site.data.reuse.short_name}} instance:\\
   1. From the navigation menu, click **Manage > Namespaces**.
   3. Click **Create Namespace**.
   3. Enter a name for your namespace.
   4. Ensure you have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.
   5. Click **Create**.
4. Click **Catalog** in the top navigation menu.
4. Search for `ibm-eventstreams-dev` and select it from the result. This is the Helm chart for the {{site.data.reuse.ce_long}}. The README is displayed.
5. Click **Configure**.
6. Enter a release name, select the target namespace you created previously, and accept the terms of the license agreement.\\
   You can leave all other settings at their default values.
7. Click **Install**.
8. [Verify your installation and log in](../post-installation/#verifying-your-installation) to start using {{site.data.reuse.short_name}}.

These steps install a basic instance of {{site.data.reuse.ce_long}} that you can try out. You can also [configure](../configuring) your installation to change the default settings as required, for example, to set up [persistent storage](../planning/#persistent-storage).

{{site.data.reuse.geo-rep_note}}
