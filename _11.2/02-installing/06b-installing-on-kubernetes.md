---
title: "Installing on other Kubernetes platforms"
excerpt: "Find out how to install IBM Event Streams on other Kubernetes platforms."
categories: installing
slug: installing-on-kubernetes
toc: true
---

The following sections provide instructions about installing {{site.data.reuse.long_name}} on Kubernetes platforms that support the Red Hat Universal Base Images (UBI) containers.

## Overview

{{site.data.reuse.short_name}} is an [operator-based](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/){:target="_blank"} release and uses custom resources to define your {{site.data.reuse.short_name}} configurations. The {{site.data.reuse.short_name}} operator uses the custom resources to deploy and manage the entire lifecycle of your {{site.data.reuse.short_name}} instances. Custom resources are presented as YAML configuration documents that define instances of the `EventStreams` custom resource type.

When deploying in an air-gapped (also referred to as offline or disconnected) environment, follow the instructions in the [README](https://github.com/IBM/cloud-pak/tree/master/repo/case/ibm-eventstreams){:target="_blank"} file downloaded with the CASE package.

Installing {{site.data.reuse.short_name}} has two phases:

1. Use Helm to install the {{site.data.reuse.short_name}} operator: this will deploy the operator that will install and manage your {{site.data.reuse.short_name}} instances.
2. Install one or more instances of {{site.data.reuse.short_name}} by using the operator.

## Before you begin

- Ensure you have set up your environment [according to the prerequisites](../prerequisites).
- Ensure you have [planned for your installation](../planning), such as preparing for persistent storage, considering security options, and considering adding resilience through multiple availability zones.
- Obtain the connection details for your Kubernetes cluster from your administrator.

## Create a namespace

Create a namespace into which the {{site.data.reuse.short_name}} instance will be installed. For more information about namespaces, see the [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/){:target="_blank"}.

Ensure you use a namespace that is dedicated to a single instance of {{site.data.reuse.short_name}}. This is required because {{site.data.reuse.short_name}} uses network security policies to restrict network connections between its internal components. A single namespace per instance also allows for finer control of user accesses.

**Important:** Do not use any of the initial or system [namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#initial-namespaces){:target="_blank"} to install an instance of {{site.data.reuse.short_name}} (`default`, `kube-node-lease`, `kube-public`, and `kube-system`).


## Add the Helm repository

Before you can install the {{site.data.reuse.short_name}} operator and use it to create instances of {{site.data.reuse.short_name}}, add the IBM Helm repository to your local repository list. This will provide access to the {{site.data.reuse.short_name}} Helm chart package that will install the operator on your cluster.

To add the [IBM Helm repository](https://github.com/IBM/charts/tree/master/repo/ibm-helm){:target="_blank"} to the local repository list, run the following command:

`helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm`

## Install the {{site.data.reuse.short_name}} operator

Ensure you have considered the {{site.data.reuse.short_name}} operator [requirements](../prerequisites/#operator-requirements), including resource requirements and the required cluster-scoped permissions.

### Choosing operator installation mode

Before installing the {{site.data.reuse.short_name}} operator, decide if you want the operator to:

- Manage instances of {{site.data.reuse.short_name}} in **any namespace**.

  To use this option, set `watchAnyNamespace: true` when installing the operator. The operator will be deployed into the specified namespace, and will be able to manage instances of {{site.data.reuse.short_name}} in any namespace.

- Only manage instances of {{site.data.reuse.short_name}} in a **single namespace**.

  This is the default option: if `watchAnyNamespace` is not set, then it defaults `false`. The operator will be deployed into the specified namespace, and will only be able to manage instances of {{site.data.reuse.short_name}} in that namespace.

### Installing the operator

To install the operator, run the following command:

```
helm install \
   <release-name> ibm-helm/ibm-eventstreams-operator \
   -n <namespace> \
   --set watchAnyNamespace=<true/false>
```

Where:
- `<release-name>` is the name you provide to identify your operator.
- `<namespace>` is the name of the namespace where you want to install the operator.
- `watchAnyNamespace=<true/false>` determines whether the operator manages instances of {{site.data.reuse.short_name}} in any namespace or only a single namespace (default is `false` if not specified).

   Set to `true` for the operator to manage instances in any namespace, or do not specify if you want the operator to only manage instances in a single namespace.

For example, to install the operator on a cluster where it will manage all instances of {{site.data.reuse.short_name}}, run the command as follows:

`helm install eventstreams ibm-helm/ibm-eventstreams-operator -n "my-namespace" --set watchAnyNamespace=true`

For example, to install the operator that will manage {{site.data.reuse.short_name}} instances in only the `eventstreams` namespace, run the command as follows:

`helm install eventstreams ibm-helm/ibm-eventstreams-operator -n "my-eventstreams"`

**Note:** If you are installing any subsequent operators in the same cluster, ensure you run the `helm install` command with the `--set createGlobalResources=false` option (as these resources have already been installed).

#### Checking the operator status

To check the status of the installed operator, run the following command:

`kubectl get deploy eventstreams-cluster-operator`

A successful installation will return a result similar to the following with `1/1` in the `READY` column:

```
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
eventstreams-cluster-operator   1/1     1            1           7d4h
```

### Technology Preview feature: KRaft

Technology Preview features are available to evaluate potential upcoming features. Such features are intended for testing purposes only and not for production use. IBM does not support these features, but might help with any issues raised against them. IBM welcomes feedback on Technology Preview features to improve them. As the features are still under development, functions and interfaces can change, and it might not be possible to upgrade when updated versions become available.

IBM offers no guarantee that Technology Preview features will be part of upcoming releases and as such become fully supported.

{{site.data.reuse.short_name}} version 11.1.5 and later includes [Apache Kafka Raft (KRaft)](https://cwiki.apache.org/confluence/display/KAFKA/KIP-500%3A+Replace+ZooKeeper+with+a+Self-Managed+Metadata+Quorum){:target="_blank"} as a Technology Preview feature.
KRaft replaces ZooKeeper for managing metadata, moving the overall handling of metadata into Kafka itself.

When the `UseKRaft` feature gate is enabled, the Kafka cluster is deployed without ZooKeeper. The `spec.strimziOverrides.zookeeper` properties in the `EventStreams` custom resource will be ignored, but still need to be present. The `UseKRaft` feature gate provides an API that configures Kafka cluster nodes and their roles. The API is still in development and is expected to change before the KRaft mode is production-ready.

#### Limitations

The KRaft mode in {{site.data.reuse.short_name}} has the following limitations:
- Moving existing Kafka clusters deployed with ZooKeeper to use KRaft, or the other way around, is not supported.
- Upgrading your Apache Kafka or {{site.data.reuse.short_name}} operator version, or reverting either one to an earlier version is not supported. To do so, you delete the cluster, upgrade the operator, and deploy a new Kafka cluster.
- The Topic Operator is not supported. The `spec.entityOperator.topicOperator` property must be removed from the Kafka custom resource.
- SCRAM-SHA-512 authentication is not supported.
- JBOD storage is not supported. You can use `type: jbod` for storage, but the JBOD array can contain only one disk.
- All Kafka nodes have both the controller and the broker KRaft roles. Kafka clusters with separate controller and broker nodes are not supported.

#### Enabling KRaft

To enable KRaft on non-OpenShift Kubernetes platforms using a Helm Chart, you can change the configuration values supplied in the values.yaml by adding extra arguments to helm install:
```shell
helm install .... --set featureGates.useKRaft=true ...
```

## Install an {{site.data.reuse.short_name}} instance

Instances of {{site.data.reuse.short_name}} can be created after the {{site.data.reuse.short_name}} operator is installed. If the operator was installed to manage **a specific namespace**, then it can only be used to manage instances of {{site.data.reuse.short_name}} in that namespace. If the operator was installed to manage **all namespaces**, then it can be used to manage instances of {{site.data.reuse.short_name}} in any namespace, including those created after the operator was deployed.

When installing an instance of {{site.data.reuse.short_name}}, ensure you are using a namespace that an operator is managing.

### Creating an image pull secret

Before installing an {{site.data.reuse.short_name}} instance, create an image pull secret called `ibm-entitlement-key` in the namespace where you want to create an instance of {{site.data.reuse.short_name}}. The secret enables container images to be pulled from the registry.

1. Obtain an entitlement key from the [IBM Container software library](https://myibm.ibm.com/products-services/containerlibrary){:target="_blank"}.
2. Click **Entitlement keys** in the navigation on the left, and click **Add new key**, or if you have an existing active key available, click **Copy** to copy the entitlement key to the clipboard.
3. Create the secret in the namespace that will be used to deploy an instance of {{site.data.reuse.short_name}} as follows.

   Name the secret `ibm-entitlement-key`, use `cp` as the username, your entitlement key as the password, and `cp.icr.io` as the docker server:

   `kubectl create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password="<your-entitlement-key>" --docker-server="cp.icr.io" -n "<target-namespace>"`


**Note:** If you do not create the required secret, pods will fail to start with `ImagePullBackOff` errors. In this case, ensure the secret is created and allow the pod to restart.

### Installing an instance by using the CLI

To install an instance of {{site.data.reuse.short_name}} from the command line, you must first prepare an `EventStreams` custom resource configuration in a YAML file.

A number of sample configuration files are included in the Helm chart package to base your deployment on. The sample configurations range from smaller deployments for non-production development or general experimentation to large scale clusters ready to handle a production workload.

More information about these samples is available in the [planning](../planning/#sample-deployments) section. You can base your deployment on the sample that most closely reflects your requirements and apply [customizations](../configuring) on top as required.

**Important:** Ensure that the `spec.license.accept` field in the custom resource YAML is set to `true`, and that the [correct values are selected](../planning/#license-usage) for the `spec.license.license` and `spec.license.use` fields before deploying the {{site.data.reuse.short_name}} instance.

For `spec.license.license`, select one of the following license IDs based on the program that you purchased:
- **L-YBXJ-ADJNSM** for [IBM Cloud Pak for Integration 2023.2.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-YBXJ-ADJNSM){:target="_blank"}
- **L-PYRA-849GYQ** for [IBM Cloud Pak for Integration 2023.2.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-PYRA-849GYQ){:target="_blank"}
- **L-RJON-CJR2RX** for [IBM Cloud Pak for Integration 2022.4.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-CJR2RX){:target="_blank"}
- **L-RJON-CJR2TC** for [IBM Cloud Pak for Integration 2022.4.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-CJR2TC){:target="_blank"}
- **L-RJON-CD3JKX** for [IBM Cloud Pak for Integration 2022.2.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-CD3JKX){:target="_blank"}
- **L-RJON-CD3JJU** for [IBM Cloud Pak for Integration 2022.2.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-CD3JJU){:target="_blank"}
- **L-RJON-C7QG3S** for [IBM Cloud Pak for Integration 2021.4.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-C7QG3S){:target="_blank"}
- **L-RJON-C7QFZX** for [IBM Cloud Pak for Integration 2021.4.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-C7QFZX){:target="_blank"}
- **L-RJON-C5CSNH** for [IBM Cloud Pak for Integration 2021.3.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-C5CSNH){:target="_blank"}
- **L-RJON-C5CSM2** for [IBM Cloud Pak for Integration 2021.3.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-C5CSM2){:target="_blank"}
- **L-RJON-BZFQU2** for [IBM Cloud Pak for Integration 2021.2.1](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-BZFQU2){:target="_blank"}
- **L-RJON-BZFQSB** for [IBM Cloud Pak for Integration 2021.2.1 Reserved or limited](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?popup=Y&li_formnum=L-RJON-BZFQSB){:target="_blank"}

For `spec.license.use`, select one of the following values depending on the purpose of your deployment:
- **CloudPakForIntegrationNonProduction** for non-production deployments suitable for basic development and test activities.
- **CloudPakForIntegrationProduction** for production deployments.

**Note:** If experimenting with {{site.data.reuse.short_name}} for the first time, the **Lightweight without security** sample is the smallest and simplest example that can be used to create an experimental deployment. For the smallest production setup, use the **Minimal production** sample configuration.

To deploy an {{site.data.reuse.short_name}} instance, run the following commands:

1. Apply the configured `EventStreams` custom resource in the selected namespace:

   `kubectl apply -f <custom-resource-file-path> -n "<target-namespace>"`

   For example: `kubectl apply -f development.yaml -n "my-eventstreams"`

3. Wait for the installation to complete.
4. Verify your installation and consider other [post-installation tasks](../post-installation/).
