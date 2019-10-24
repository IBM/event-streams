---
title: "Installing on IBM Cloud Private"
excerpt: "Installing IBM Event Streams on IBM Cloud Private."
categories: installing
slug: installing
toc: true
---

{{site.data.reuse.long_name}} is the paid-for version intended for enterprise use, and includes full IBM support and additional features such as geo-replication.

You can also install a basic deployment of {{site.data.reuse.short_name}} {{site.data.reuse.ce_short}} to [try it out](../trying-out).

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites), including your {{site.data.reuse.icp}} environment.
- Ensure you have [planned for your installation](../planning), such as planning for persistent volumes if required, and creating a ConfigMap for Kafka static configuration.
- Gather the following information from your administrator:\\
   - The master host and port for your {{site.data.reuse.icp}} cluster. These values are set during the installation of {{site.data.reuse.icp}}. The default port is 8443.
      Make a note of these values, and enter them in the steps that have `https://<Cluster Master Host>:<Cluster Master API Port>`
   - The SSH password if you are connecting remotely to the master host of your {{site.data.reuse.icp}} cluster.
- Ensure your proxy address uses lowercase characters. This is a setting that often needs to be checked when installing {{site.data.reuse.short_name}} on an {{site.data.reuse.icp}} cluster [deployed on Amazon Web Services (AWS)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/aws/overview.html){:target="_blank"}. If the address is in uppercase, edit the `ibmcloud-cluster-info` ConfigMap in the `kube-public` namespace, and change the uppercase characters to lowercase for the `proxy_address` parameter:\\
   `kubectl edit configmap -n ibmcloud-cluster-info -n kube-public`
- Ensure you have the {{site.data.reuse.icp}} monitoring service installed. Usually monitoring is installed by default. However, some deployment methods might not install it. For example, monitoring might not be part of the default deployment when installing {{site.data.reuse.icp}} on Azure [by using Terraform](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/azure_overview.html){:target="_blank"}. Without this service, parts of the {{site.data.reuse.short_name}} UI [do not work](../../troubleshooting/problem-with-piping/). You can install the monitoring service from the [Catalog or CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_metrics/monitoring_service.html#install_monitsrv){:target="_blank"} for existing  deployments.


## Preparing the platform

Prepare your platform for installing {{site.data.reuse.short_name}} as follows.

### Create a namespace

You must use a namespace that is dedicated to your {{site.data.reuse.short_name}} deployment. This is required because {{site.data.reuse.short_name}} uses network security policies to restrict network connections between its internal components.

If you plan to have multiple {{site.data.reuse.short_name}} instances, create namespaces to organize your {{site.data.reuse.long_name}} deployments into, and control user access to them.

To create a namespace, you must have the Cluster Administrator role.

1. {{site.data.reuse.icp_ui_login321}}\\
   Ensure you log in as a user that has the Cluster Administrator role.
2. From the navigation menu, click **Manage > Namespaces**.
3. Click **Create Namespace**.
3. Enter a name for your namespace.
4. Ensure you have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.
5. Click **Create**.

See the {{site.data.reuse.icp}} documentation for more information about [creating namespaces](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/user_management/create_project.html){:target="_blank"}.

### Download the archive

Download the {{site.data.reuse.long_name}} installation image file from the IBM Passport Advantage site and make it available in your catalog.

1. Go to [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/pao_customer.html){:target="_blank"}, and search for "{{site.data.reuse.long_name}}". Download the images related to the part numbers for your platform.
2. Ensure you [configure your Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_images/configuring_docker_cli.html){:target="_blank"} to access your cluster.
3. Log in to your cluster from the {{site.data.reuse.icp}} CLI and log in to the Docker private image registry:
   ```
   cloudctl login -a https://<cluster_CA_domain>:8443
   docker login <cluster_CA_domain>:8500
   ```
   **Note:** The default value for the `cluster_CA_domain` parameter is `mycluster.icp`. If necessary add an entry to your system's host file to allow it to be resolved. For more information, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/installing/install_entitled_workloads.html){:target="_blank"}.
4. Make the {{site.data.reuse.short_name}} Helm chart available in the catalog by using the compressed image you downloaded from IBM Passport Advantage.\\
   `cloudctl catalog load-archive --archive <PPA-image-name.tar.gz>`

   When the image installation completes successfully, the catalog is updated with the {{site.data.reuse.long_name}} local chart, and the internal Docker repository is populated with the Docker images used by {{site.data.reuse.long_name}}.

## Preparing the repository

Prepare your repository by creating an image policy.

**Note:** You only need to follow these steps if the `image-security-enforcement` [service](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_images/image_security.html){:target="_blank"} is enabled. If the service is not enabled, you can ignore these steps.

The following steps require you to run `kubectl` commands. To run the commands, you must be logged in to your {{site.data.reuse.icp}} cluster as an administrator.

{{site.data.reuse.icp_cli_login321}} The default port is 8443.


Create an image policy for the internal Docker repository. The policy enables images to be retrieved during installation.

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

For more information about container image security, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_images/image_security.html){:target="_blank"}.

## Installing the {{site.data.reuse.short_name}} chart

Install the {{site.data.reuse.short_name}} chart as follows.

1. {{site.data.reuse.icp_ui_login321}}\\
   Ensure you log in as a user that has the Team Administrator or Cluster Administrator role.
2. Click **Catalog** in the top navigation menu.
2. Search for `ibm-eventstreams-prod` and select it from the result. The {{site.data.reuse.long_name}} README is displayed.
3. Click **Configure**.\\
   **Note:** The README includes information about how to install {{site.data.reuse.long_name}} by using the CLI. To use the CLI, follow the instructions in the README instead of clicking **Configure**.
4. {{site.data.reuse.enter_install_details}}
5. Expand the **All parameters** section to configure the settings for your installation as described in [configuring](../configuring). Configuration options to consider include setting up persistent storage, external access, and preparing for geo-replication.
6. Click **Install**.
7. [Verify your installation](../post-installation/#verifying-your-installation) and consider other post-installation tasks.
