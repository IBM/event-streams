---
title: "Installing"
excerpt: "Installing IBM Event Streams."
categories: installing
slug: installing
toc: true
---

The following sections provide instructions about installing {{site.data.reuse.long_name}} on the {{site.data.reuse.openshift}}. The instructions are based on using the {{site.data.reuse.openshift_short}} web console and `oc` command-line utility.

When deploying in an air-gapped (also referred to as offline or disconnected) environment, ensure you have access to this documentation set, and see the [instructions in the {{site.data.reuse.cp4i}} documentation](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.4?topic=installing-adding-catalog-sources-mirroring-images){:target="_blank"}.

{{site.data.reuse.short_name}} can also be installed as part of [{{site.data.reuse.cp4i}}](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.4?topic=capabilities-event-streams-deployment){:target="_blank"}.


## Overview

{{site.data.reuse.short_name}} is an [operator-based](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} release and uses custom resources to define your {{site.data.reuse.short_name}} configurations. The {{site.data.reuse.short_name}} operator uses the custom resources to deploy and manage the entire lifecycle of your {{site.data.reuse.short_name}} instances. Custom resources are presented as YAML configuration documents that define instances of the `EventStreams` custom resource type.

Installing {{site.data.reuse.short_name}} has two phases:

1. Install the {{site.data.reuse.short_name}} operator: this will deploy the operator that will install and manage your {{site.data.reuse.short_name}} instances.
2. Install one or more instances of {{site.data.reuse.short_name}} by using the operator.

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites), including setting up your {{site.data.reuse.openshift_short}}.
- Ensure you have [installed](../prerequisites/#ibm-cloud-pak-foundational-services) a supported version of the {{site.data.reuse.icpfs}}.
- Ensure you have [planned for your installation](../planning), such as preparing for persistent storage, considering security options, and considering adding resilience through multiple availability zones.
- Obtain the connection details for your {{site.data.reuse.openshift_short}} cluster from your administrator.
- The {{site.data.reuse.short_name}} UI includes dashboards for monitoring [Kafka health](../../administering/cluster-health/#viewing-the-preconfigured-dashboard) and [topic health](../../administering/topic-health/). To provide metrics for these dashboards, ensure you enable the {{site.data.reuse.openshift_short}} monitoring stack as described in the {{site.data.reuse.cp4i}} [documentation](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.4?topic=administering-enabling-openshift-container-platform-monitoring){:target="_blank"}.
   In addition, to provide metrics about topic health, [enable the Kafka Proxy](../../installing/configuring/#enabling-collection-of-producer-metrics).

## Create a project (namespace)

Create a namespace into which the {{site.data.reuse.short_name}} instance will be installed by creating a [project](https://docs.openshift.com/container-platform/4.12/applications/projects/working-with-projects.html){:target="_blank"}.
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

Before you can install the {{site.data.reuse.short_name}} operator and use it to create instances of {{site.data.reuse.short_name}}, you must have the IBM Operator Catalog available in your cluster.

If you have other IBM products installed in your cluster, then you already have the IBM Operator Catalog available, and you can continue to [installing](#install-the-event-streams-operator) the {{site.data.reuse.short_name}} operator.

If you are installing {{site.data.reuse.short_name}} as the first IBM product in your cluster, complete the following steps.

To make the {{site.data.reuse.long_name}} operator and related {{site.data.reuse.fs}} dependencies available in the OpenShift OperatorHub catalog, create the following YAML files and apply them as  follows.

To add the IBM Operator Catalog:

1. Create a file for the IBM Operator Catalog source with the following content, and save as `IBMCatalogSource.yaml`:

   ```yaml
   apiVersion: operators.coreos.com/v1alpha1
   kind: CatalogSource
   metadata:
      name: ibm-operator-catalog
      namespace: openshift-marketplace
   spec:
      displayName: "IBM Operator Catalog"
      publisher: IBM
      sourceType: grpc
      image: icr.io/cpopen/ibm-operator-catalog
      updateStrategy:
        registryPoll:
          interval: 45m
   ```
2. {{site.data.reuse.openshift_cli_login}}
3. Apply the source by using the following command:

   `oc apply -f IBMCatalogSource.yaml`

The IBM Operator Catalog source is added to the OperatorHub catalog, making the {{site.data.reuse.short_name}} operator available to install.

<!---
To add the {{site.data.reuse.icpfs}} Catalog:

1. Create a file for the {{site.data.reuse.icpfs}} Catalog source with the following content, and save as `IBMCSCatalogSource.yaml`:

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
      image: icr.io/cpopen/ibm-common-service-catalog:latest
      updateStrategy:
        registryPoll:
          interval: 45m
   ```

2. {{site.data.reuse.openshift_cli_login}}
3. Apply the source by using the following command:

   `oc apply -f IBMCSCatalogSource.yaml`

The {{site.data.reuse.icpfs}} Catalog source is added to the OperatorHub catalog, making the {{site.data.reuse.icpfs}} items available to install for {{site.data.reuse.short_name}}.
--->


## Install the {{site.data.reuse.short_name}} operator

Ensure you have considered the {{site.data.reuse.short_name}} operator [requirements](../prerequisites/#operator-requirements), including resource requirements and the required cluster-scoped permissions.

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
8. Click **Install** to begin the installation.

The installation can take a few minutes to complete.

**Important:** Only install one {{site.data.reuse.short_name}} operator on a cluster.

#### Checking the operator status

You can see the installed operator and check its status as follows:

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. Scroll down to the **ClusterServiceVersion details** section of the page.
5. Check the **Status** field. After the operator is successfully installed, this will change to `Succeeded`.

In addition to the status, information about key events that occur can be viewed under the **Conditions** section of the same page. After a successful installation, a condition with the following message is displayed: `install strategy completed with no errors`.

**Note:** If the operator is installed into a specific namespace, then it will only appear under the associated project. If the operator is installed for all namespaces, then it will appear under any selected project. If the operator is installed for all namespaces and you select **all projects** from the **Project** drop down, the operator will be shown multiple times in the resulting list, once for each project.

When the {{site.data.reuse.short_name}} operator is installed, the following additional operators will appear in the installed operator list:
- Operand Deployment Lifecycle Manager.
- IBM Common Service Operator.

### Scaling the operator for high availability

High availability (HA) is the elimination of single points of failure in an environment. In addition to setting up your [Kafka brokers](../planning/#kafka-high-availability) for high availability, you can also set the number of the {{site.data.reuse.short_name}} operator replicas to enable more resilience.

By increasing the number of replicas to a value greater than 1, you can ensure that the {{site.data.reuse.short_name}} operator continues to function in a wider range of outage scenarios. To ensure uptime in failure situations, the management of your {{site.data.reuse.short_name}} is delegated to the other available operator pods.

To increase the number replicas, edit the replicas in the `ClusterServiceVersion` object  manually or by running the following command:

```shell
oc patch csv -n <NAMESPACE> ibm-eventstreams.v<CSV_VERSION> -p '[{"op":"replace","path":"/spec/install/spec/deployments/0/spec/replicas","value":3}]' --type json
```

### Technology Preview feature: KRaft

Technology Preview features are available to evaluate potential upcoming features. Such features are intended for testing purposes only and not for production use. IBM does not support these features, but might help with any issues raised against them. IBM welcomes feedback on Technology Preview features to improve them. As the features are still under development, functions and interfaces can change, and it might not be possible to upgrade when updated versions become available.

IBM offers no guarantee that Technology Preview features will be part of upcoming releases and as such become fully supported.

![Event Streams 11.1.5 icon]({{ 'images' | relative_url }}/11.1.5.svg "In Event Streams 11.1.5"){{site.data.reuse.short_name}} version 11.1.5 includes [Apache Kafka Raft (KRaft)](https://cwiki.apache.org/confluence/display/KAFKA/KIP-500%3A+Replace+ZooKeeper+with+a+Self-Managed+Metadata+Quorum){:target="_blank"} as a Technology Preview feature.
KRaft replaces ZooKeeper for managing metadata, moving the overall handling of metadata into Kafka itself.

When the `UseKRaft` feature gate is enabled, the Kafka cluster is deployed without ZooKeeper. The `spec.strimziOverrides.zookeeper` properties in the `EventStreams` custom resource will be ignored, but still need to be present. The `UseKRaft` feature gate provides an API that configures Kafka cluster nodes and their roles. The API is still in development and is expected to change before the KRaft mode is production-ready.

#### Limitations

The KRaft mode in {{site.data.reuse.short_name}} has the following limitations:
- Moving existing Kafka clusters deployed with ZooKeeper to use KRaft, or the other way around, is not supported.
- Upgrading your Apache Kafka or {{site.data.reuse.short_name}} operator version, or reverting either one to an earlier version is not supported. To do so, you delete the cluster, upgrade the operator, and deploy a new Kafka cluster.
- The Topic Operator is not supported. The `spec.entityOperator.topicOperator` property must be removed from the Kafka custom resource.
- SCRAM-SHA-512 authentication is not supported. If required, use TLS authentication for secure communication.
- You can only access the {{site.data.reuse.short_name}} UI by using {{site.data.reuse.icpfs}} Identity and Access Management (IAM).
- JBOD storage is not supported. You can use `type: jbod` for storage, but the JBOD array can contain only one disk.
- All Kafka nodes have both the controller and the broker KRaft roles. Kafka clusters with separate controller and broker nodes are not supported.

#### Enabling KRaft

To enable KRaft, ensure you enable both the `UseKRaft` and `StrimziPodSet` feature gates. After the {{site.data.reuse.short_name}} operator is installed and created, edit your `ClusterServiceVersion` object on the {{site.data.reuse.openshift_short}} by running the following command:

**Note:** This command requires the [`yq` YAML](https://github.com/mikefarah/yq){:target="_blank"} parsing and editing tool.

```shell
oc get csv -n <namespace> ibm-eventstreams.v<operator_version> -oyaml | yq e "(.spec.install.spec.deployments[0].spec.template.spec.containers[0].env[] | select(.name==\"STRIMZI_FEATURE_GATES\")) .value=\"+UseStrimziPodSets,+UseKRaft\"" | oc apply -f
```
Alternatively, you can edit the `ClusterServiceVersion` in the {{site.data.reuse.openshift_short}} web console by locating the `STRIMZI_FEATURE_GATES` environmental variable and editing it to have the `value` of `+UseStrimziPodSets,+UseKRaft` as follows:
```yaml
                      - name: STRIMZI_FEATURE_GATES
                        value: '+UseStrimziPodSets,+UseKRaft'
```
**Important:** An {{site.data.reuse.short_name}} instance in KRaft mode must use the `RunAsKRaftAuthorizer` custom authorizer class. When configuring your `EventStreams` custom resource, set `authorizerClass` as follows:
```yaml
         kafka:
            replicas: 3
            authorization:
               type: custom
               authorizerClass: com.ibm.eventstreams.runas.authorizer.RunAsKRaftAuthorizer
               supportsAdminApi: true
```

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
   ![Accepting license toggle]({{ 'images' | relative_url }}/license_accept_form.png "Screen capture showing how to toggle the license accept field to true"){:height="100%" width="100%"}
3. Ensure that the correct value is selected for the **Product use** from the dropdown. Select **CloudPakForIntegrationNonProduction** for development and test deployments not intended for production use, and select **CloudPakForIntegrationProduction** for production deployments. See the [licensing](../planning/#licensing) section for more details about selecting the correct value.
4. You can optionally configure other components such as **Kafka**, **ZooKeeper**, and **Security** to suit your [requirements](../configuring).
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

![Accepting license]({{ 'images' | relative_url }}/license_accept_10.2.png "Screen capture showing how to set the license accept field to true"){:height="50%" width="50%"}

**Note:** If experimenting with {{site.data.reuse.short_name}} for the first time, the **Lightweight without security** sample is the smallest and simplest example that can be used to create an experimental deployment. For the smallest production setup, use the **Minimal production** sample configuration.

To deploy an {{site.data.reuse.short_name}} instance, use the following steps:

1. Complete any changes to the sample configuration in the **Create EventStreams** panel.
2. Click **Create** to begin the installation process.
3. Wait for the installation to complete.
4. You can now verify your installation and consider other [post-installation tasks](../post-installation/).

### Installing an instance by using the CLI

To install an instance of {{site.data.reuse.short_name}} from the command-line, you must first prepare an `EventStreams` custom resource configuration in a YAML file.

A number of [sample configuration files](http://ibm.biz/es-cr-samples){:target="_blank"} have been provided to base your deployment on (download and extract the resources for your {{site.data.reuse.short_name}} version, then go to `/cr-examples/eventstreams` to access the samples). The sample configurations range from smaller deployments for non-production development or general experimentation to large scale clusters ready to handle a production workload.

More information about these samples is available in the [planning](../planning/#sample-deployments) section. You can base your deployment on the sample that most closely reflects your requirements and apply [customizations](../configuring) on top as required.

**Important:** You must ensure that the `spec.license.accept` field in the configuration is set to `true` and that the correct value is selected for the `spec.license.use` field before deploying the {{site.data.reuse.short_name}} instance. Select **CloudPakForIntegrationNonProduction** for development and test deployments not intended for production use, and select **CloudPakForIntegrationProduction** for production deployments. See the [licensing](../planning/#licensing) section for more details about selecting the correct value.

![Accepting license]({{ 'images' | relative_url }}/license_accept_10.2.png "Screen capture showing how to set the license accept field to true"){:height="50%" width="50%"}

**Note:** If experimenting with {{site.data.reuse.short_name}} for the first time, the **Lightweight without security** sample is the smallest and simplest example that can be used to create an experimental deployment. For the smallest production setup, use the **Minimal production** sample configuration.

To deploy an {{site.data.reuse.short_name}} instance, run the following commands:

1. Set the project where your `EventStreams` custom resource will be deployed in:

   `oc project <project-name>`

2. Apply the configured `EventStreams` custom resource:

   `oc apply -f <custom-resource-file-path>`

   For example: `oc apply -f development.yaml`
3. Wait for the installation to complete.
4. You can now verify your installation and consider other [post-installation tasks](../post-installation/).
