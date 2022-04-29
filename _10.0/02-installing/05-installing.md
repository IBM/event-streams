---
title: "Installing"
excerpt: "Installing IBM Event Streams."
categories: installing
slug: installing
toc: true
---

The following sections provide instructions about installing {{site.data.reuse.long_name}} on the {{site.data.reuse.openshift}}. The instructions are based on using the {{site.data.reuse.openshift_short}} web console and `oc` command line utility.

When deploying in an air-gapped environment, ensure you have access to this documentation set, and see the instructions in the offline installation README that is provided as part of the downloaded package.

{{site.data.reuse.short_name}} can also be installed as part of [{{site.data.reuse.cp4i}}](https://www.ibm.com/support/knowledgecenter/SSGT7J_20.2/install/install_event_streams.html){:target="_blank"}.

## Overview

{{site.data.reuse.short_name}} is an [operator-based](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} release and uses custom resources to define your {{site.data.reuse.short_name}} configurations. The {{site.data.reuse.short_name}} operator uses the custom resources to deploy and manage the entire lifecycle of your {{site.data.reuse.short_name}} instances. Custom resources are presented as YAML configuration documents that define instances of the `EventStreams` custom resource type.

Installing {{site.data.reuse.short_name}} has two phases:

1. Install the {{site.data.reuse.short_name}} operator: this will deploy the operator that will install and manage your {{site.data.reuse.short_name}} instances.
2. Install one or more instances of {{site.data.reuse.short_name}} by using the operator.

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites), including setting up your {{site.data.reuse.openshift_short}}.
- Ensure you have [planned for your installation](../planning), such as preparing for persistent storage, considering security options, and considering adding resilience through multiple availability zones.
- Obtain the connection details for your {{site.data.reuse.openshift_short}} cluster from your administrator.

## Create a project (namespace)

