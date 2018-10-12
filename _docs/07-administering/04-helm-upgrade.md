---
title: "Running Helm upgrade commands"
permalink: /administering/helm-upgrade-command/
excerpt: "To run helm upgrade commands, you must have a copy of the original Helm charts file that you used to install IBM Event Streams."
last_modified_at:
toc: false
---

You can use the `helm upgrade` command to upgrade your chart version or to modify configuration settings for your deployment, for example, for [scaling purposes](../scaling/). To run Helm upgrade commands, you must have a copy of the original Helm charts file that you used to install {{site.data.reuse.long_name}}.

To retrieve the charts file for {{site.data.reuse.ce_long}}:
1. {{site.data.reuse.icp_ui_login}}
2. Click **Catalog** in the top navigation menu.
3. Search for `ibm-eventstreams-dev` and select it from the result.
4. To download the file, go to the **SOURCE & TAR FILES** section on the left and click the link. \\
   The `ibm-eventstreams-dev-<version>.tgz` file is downloaded.

To retrieve the charts file for {{site.data.reuse.long_name}} downloaded from IBM Passport Advantage, look for a file called `ibm-eventstreams-prod-<version>.tgz`. If you no longer have a copy, you can download the file again from [IBM Passport Advantage](https://www-01.ibm.com/software/passportadvantage/pao_customer.html).
