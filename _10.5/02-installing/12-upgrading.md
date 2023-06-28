---
title: "Upgrading and migrating"
excerpt: "Upgrade your installation to the latest version."
categories: installing
slug: upgrading
layout: redirects
toc: true
---

Upgrade your {{site.data.reuse.long_name}} operator and operand instances as follows.

## Upgrade paths

The following upgrade paths are available:
- You can upgrade the {{site.data.reuse.short_name}} operator to version 2.5.3 directly from version 2.5.x, 2.4.x, 2.3.x, and 2.2.x.
- You can upgrade the {{site.data.reuse.short_name}} operand to version 10.5.0 directly from version 10.4.x, 10.3.x, 10.2.x, 10.1.x, and 10.0.x.
- If you have an earlier version than 10.0.0, you must first upgrade your {{site.data.reuse.short_name}} version [to 10.0.0](../../10.0/installing/upgrading/), before upgrading to 10.5.0.

## Prerequisites

- Ensure you have followed the [upgrade steps for {{site.data.reuse.cp4i}}](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2021.4?topic=upgrading){:target="_blank"} before upgrading {{site.data.reuse.short_name}}.
- The images for {{site.data.reuse.short_name}} release 10.5.0 are available in the IBM Cloud Container Registry. Ensure you redirect your catalog source to use `icr.io/cpopen` as described in [Implementing ImageContentSourcePolicy to redirect to the IBM Container Registry](https://www.ibm.com/docs/en/cloud-paks/1.0?topic=clusters-migrating-from-docker-container-registry#implementing-imagecontentsourcepolicy-to-redirect-to-the ibm-container-registry){:target="_blank"}.


- To upgrade successfully, your {{site.data.reuse.short_name}} instance must have more than one ZooKeeper node or have persistent storage enabled. If you upgrade an {{site.data.reuse.short_name}} instance with a single ZooKeeper node that has ephemeral storage, all messages and all topics will be lost and both ZooKeeper and Kafka pods will move to an error state. To avoid this issue, increase the number of ZooKeeper nodes before upgrading as follows:

```
apiVersion: eventstreams.ibm.com/v1beta1
kind: EventStreams
metadata:
  name: example-pre-upgrade
  namespace: myproject
spec:
  strimziOverrides:
    zookeeper:
      replicas: 3
```

## Upgrade process

The upgrade process requires the upgrade of the {{site.data.reuse.short_name}} operator, and then the upgrade of your {{site.data.reuse.short_name}} instances. Complete the steps in the following sections to upgrade your {{site.data.reuse.short_name}} installation.

### Upgrade the {{site.data.reuse.short_name}} operator

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Operators** in the navigation on the left, and click **Installed Operators**.\\
   ![Operators > Installed Operators]({{ 'images' | relative_url }}/rhocp_menu_installedoperators.png "Screen capture showing how to select Operators > Installed Operators from navigation menu"){:height="50%" width="50%"}
3. Locate the operator that manages your {{site.data.reuse.short_name}} instance in the namespace. It is called **{{site.data.reuse.long_name}}** in the **Name** column.
4. Click the **{{site.data.reuse.long_name}}** link in the row and then click the **Subscription** tab. This shows the **Subscription details** for the **{{site.data.reuse.short_name}}** operator.
5. Click the version number link in the **Update channel** section (for example, **v2.4**). The **Change Subscription update channel** dialog is displayed, showing the channels that are available to upgrade to.
6. Select **v2.5** and click the **Save** button on the **Change Subscription Update Channel** dialog.

All {{site.data.reuse.short_name}} pods that need to be updated as part of the upgrade will be gracefully rolled. Where required ZooKeeper pods will roll one at a time, followed by Kafka brokers rolling one at a time.

**Note:** The number of containers in each Kafka broker will reduce from 2 to 1 as the TLS-sidecar container will be removed from each broker during the upgrade process.

### Upgrade the {{site.data.reuse.short_name}} operand (instance)

1. Click **Installed Operators** from the navigation on the left to show the list of installed operators that includes the upgraded **{{site.data.reuse.long_name}}** operator.
2. Select the **{{site.data.reuse.long_name}}** operator from the list of **Installed Operators**.
3. Click the **{{site.data.reuse.short_name}}** tab. This lists the **{{site.data.reuse.short_name}}** operands.
4. Find your instance in the **Name** column and click the link for the instance.
5. Click the **YAML** tab. The **{{site.data.reuse.short_name}}** instance custom resource is shown.
6. In the YAML, change the version field to the required version, for example, 10.5.0.
7. Click the **Save** button.

All {{site.data.reuse.short_name}} pods will gracefully roll again.

### Verify the upgrade

1. Wait for all {{site.data.reuse.short_name}} pods to complete the upgrade process. This is indicated by the `Running` state.
2. {{site.data.reuse.openshift_cli_login}}
3. To retrieve a list of {{site.data.reuse.short_name}} instances, run the following command:\\
   `oc get eventstreams -n <namespace>`
4. For the instance of {{site.data.reuse.short_name}} that you upgraded, check that the status returned by the command in the previous step is `Ready`.

## Post-upgrade tasks

### Enable metrics for monitoring

To display metrics in the monitoring dashboards of the {{site.data.reuse.short_name}} UI, ensure you [enable](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2021.4?topic=administration-enabling-openshift-container-platform-monitoring){:target="_blank"} the {{site.data.reuse.openshift_short}} monitoring stack.

### Retrieve the new URL for the UI

When upgrading from an earlier version than 10.4.x, the previous URL for accessing the {{site.data.reuse.short_name}} UI is deprecated, and will redirect to the 10.5.0 URL after upgrading.

You can also retrieve the URL for your {{site.data.reuse.short_name}} UI by following the steps in [logging in](../../getting-started/logging-in/).

### Delete the `eventstreams-cluster-operator` operand request

When upgrading from an earlier version than 10.2.x, delete the previous `eventstreams-cluster-operator` operand request for the earlier operator version.

{{site.data.reuse.short_name}} uses operand request resources to declare the required {{site.data.reuse.icpfs}} components. In {{site.data.reuse.short_name}} version 10.2.0 and later, operand request resources are only created for individual instances of {{site.data.reuse.short_name}}. In versions 10.0.0 and 10.1.0, the operator also had an operand request created when installed. After upgrading to version 10.2.0 or later, you can delete the previous operand request for the earlier operator version as follows:

```
oc delete operandrequest -n <operator_namespace> eventstreams-cluster-operator
```

where `<operator_namespace>` is either the specific namespace where the operator was [deployed](../installing/#install-the-event-streams-operator) to manage instances of {{site.data.reuse.short_name}} in that namespace only, or it is `openshift-operators` if the operator was [deployed](../installing/#install-the-event-streams-operator) to manage instances of {{site.data.reuse.short_name}} in any namespace..

### Upgrade the Kafka broker protocol version

**Note:** Only applicable when upgrading from an earlier version than 10.4.x.

After successfully upgrading to {{site.data.reuse.short_name}} 10.5.0 by completing all previous steps and verifying the cluster’s behavior and performance, change the following values in order to upgrade the Kafka brokers to version `2.8`:

1. Change the `inter.broker.protocol.version` value in the EventStreams custom resource to `2.8`.
1. Wait for the Kafka pods to roll.
1. After the pods have rolled, change the `log.message.format.version` value in the EventStreams custom resource to `2.8`.
1. Wait for the pods to roll again.

### Upgrade to use the Apicurio Registry

The previous schema registry in {{site.data.reuse.short_name}} was deprecated in version 10.1.0 and is not an available option for schemas in {{site.data.reuse.short_name}} version 10.5.0 and later.

If you are upgrading to {{site.data.reuse.short_name}} version 10.5.0 from an earlier version and you are using the deprecated registry option previously used for schemas, you will need to move your schemas to use the Apicurio Registry and reconfigure any applications that use those schemas to connect to the new registry, as described in [migrating](../migrating-to-apicurio/).