Create a namespace into which the {{site.data.reuse.short_name}} instance will be installed by creating a [project](https://docs.openshift.com/container-platform/4.4/applications/projects/working-with-projects.html){:target="_blank"}.
When you create a project, a namespace with the same name is also created.

Ensure you use a namespace that is dedicated to a single instance of {{site.data.reuse.short_name}}. This is required because {{site.data.reuse.short_name}} uses network security policies to restrict network connections between its internal components. A single namespace per instance also allows for finer control of user accesses.

**Important:** Do not use any of the default or system namespaces to install an instance of {{site.data.reuse.short_name}} (some examples of these are: `default`, `kube-system`, `kube-public`, and `openshift-operators`).

### Creating a project by using the web console

1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Home** dropdown and select **Projects** to open the **Projects** panel.
3. Click **Create Project**.
4. Enter a new project name in the **Name** field, and optionally, a display name in the **Display Name** field, and a description in the **Description** field.
5. Click **Create**.

### Creating a project by using the CLI

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to create a new project:

   `oc new-project <project_name> --description="<description>" --display-name="<display_name>"`

   where `description` and `display-name` are optional flags to set a description and custom descriptive name for your project.
3. Ensure you are using the project you created by selecting it as follows:

   `oc project <new-project-name>`


   The following message is displayed if successful:
   ```
   Now using project "<new-project-name>" on server "https://<OpenShift-host>:6443".
   ```


## Add the {{site.data.reuse.short_name}} operator to the catalog

Before you can install the {{site.data.reuse.short_name}} operator and use it to create instances of {{site.data.reuse.short_name}}, you must have the IBM Operator Catalog and the IBM Common Services Catalog available in your cluster.

If you have other IBM products installed in your cluster, then you already have the IBM Operator Catalog available, and you can continue to [installing](#install-the-event-streams-operator) the {{site.data.reuse.short_name}} operator. Ensure you also have the IBM Common Services Catalog available, as described in the following steps.

If you are installing {{site.data.reuse.short_name}} as the first IBM product in your cluster, complete the following steps.

To make the {{site.data.reuse.long_name}} operator and related {{site.data.reuse.cs}} dependencies available in the OpenShift OperatorHub catalog, create the following YAML files and apply them as  follows.

To add the IBM Operator Catalog:

1. Create a file for the IBM Operator Catalog source with the following content, and save as `IBMCatalogSource.yaml`:

   ```
   apiVersion: operators.coreos.com/v1alpha1
   kind: CatalogSource
   metadata:
      name: ibm-operator-catalog
      namespace: openshift-marketplace
   spec:
      displayName: "IBM Operator Catalog"
      publisher: IBM
      sourceType: grpc
      image: docker.io/ibmcom/ibm-operator-catalog
      updateStrategy:
        registryPoll:
          interval: 45m
   ```
   **Important:** If you are using {{site.data.reuse.openshift_short}} 4.3, do not include the last 3 lines in your file:

   ```
   updateStrategy:
     registryPoll:
       interval: 45m
    ```
2. {{site.data.reuse.openshift_cli_login}}
3. Apply the source by using the following command:

   `oc apply -f IBMCatalogSource.yaml`

The IBM Operator Catalog source is added to the OperatorHub catalog, making the {{site.data.reuse.short_name}} operator available to install.


To add the IBM Common Services Catalog:

1. Create a file for the IBM Common Services Catalog source with the following content, and save as `IBMCSCatalogSource.yaml`:

   ```
   apiVersion: operators.coreos.com/v1alpha1
   kind: CatalogSource
   metadata:
      name: opencloud-operators
      namespace: openshift-marketplace
   spec:
      displayName: "IBMCS Operators"
      publisher: IBM
      sourceType: grpc
      image: docker.io/ibmcom/ibm-common-service-catalog:latest
      updateStrategy:
        registryPoll:
          interval: 45m
   ```
   **Important:** If you are using {{site.data.reuse.openshift_short}} 4.3, do not include the last 3 lines in your file:

   ```
   updateStrategy:
     registryPoll:
       interval: 45m
    ```
2. {{site.data.reuse.openshift_cli_login}}
3. Apply the source by using the following command:

   `oc apply -f IBMCSCatalogSource.yaml`

The IBM Common Services Catalog source is added to the OperatorHub catalog, making the {{site.data.reuse.icpcs}} items available to install for {{site.data.reuse.short_name}}.

## OpenShift 4.4.8 to 4.4.12 only: manually install the {{site.data.reuse.cs}} operator

{{site.data.reuse.openshift_short}} version 4.4.8 introduced a regression where the default channels are not selected when a dependency is installed by the Operator Lifecycle Manager. This results in the wrong version of some operators, including {{site.data.reuse.icpcs}}, to be installed by default.

If you are installing {{site.data.reuse.short_name}} on {{site.data.reuse.openshift_short}} 4.4.8 to 4.4.12, manually install the {{site.data.reuse.cs}} operator on the `stable-v1` channel first, or upgrade the {{site.data.reuse.openshift_short}} to 4.4.13 before installing the {{site.data.reuse.short_name}} operator.

For other OpenShift versions, the {{site.data.reuse.short_name}} operator will automatically deploy the required {{site.data.reuse.icpcs}} if not present.

To install the {{site.data.reuse.cs}} operator on the `stable-v1` channel when using {{site.data.reuse.openshift_short}} 4.4.8 to 4.4.12:
1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Operators** dropdown and select **OperatorHub** to open the **OperatorHub** dashboard.
3. Select the project you want to deploy the operator in.
4. In the **All Items** search box enter `{{site.data.reuse.cs}}` to locate the operator title.
5. Click the **{{site.data.reuse.icpcs}}** tile to open the install side panel.
6. Click the **Install** button to open the **Create Operator Subscription** dashboard, and select the `stable-v1` channel.
7. Select the chosen [installation mode](#choosing-operator-installation-mode) that suits your requirements.
   If the installation mode is **A specific namespace on the cluster**, select the target namespace you created previously.
8. Click **Subscribe** to begin the installation.

## Install the {{site.data.reuse.short_name}} operator

### Choosing operator installation mode

Before installing the {{site.data.reuse.short_name}} operator, decide if you want the operator to:

- Manage instances of {{site.data.reuse.short_name}} in **any namespace**.

  To use this option, select `All namespaces on the cluster (default)` later. The operator will be deployed into the system namespace `openshift-operators`, and will be able to manage instances of {{site.data.reuse.short_name}} in any namespace.

- Only manage instances of {{site.data.reuse.short_name}} in a **single namespace**.

  To use this option, select `A specific namespace on the cluster` later. The operator will be deployed into the specified namespace, and will not be able to manage instances of {{site.data.reuse.short_name}} in any other namespace.

### Installing by using the web console

To install the operator by using the {{site.data.reuse.openshift_short}} web console, do the following:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Operators** dropdown and select **OperatorHub** to open the **OperatorHub** dashboard.
3. Select the project you want to deploy the {{site.data.reuse.short_name}} instance in.
4. In the **All Items** search box enter `IBM Event Streams` to locate the operator title.
5. Click the **IBM Event Streams** tile to open the install side panel.
6. Click the **Install** button to open the **Create Operator Subscription** dashboard.
7. Select the chosen [installation mode](#choosing-operator-installation-mode) that suits your requirements.
   If the installation mode is **A specific namespace on the cluster**, select the target namespace you created previously.
8. Click **Subscribe** to begin the installation.

The installation can take a few minutes to complete.

#### Checking the operator status

You can see the installed operator and check its status as follows:

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. Scroll down to the **ClusterServiceVersion Overview** section of the page.
5. Check the **Status** field. After the operator is successfully installed, this will change to `Succeeded`.

In addition to the status, information about key events that occur can be viewed under the **Conditions** section of the same page. After a successful installation, a condition with the following message is displayed: `install strategy completed with no errors`.

**Note:** If the operator is installed into a specific namespace, then it will only appear under the associated project. If the operator is installed for all namespaces, then it will appear under any selected project. If the operator is installed for all namespaces and you select **all projects** from the **Project** drop down, the operator will be shown multiple times in the resulting list, once for each project.

**Note:** If the required {{site.data.reuse.icpcs}} are not installed, they will be automatically deployed when the {{site.data.reuse.short_name}} operator is installed and the following additional operators will appear in the installed operator list:

- Operand Deployment Lifecycle Manager.
- IBM Common Service Operator.

## Install an {{site.data.reuse.short_name}} instance

Instances of {{site.data.reuse.short_name}} can be created after the {{site.data.reuse.short_name}} operator is installed. If the operator was installed into **a specific namespace**, then it can only be used to manage instances of {{site.data.reuse.short_name}} in that namespace. If the operator was installed for **all namespaces**, then it can be used to manage instances of {{site.data.reuse.short_name}} in any namespace, including those created after the operator was deployed.

When installing an instance of {{site.data.reuse.short_name}}, ensure you are using a namespace that an operator is managing.

### Creating an image pull secret

Before installing an {{site.data.reuse.short_name}} instance, create an image pull secret called `ibm-entitlement-key` in the namespace where you want to create an instance of {{site.data.reuse.short_name}}. The secret enables container images to be pulled from the registry.

1. Obtain an entitlement key from the [IBM Container software library](https://myibm.ibm.com/products-services/containerlibrary){:target="_blank"}.
2. Create the secret in the namespace that will be used to deploy an instance of {{site.data.reuse.short_name}} as follows.

   Name the secret `ibm-entitlement-key`, use `cp` as the username, your entitlement key as the password, and `cp.icr.io` as the docker server:

   `oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password="<your-entitlement-key>" --docker-server="cp.icr.io" -n <target-namespace>`


**Note:** If you do not create the required secret, pods will fail to start with `ImagePullBackOff` errors. In this case, ensure the secret is created and allow the pod to restart.

### Installing an instance by using the web console

To install an {{site.data.reuse.short_name}} instance through the {{site.data.reuse.openshift_short}} web console, do the following:

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}

   **Note:** If the operator is not shown, it is either not installed or not available for the selected namespace.

4. In the **Operator Details** dashboard, click the **{{site.data.reuse.short_name}}** tab.
5. Click the **Create EventStreams** button to open the **Create EventStreams** panel. You can use this panel to define an `EventStreams` custom resource.

From here you can install by using the [form view](#installing-by-using-the-form-view). For more advanced configurations or to install one of the samples, see [installing by using the YAML view](#installing-by-using-the-yaml-view).

#### Installing by using the form view

To configure an `EventStreams` custom resource, do the following:

1. Enter a name for the instance in the **Name** field.
2. Click the license accept toggle to set it to **True**.
   ![Accepting license toggle](../../../images/license_accept_form.png "Screen capture showing how to toggle the license accept field to true"){:height="100%" width="100%"}
3. Ensure that the correct value is selected for the **Product use** from the dropdown. Select **CloudPakForIntegrationNonProduction** for development and test deployments not intended for production use, and select **CloudPakForIntegrationProduction** for production deployments. See the [licensing](../planning/#licensing) section for more details about selecting the correct value.
4. You can optionally configure other components such as **Kafka**, **ZooKeeper**, **Schema Registry**, and **Security** to suit your [requirements](../configuring).
5. Scroll down and click the **Create** button at the bottom of the page to deploy the {{site.data.reuse.short_name}} instance.
6. Wait for the installation to complete.
7. You can now verify your installation and consider other [post-installation tasks](../post-installation/).

#### Installing by using the YAML view

Alternatively, you can configure the `EventStreams` custom resource by editing YAML documents. To do this, click the **Edit YAML** tab.

A number of sample configurations are provided on which you can base your deployment. These range from smaller deployments for non-production development or general experimentation to large scale clusters ready to handle a production workload. Alternatively, a pre-configured YAML file containing the custom resource sample can be dragged and dropped onto this screen to apply the configuration.

To view the samples, do the following:

1. Select the **Samples** tab to show the available sample configurations.
2. Click the **Try it** link under any of the samples to open the configuration in the **Create EventStreams** panel.

More information about these samples is available in the [planning](../planning/#sample-deployments) section. You can base your deployment on the sample that most closely reflects your requirements and apply [customizations](../configuring) on top as required.

When modifying the sample configuration, the updated document can be exported from the **Create EventStreams** panel by clicking the **Download** button and re-imported by dragging the resulting file back into the window.

**Important:** You must ensure that the `spec.license.accept` field in the custom resource YAML is set to `true` and that the correct value is selected for the `spec.license.use` field before deploying the {{site.data.reuse.short_name}} instance. Select **CloudPakForIntegrationNonProduction** for development and test deployments not intended for production use, and select **CloudPakForIntegrationProduction** for production deployments. See the [licensing](../planning/#licensing) section for more details about selecting the correct value.

![Accepting license](../../../images/license_accept.png "Screen capture showing how to set the license accept field to true"){:height="50%" width="50%"}

**Note:** If experimenting with {{site.data.reuse.short_name}} for the first time, the **Lightweight without security** sample is the smallest and simplest example that can be used to create an experimental deployment. For the smallest production setup, use the **Minimal production** sample configuration.

To deploy an {{site.data.reuse.short_name}} instance, use the following steps:

1. Complete any changes to the sample configuration in the **Create EventStreams** panel.
2. Click **Create** to begin the installation process.
3. Wait for the installation to complete.
4. You can now verify your installation and consider other [post-installation tasks](../post-installation/).

### Installing an instance by using the CLI

To install an instance of {{site.data.reuse.short_name}} from the command line, you must first prepare an `EventStreams` custom resource configuration in a YAML file.

A number of [sample configuration files](http://ibm.biz/es-cr-samples){:target="_blank"} have been provided to base your deployment on (download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples). The sample configurations range from smaller deployments for non-production development or general experimentation to large scale clusters ready to handle a production workload.

More information about these samples is available in the [planning](../planning/#sample-deployments) section. You can base your deployment on the sample that most closely reflects your requirements and apply [customizations](../configuring) on top as required.

**Important:** You must ensure that the `spec.license.accept` field in the configuration is set to `true` and that the correct value is selected for the `spec.license.use` field before deploying the {{site.data.reuse.short_name}} instance. Select **CloudPakForIntegrationNonProduction** for development and test deployments not intended for production use, and select **CloudPakForIntegrationProduction** for production deployments. See the [licensing](../planning/#licensing) section for more details about selecting the correct value.

![Accepting license](../../../images/license_accept.png "Screen capture showing how to set the license accept field to true"){:height="50%" width="50%"}

**Note:** If experimenting with {{site.data.reuse.short_name}} for the first time, the **Lightweight without security** sample is the smallest and simplest example that can be used to create an experimental deployment. For the smallest production setup, use the **Minimal production** sample configuration.

To deploy an {{site.data.reuse.short_name}} instance, run the following commands:

1. Set the project where your `EventStreams` custom resource will be deployed in:

   `oc project <project-name>`

2. Apply the configured `EventStreams` custom resource:

   `oc apply -f <custom-resource-file-path>`

   For example: `oc apply -f development.yaml`
3. Wait for the installation to complete.
4. You can now verify your installation and consider other [post-installation tasks](../post-installation/).
