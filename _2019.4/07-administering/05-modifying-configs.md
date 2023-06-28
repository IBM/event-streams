---
title: "Modifying Kafka broker configurations"
excerpt: "Modify your Kafka broker configuration settings dynamically using a ConfigMap."
categories: administering
slug: modifying-configs
layout: redirects
toc: true
---

You can use the {{site.data.reuse.long_name}} CLI to dynamically modify brokers and cluster-wide configuration settings for your {{site.data.reuse.long_name}} instance.

You can also use the {{site.data.reuse.long_name}} CLI together with a ConfigMap to modify static (read-only) configuration settings.

## Configuration options

For a list of all configuration settings you can specify for Kafka brokers, see [the Kafka documentation](http://kafka.apache.org/documentation.html#brokerconfigs){:target="_blank"}.

Some of the broker configuration settings can be updated without restarting the broker, while others require a restart:
* `read-only`: Requires a broker restart for the update to take effect.
* `per-broker`: Can be updated dynamically for each broker without a broker restart.
* `cluster-wide`: Can be updated dynamically as a cluster-wide default, or as a per-broker value for testing purposes.

See the [Dynamic Update Mode](http://kafka.apache.org/documentation.html#brokerconfigs){:target="_blank"} column in the Kafka documentation for the update mode of each broker configuration.

**Note:** You cannot modify the following properties.
* `broker.id`
* `listeners`
* `zookeeper.connect`
* `advertised.listeners`
* `inter.broker.listener.name`
* `listener.security.protocol.map`
* `authorizer.class.name`
* `principal.builder.class`
* `sasl.enabled.mechanisms`
* `log.dirs`
* `inter.broker.protocol.version`
* `log.message.format.version`

## Modifying broker and cluster settings

You can modify per-broker and cluster-wide configuration settings dynamically (without a broker restart) by using the {{site.data.reuse.long_name}} CLI:
1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to start the {{site.data.reuse.long_name}} CLI:\\
    `cloudctl es init`
3. To modify a per-broker configuration setting:\\
    `cloudctl es broker-config --broker <broker_id> --config <name>=<value>`
4. To modify a cluster-wide configuration setting:\\
    `cloudctl es cluster-config --config <name>=<value>`

You can also update your read-only configuration settings that require a broker restart by using the {{site.data.reuse.long_name}} CLI.

**Note:** Read-only settings require a ConfigMap to be set. If you did not create and specify a ConfigMap during the installation process, you can [create a ConfigMap](../../installing/planning/#configmap-for-kafka-static-configuration) later with the required Kafka configuration settings or create a blank one to use later.

Use the following command to make the ConfigMap available to your {{site.data.reuse.long_name}} instance if you did not create a ConfigMap during installation:

`helm upgrade --reuse-values --set kafka.configMapName=<configmap_name> <release_name> <charts.tgz>`

{{site.data.reuse.helm_charts_note}}

You can use the {{site.data.reuse.long_name}} CLI to modify read-only configuration settings as follows:

`cloudctl es cluster-config --config <name>=<value> --static-config-all-brokers`
