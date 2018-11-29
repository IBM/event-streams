---
title: "Installing"
permalink: /installing/installing/
excerpt: "Installing IBM Event Streams."
toc: true
---

{{site.data.reuse.long_name}} is the paid-for version intended for enterprise use, and includes full IBM support and additional features such as geo-replication.

You can also install a basic deployment of {{site.data.reuse.short_name}} to [try it out](../trying-out).

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites).
- Ensure you have [planned for your installation](../planning), including setting up a namespace, and planning for persistent volumes if required, or creating a ConfigMap for Kafka static configuration.
- Ensure you have [downloaded](../downloading) the installation image and made it available in the {{site.data.reuse.icp}} catalog.

## Preparing the repository

Prepare your repository for the installation as follows.

**Note:** Before running `kubectl` commands as instructed in any the following steps, log in to your {{site.data.reuse.icp}} cluster as an administrator using the CLI as follows:\\
`cloudctl login -a https://<master-ip>:8443 --skip-ssl-validation`

### Create an image pull secret

Create an image pull secret for the [namespace](../planning/#namespaces) where you intend to install {{site.data.reuse.long_name}}. The secret enables access to the internal docker repository provided by {{site.data.reuse.icp}}.

To create a secret, use the following command:

`kubectl create secret docker-registry regcred --docker-server=<cluster_CA_domain>:8500 --docker-username=<user-name> --docker-password=<password> --docker-email=<your-email> -n <namespace>`

For example:

`kubectl create secret docker-registry regcred --docker-server=mycluster.icp:8500 --docker-username=admin --docker-password=admin --docker-email=john.smith@ibm.com -n event-streams`

For more information about creating image pull secrets, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/imagepullsecret.html).

### Create an image policy

Create an image policy for the internal docker repository. The policy enables images to be retrieved during installation.\\
To create an image policy:

1. Create a `.yaml` file with the following content, then change `<cluster_CA_domain>` to the correct value for your {{site.data.reuse.icp}} environment, and change the `namespace` value to where you intend to install {{site.data.reuse.long_name}}:
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
  - name: <cluster_CA_domain>:8500/*
        policy: null
 ```
2. Run the following command: `kubectl apply -f <filename>.yaml`

For more information about container image security, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html).

## Installing the {{site.data.reuse.short_name}} chart

Install the {{site.data.reuse.short_name}} chart as follows.

1. {{site.data.reuse.icp_ui_login}}\\
   Ensure you log in as a user that has the Cluster Administrator role.
2. Click **Catalog** in the top navigation menu.
2. Search for `ibm-eventstreams-prod` and select it from the result. The {{site.data.reuse.long_name}} README is displayed.
3. Click **Configure**.\\
   **Note:** The README includes information about how to install {{site.data.reuse.long_name}} by using the the CLI. To use the CLI, follow the instructions in the README instead of clicking **Configure**.
4. Enter a release name, select the target namespace you created previously, and accept the terms of the license agreement.
5. Expand the **All parameters** section to configure the settings for your installation as described in [configuring](../configuring). Configuration options to consider include setting up persistent storage, external access, and preparing for geo-replication.\\
   **Important:** As part of the configuration process, enter the name of the [secret](#preparing-the-repository) you created previously in the [**Image pull secret**](../configuring/#global-install-settings) field.\\
   **Note:** Ensure the [**Docker image registry**](../configuring/#global-install-settings) field value does not have a trailing slash, for example: `mycluster.icp:8500/ibmcom`
6. Click **Install**.
7. [Verify your installation](../post-installation/#verifying-your-installation) and consider other post-installation tasks.
