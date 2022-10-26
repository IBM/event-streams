---
title: "Upgrading and migrating"
excerpt: "Upgrade your installation to the latest version."
categories: installing
slug: upgrading
toc: true
---

Upgrade your {{site.data.reuse.long_name}} operator and operand instances as follows.

## Upgrade paths

You must first upgrade the {{site.data.reuse.short_name}} operator, and then upgrade your {{site.data.reuse.short_name}} instance (operand version).

### Upgrade paths for CD releases

The following upgrade paths are available for Continuous Delivery (CD) releases (2.x operators and 10.x operands and later, except for 2.2.x operators and 10.2.x operands):
- You can upgrade the {{site.data.reuse.short_name}} operator to the latest 3.0.5 version directly from versions 3.0.x, 2.5.x, and 2.4.x. If you have an earlier operator version than 2.4.0, you must first upgrade it to 2.4.0 before upgrading to 3.0.x.
- You can upgrade the {{site.data.reuse.short_name}} operand to the latest 11.0.4 version directly from versions 11.0.x, 10.5.x, and 10.4.x. If you have an earlier operand version than 10.4.0, you must first upgrade it [to 10.4.0](../../10.4/installing/upgrading/) before upgrading to 11.0.x.

### Upgrade paths for EUS releases

You can also upgrade to the latest {{site.data.reuse.short_name}} CD release from the {{site.data.reuse.short_name}} Extended Update Support (EUS) release (2.2.x operators and 10.2.x operands) as follows:

