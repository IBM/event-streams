---
title: "Installing"
permalink: /installing/installing/
excerpt: "Installing the Community Edition of IBM Event Streams."
last_modified_at:
toc: false
---

Install {{site.data.reuse.long_name}} as follows.

1. Ensure you have set up your environment [according to the prerequisites](../prerequisites).
2. Ensure you have [planned for your installation](../planning), including setting up a namespace.
3. To install {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}), [download it](../downloading) first and make it available in the catalog.
4. Install {{site.data.reuse.long_name}} by using the helm chart as follows:
    1. Click **Catalog** in the top navigation menu.
    2. Select the {{site.data.reuse.long_name}} edition you want to install:
    * To install {{site.data.reuse.ce_long}}, search for `ibm-eventstreams-dev` and select it from the result.
    * To install {{site.data.reuse.long_name}}, search for `ibm-eventstreams-prod` and select it from the result.
    * The {{site.data.reuse.long_name}} README is displayed.
    3. You can install {{site.data.reuse.long_name}} by using the UI or the CLI.
      * To use the UI, click **Configure**, and go to the next step.
      * To use the CLI, follow the instructions in the README instead of clicking **Configure** and following the following steps.
    4. Enter a release name, select the target namespace you created previously, and accept the terms of the license agreement.
    5. Configure the settings for your installation as described in [configuring](../configuring). Configuration options to consider include setting up persistent storage, external access, and preparing for geo-replication.\\
       **Important:** If you are installing {{site.data.reuse.long_name}} by using an image downloaded from IBM Passport Advantage, ensure you [configure the image pull secret settings](../configuring/#global-installation-settings), such as the Docker image registry and the name of the secret created previously.\\
       **Note:** Ensure the **Docker image registry** value under the **All parameters** section does not have a trailing slash, for example: `mycluster.icp:8500/ibmcom`
    6. Click **Install**.
5. [Verify your installation](../post-installation/#verifying-your-installation) and consider other post-installation tasks.
