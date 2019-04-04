---
title: "Installing"
excerpt: "Installing IBM Event Streams."
categories: installing
slug: installing
toc: true
---

{{site.data.reuse.long_name}} is the paid-for version intended for enterprise use, and includes full IBM support and additional features such as geo-replication.

You can also install a basic deployment of {{site.data.reuse.short_name}} to [try it out](../trying-out).

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites), including your {{site.data.reuse.icp}} environment.
- Ensure you have [planned for your installation](../planning), such as planning for persistent volumes if required, and creating a ConfigMap for Kafka static configuration.

## Preparing the platform

Prepare your platform for installing {{site.data.reuse.short_name}} as follows.

### Create a namespace

You must use a namespace that is dedicated to your {{site.data.reuse.short_name}} deployment. This is required because {{site.data.reuse.short_name}} uses network security policies to restrict network connections between its internal components.

If you plan to have multiple {{site.data.reuse.short_name}} instances, create namespaces to organize your {{site.data.reuse.long_name}} deployments into, and control user access to them.

You must have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp) selected for the target namespace.

To create a namespace, you must have the Cluster administrator role. See the {{site.data.reuse.icp}} documentation for more information about [creating namespaces](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/user_management/create_project.html).

### Download the archive

Download the {{site.data.reuse.long_name}} installation image file from the IBM Passport Advantage site and make it available in your catalog.

1. Go to [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/pao_customer.html), and search for "{{site.data.reuse.long_name}}". Download the images related to the part numbers for your platform (for example, the {{site.data.reuse.short_name}} package for the {{site.data.reuse.openshift}} includes `rhel` in the package name).
2. Ensure you [configure your Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_images/configuring_docker_cli.html) to access your cluster.
3. Log in to your cluster from the {{site.data.reuse.icp}} CLI and log in to the Docker private image registry:
   ```
   cloudctl login -a https://<cluster_CA_domain>:8443 --skip-ssl-validation
   docker login <cluster_CA_domain>:8500
   ```
   **Note:** The default value for the `cluster_CA_domain` parameter is `mycluster.icp`. If necessary add an entry to your system's host file to allow it to be resolved. For more information, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/installing/install_entitled_workloads.html).
4. Install the {{site.data.reuse.short_name}} Helm chart by using the compressed image you downloaded from IBM Passport Advantage.\\
   `cloudctl catalog load-archive --archive <PPA-image-name.tar.gz>`\\
   When the image installation completes successfully, the catalog is updated with the {{site.data.reuse.long_name}} local chart, and the internal Docker repository is populated with the Docker images used by {{site.data.reuse.long_name}}.

## Preparing the repository

Prepare your repository for the installation as follows.

**Note:** Before running `kubectl` commands as instructed in any the following steps, log in to your {{site.data.reuse.icp}} cluster as an administrator by using `cloudctl login`.

### Create an image pull secret

Create an image pull secret for the namespace where you intend to install {{site.data.reuse.short_name}} (this is the namespace created earlier). The secret enables access to the internal Docker repository provided by {{site.data.reuse.icp}}.

To create a secret, use the following command:

`kubectl create secret docker-registry regcred --docker-server=<cluster_CA_domain>:8500 --docker-username=<user-name> --docker-password=<password> --docker-email=<your-email> -n <namespace_for_event_streams>`

For example:

`kubectl create secret docker-registry regcred --docker-server=mycluster.icp:8500 --docker-username=admin --docker-password=admin --docker-email=john.smith@ibm.com -n event-streams`

For more information about creating image pull secrets, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/imagepullsecret.html).

### Create an image policy

Create an image policy for the internal Docker repository. The policy enables images to be retrieved during installation.\\
To create an image policy:

1. Create a `.yaml` file with the following content, then replace `<cluster_CA_domain>` with the correct value for your {{site.data.reuse.icp}} environment, and replace the `<namespace_for_event_streams>` value with the name where you intend to install {{site.data.reuse.long_name}} (set as `-n event-streams` in the previous example):
```
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ImagePolicy
metadata:
  name: image-policy
  namespace: <namespace_for_event_streams>
spec:
  repositories:
  - name: docker.io/*
       policy: null
  - name: <cluster_CA_domain>:8500/*
       policy: null
```
2. Run the following command: `kubectl apply -f <filename>.yaml`

For more information about container image security, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html).

## Installing the {{site.data.reuse.short_name}} chart

Install the {{site.data.reuse.short_name}} chart as follows.

1. {{site.data.reuse.icp_ui_login}}\\
   Ensure you log in as a user that has the Cluster Administrator role.
2. Click **Catalog** in the top navigation menu.
2. Search for `ibm-eventstreams-prod` and select it from the result. The {{site.data.reuse.long_name}} README is displayed.
3. If you are installing {{site.data.reuse.short_name}} on {{site.data.reuse.icp}} 3.1.1 running on Red Hat Enterprise Linux, [remove AppArmor settings](../../troubleshooting/pods-apparmor-blocked/) in the PodSecurityPolicy to avoid installation issues.
3. Click **Configure**.\\
   **Note:** The README includes information about how to install {{site.data.reuse.long_name}} by using the CLI. To use the CLI, follow the instructions in the README instead of clicking **Configure**.
4. Enter a release name that identifies your {{site.data.reuse.short_name}} installation, select the target namespace you created previously, and accept the terms of the license agreement.
5. Expand the **All parameters** section to configure the settings for your installation as described in [configuring](../configuring). Configuration options to consider include setting up persistent storage, external access, and preparing for geo-replication.\\
   **Important:** As part of the configuration process, enter the name of the [secret](#preparing-the-repository) you created previously in the [**Image pull secret**](../configuring/#global-install-settings) field.\\
   **Note:** Ensure the [**Docker image registry**](../configuring/#global-install-settings) field value does not have a trailing slash, for example: `mycluster.icp:8500/ibmcom`
6. Click **Install**.
7. [Verify your installation](../post-installation/#verifying-your-installation) and consider other post-installation tasks.
