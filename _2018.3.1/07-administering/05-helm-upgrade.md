---
title: "Running Helm upgrade commands"
excerpt: "To run helm upgrade commands, you must have a copy of the original Helm charts file that you used to install IBM Event Streams."
categories: administering
slug: helm-upgrade-command
layout: redirects
toc: false
---

You can use the `helm upgrade` command to upgrade your chart version or to modify configuration settings for your {{site.data.reuse.short_name}} installation. To run Helm upgrade commands, you must have a copy of the original Helm charts file that you used to install {{site.data.reuse.long_name}}.

To retrieve the charts file using the UI:
1. {{site.data.reuse.icp_ui_login}}
2. Click **Catalog** in the top navigation menu.
3. If you are using the {{site.data.reuse.ce_short}}, search for `ibm-eventstreams-dev` and select it from the result. If you are using {{site.data.reuse.short_name}}, search for `ibm-eventstreams-prod` and select it from the result.
4. Select the latest version number from the drop-down list on the left.
5. To download the file, go to the **SOURCE & TAR FILES** section on the left and click the link. \\
   The `ibm-eventstreams-dev-<version>.tgz` file is downloaded.

Alternatively, if you downloaded {{site.data.reuse.long_name}} from IBM Passport Advantage, you can also retrieve the charts file by looking for a file called `ibm-eventstreams-prod-<version>.tgz` within the downloaded archive. If you no longer have a copy, you can download the file again from IBM Passport Advantage.