1. Upgrade your {{site.data.reuse.short_name}} [EUS release](../../10.2/installing/upgrading/) by upgrading to the latest EUS operator (2.2.x). The latest operator revision for the EUS release ensures you have the latest updates and fixes applied, including updates to enable upgrading to the latest CD release.
2. [Upgrade your {{site.data.reuse.icpfs}}](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.2?topic=upgrading-cloud-pak-foundational-services){:target="_blank"} from EUS version 3.6.x to the latest CD version.
3. After successfully upgrading to the latest CD version of foundational services, ensure you [clean up the monitoring resources](https://www.ibm.com/docs/en/cpfs?topic=issues-monitoring-resources-not-cleaned-up){:target="_blank"} to avoid errors.
4. Upgrade your {{site.data.reuse.short_name}} version to the latest CD release by following the instructions on this page starting with the [prerequisites](#prerequisites) (operator version 3.0.5 and operand version 11.0.4).

## Prerequisites

- Ensure you have followed the [upgrade steps for {{site.data.reuse.cp4i}}](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.2?topic=upgrading){:target="_blank"} before upgrading {{site.data.reuse.short_name}}.

   **Note:** If you upgrade your OpenShift version before upgrading your {{site.data.reuse.short_name}} operator version, the {{site.data.reuse.short_name}} operand might display a `Failed` status temporarily. This will be resolved when you upgrade your operator and then the operand version, the next steps in the upgrade process.

- The images for {{site.data.reuse.short_name}} release 11.0.x are available in the IBM Cloud Container Registry. Ensure you redirect your catalog source to use `icr.io/cpopen` as described in [Implementing ImageContentSourcePolicy to redirect to the IBM Container Registry](https://www.ibm.com/docs/en/cloud-paks/1.0?topic=clusters-migrating-from-docker-container-registry#implementing-imagecontentsourcepolicy-to-redirect-to-the ibm-container-registry){:target="_blank"}.


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


- If you have an {{site.data.reuse.short_name}} 11.0.3 or earlier installation, and you previously added your own Kafka or Zookeeper metrics rules, then ensure you record these elsewhere to be added to the `metrics-config` ConfigMap [after upgrading](#update-metrics-rules).


## Upgrading by using the UI

The upgrade process requires the upgrade of the {{site.data.reuse.short_name}} operator, and then the upgrade of your {{site.data.reuse.short_name}} instances. If you are using the OpenShift Container Platform web console, complete the steps in the following sections to upgrade your {{site.data.reuse.short_name}} installation.

### Upgrade the {{site.data.reuse.short_name}} operator

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Operators** in the navigation on the left, and click **Installed Operators**.\\
   ![Operators > Installed Operators](../../../images/rhocp_menu_installedoperators.png "Screen capture showing how to select Operators > Installed Operators from navigation menu"){:height="50%" width="50%"}
3. From the **Project** list, select the namespace (project) the instance is installed in.
4. Locate the operator that manages your {{site.data.reuse.short_name}} instance in the namespace. It is called **{{site.data.reuse.long_name}}** in the **Name** column. Click the **{{site.data.reuse.long_name}}** link in the row.
4. Click the **Subscription** tab to display the **Subscription details** for the {{site.data.reuse.short_name}} operator.
5. Click the version number link in the **Update channel** section (for example, **v2.5**). The **Change Subscription update channel** dialog is displayed, showing the channels that are available to upgrade to.
6. Select **v3.0** and click the **Save** button on the **Change Subscription Update Channel** dialog.

All {{site.data.reuse.short_name}} pods that need to be updated as part of the upgrade will be gracefully rolled. Where required, ZooKeeper pods will roll one at a time, followed by Kafka brokers rolling one at a time.

**Important:** The Entity operator might display a `CrashLoopBackOff` error. In addition, some {{site.data.reuse.short_name}} pods might display errors temporarily when the operator version has been updated. You can ignore these errors and continue with upgrading the {{site.data.reuse.short_name}} operand version, which will resolve these errors.

**Note:** The number of containers in each Kafka broker will reduce from 2 to 1 as the TLS-sidecar container will be removed from each broker during the upgrade process.

### Upgrade the {{site.data.reuse.short_name}} operand (instance)

1. Click **Installed Operators** from the navigation on the left to view the list of installed operators, including the upgraded **{{site.data.reuse.long_name}}** operator.
2. Select the **{{site.data.reuse.long_name}}** operator from the list of **Installed Operators**.
3. Click the **{{site.data.reuse.short_name}}** tab. This lists the **{{site.data.reuse.short_name}}** operands.
4. Find your instance in the **Name** column and click the link for the instance.
5. Click the **YAML** tab. The **{{site.data.reuse.short_name}}** instance custom resource is shown.
6. In the YAML, change the `spec.version` field to the required version, for example, 11.0.4.
7. Click the **Save** button.

All {{site.data.reuse.short_name}} pods will gracefully roll again.

Alternatively, you can also upgrade your {{site.data.reuse.short_name}} instance in the {{site.data.reuse.cp4i}} Platform UI as follows:
   1. Log in to the {{site.data.reuse.cp4i}} Platform UI.
   2. Click the **Navigation Menu** in the top left.
   3. Expand **Administration** and click **Integration instances**.
      If an update is available for a runtime, the ![Information icon](../../../images/icon_info.png) **Information icon** displays next to the runtime's current Version number.
   4. Click the ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options** in the row for the {{site.data.reuse.short_name}} instance, and then click **Change version**.
   5. Select **11.0.4** from the **Select a new channel or version** list.
   6. Click **Change version** to save your selections and start the upgrade.
      In the runtimes table, the **Status** column for the runtime displays the `Upgrading` message. The upgrade is complete when the **Status** is `Ready` and the **Version** displays the new version number.


## Upgrading by using the CLI

The upgrade process requires the upgrade of the {{site.data.reuse.short_name}} operator, and then the upgrade of your {{site.data.reuse.short_name}} instances. If you are using the OpenShift command-line interface (CLI), the oc command, complete the steps in the following sections to upgrade your {{site.data.reuse.short_name}} installation.

### Upgrade the {{site.data.reuse.short_name}} operator

1. {{site.data.reuse.openshift_cli_login}}
2. Ensure the required {{site.data.reuse.long_name}} Operator Upgrade Channel is available:

   `oc get packagemanifest ibm-eventstreams -o=jsonpath='{.status.channels[*].name}'`

2. Change the subscription to move to the required update channel, where `vX.Y` is the required update channel (for example, `v3.0`):

   `oc patch subscription -n <namespace> ibm-eventstreams --patch '{"spec":{"channel":"vX.Y"}}' --type=merge`

All {{site.data.reuse.short_name}} pods that need to be updated as part of the upgrade will be gracefully rolled. Where required, ZooKeeper pods will roll one at a time, followed by Kafka brokers rolling one at a time.

**Important:** The Entity operator might display a `CrashLoopBackOff` error. In addition, some {{site.data.reuse.short_name}} pods might display errors temporarily when the operator version has been updated. You can ignore these errors and continue with upgrading the {{site.data.reuse.short_name}} operand version, which will resolve these errors.

**Note:** The number of containers in each Kafka broker will reduce from 2 to 1 as the TLS-sidecar container will be removed from each broker during the upgrade process.

### Upgrade the {{site.data.reuse.short_name}} operand (instance)

Upgrade the {{site.data.reuse.short_name}} instance to move to the required version, where `X.Y.Z` is the required version, for example, 11.0.4.

  `oc patch eventstreams -n <namespace> <name-of-the-es-instance> --patch '{"spec":{"version":"X.Y.Z"}}' --type=merge`

All {{site.data.reuse.short_name}} pods will gracefully roll again.

## Verifying the upgrade

1. Wait for all {{site.data.reuse.short_name}} pods to complete the upgrade process. This is indicated by the `Running` state.
2. {{site.data.reuse.openshift_cli_login}}
3. To retrieve a list of {{site.data.reuse.short_name}} instances, run the following command:\\
   `oc get eventstreams -n <namespace>`
4. For the instance of {{site.data.reuse.short_name}} that you upgraded, check that the status returned by the following command is `Ready`.\\
   `oc get eventstreams -n <namespace> <name-of-the-es-instance> -o jsonpath="'{.status.phase}'"`


## Post-upgrade tasks

### Enable collection of producer metrics

In {{site.data.reuse.long_name}} version 11.0.0 and later, a Kafka Proxy handles gathering metrics from producing applications. The information is displayed in the [**Producers** dashboard](../../administering/topic-health/). The proxy is optional and is not enabled by default. To enable metrics gathering and have the information displayed in the dashboard, [enable the Kafka Proxy](../../installing/configuring/#enabling-collection-of-producer-metrics).

### Update metrics rules

If you previously added your own Kafka or Zookeeper metrics rules, then ensure you add these rules again to the `metrics-config` ConfigMap. The rules in the following ConfigMap are the default rules. Add your own custom rules to `data.kafka-metrics-config.yaml.rules:` or `data.zookeeper-metrics-config.yaml.rules:` after the default rules.

If you do not want to export metrics then delete all of the rules in the `metrics-config` ConfigMap.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: metrics-config
data:
  kafka-metrics-config.yaml: |
    lowercaseOutputName: true
    rules:
    - attrNameSnakeCase: false
      name: kafka_controller_$1_$2_$3
      pattern: kafka.controller<type=(\w+), name=(\w+)><>(Count|Value|Mean)
    - attrNameSnakeCase: false
      name: kafka_server_BrokerTopicMetrics_$1_$2
      pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(Count)
    - attrNameSnakeCase: false
      name: kafka_server_BrokerTopicMetrics_$1__alltopics_$2
      pattern: kafka.server<type=BrokerTopicMetrics, name=(BytesInPerSec|BytesOutPerSec)><>(OneMinuteRate)
    - attrNameSnakeCase: false
      name: kafka_server_ReplicaManager_$1_$2
      pattern: kafka.server<type=ReplicaManager, name=(\w+)><>(Value)
  zookeeper-metrics-config.yaml: |
    lowercaseOutputName: true
    rules: []
```

### Deprecation warnings for metrics

The `metrics` configuration option for the `EventStreams` custom resource has been deprecated. If you receive deprecation warnings about `spec.kafka.metrics:
{}` or `spec.zookeeper.metrics:{}` after upgrading, then remove the `metrics: {}` line from the `EventStreams` [custom resource](../../10.5/installing/configuring/#configuring-external-monitoring-through-prometheus).
### Enable metrics for monitoring

To display metrics in the monitoring dashboards of the {{site.data.reuse.short_name}} UI, ensure you [enable](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.2?topic=administering-enabling-openshift-container-platform-monitoring){:target="_blank"} the {{site.data.reuse.openshift_short}} monitoring stack.

### Upgrade to use the Apicurio Registry

The previous schema registry in {{site.data.reuse.short_name}} was deprecated in version 10.1.0 and is not an available option for schemas in {{site.data.reuse.short_name}} version 10.5.0 and later.

If you are upgrading to {{site.data.reuse.short_name}} version 11.0.x from an earlier version and you are using the deprecated registry option previously used for schemas, you will need to move your schemas to use the Apicurio Registry and reconfigure any applications that use those schemas to connect to the new registry, as described in [migrating](../migrating-to-apicurio/).
