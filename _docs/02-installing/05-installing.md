---
title: "Installing"
permalink: /installing/installing/
excerpt: "Installing the Community Edition of IBM Event Streams."

toc: false
---

Install {{site.data.reuse.long_name}} as follows.

**Note:** Before running `kubectl` commands as instructed in any the following steps, log in to your {{site.data.reuse.icp}} cluster as an administrator using the CLI as follows: `cloudctl login -a https://<master-ip>:8443 --skip-ssl-validation`

1. Ensure you have set up your environment [according to the prerequisites](../prerequisites).
2. Ensure you have [planned for your installation](../planning), including setting up a namespace.
3. To install {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}), [download it](../downloading) first and make it available in the catalog.
4. When installing {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}), ensure you create an image pull secret for the [namespace](../planning/#namespaces) where you intend to install {{site.data.reuse.long_name}}. The secret enables access to the internal docker repository provided by {{site.data.reuse.icp}}. To create a secret: \\
    `kubectl create secret docker-registry regcred --docker-server=<cluster_CA_domain>:8500 --docker-username=<user-name> --docker-password=<password> --docker-email=<your-email> -n <namespace>` \\
   For example: \\
   `kubectl create secret docker-registry regcred --docker-server=mycluster.icp:8500 --docker-username=admin --docker-password=admin --docker-email=john.smith@ibm.com -n event-streams` \\
   For more information about creating image pull secrets, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/imagepullsecret.html).
5. When installing {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}), ensure you create an image policy for the internal docker repository. The policy enables images to be retrieved during installation.\\
    To create an image policy:\\
    1. Create a `.yaml` file with the following content, and change the `namespace` value to where you intend to install {{site.data.reuse.long_name}}:\\
    ```
    apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
    kind: ImagePolicy
    metadata:
     name: image-policy
     namespace: event-streams
    spec:
     repositories:
     - name: docker.io/*
           policy: null
     - name: mycluster.icp:8500/*
           policy: null
    ```
    2. Run the following command: `kubectl apply -f <filename>.yaml`\\
    For more information about container image security, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/image_security.html).
6. Install {{site.data.reuse.long_name}} by using the helm chart as follows:
    1. Click **Catalog** in the top navigation menu.
    2. Select the {{site.data.reuse.long_name}} edition you want to install:
    * To install {{site.data.reuse.ce_long}}, search for `ibm-eventstreams-dev` and select it from the result.
    * To install {{site.data.reuse.long_name}}, search for `ibm-eventstreams-prod` and select it from the result. \\
    The {{site.data.reuse.long_name}} README is displayed.
    3. You can install {{site.data.reuse.long_name}} by using the UI or the CLI.
      * To use the UI, click **Configure**, and go to the next step.
      * To use the CLI, follow the instructions in the README instead of clicking **Configure** and following the steps here.
    4. Enter a release name, select the target namespace you created previously, and accept the terms of the license agreement.
    5. Configure the settings for your installation as described in [configuring](../configuring). Configuration options to consider include setting up persistent storage, external access, and preparing for geo-replication.\\
       **Important:** If you are installing {{site.data.reuse.long_name}} by using an image downloaded from IBM Passport Advantage, enter the name of the secret created previously in the [**Image pull secret**](../configuring/#global-install-settings) field.\\
       **Note:** Ensure the [**Docker image registry**](../configuring/#global-install-settings) field value does not have a trailing slash, for example: `mycluster.icp:8500/ibmcom`
    6. Click **Install**.
7. [Verify your installation](../post-installation/#verifying-your-installation) and consider other post-installation tasks.
