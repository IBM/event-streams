---
title: "Modifying installation settings"
excerpt: "Modify your existing Event Streams installation."
categories: administering
slug: modifying-installation
toc: true
---

You can modify the configuration settings for your existing {{site.data.reuse.short_name}} installation by using the {{site.data.reuse.openshift_short}} web console or the `oc` command line tool. The configuration changes are applied by updating the `EventStreams` custom resource
You can modify existing values and introduce new properties as outlined under [configuration settings](../../installing/configuring).
**Note:** Some settings might cause affected components of your {{site.data.reuse.short_name}} instance to restart.

For examples on changes you might want to make, see [scaling your {{site.data.reuse.short_name}} instance](../scaling/).

## Using the {{site.data.reuse.openshift_short}} web console

To modify configuration settings by using the {{site.data.reuse.openshift_short}} web console:
1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. {{site.data.reuse.task_openshift_select_instance}}
5. Click the **YAML** tab to edit the custom resource.
6. Make the required changes on the page, or you can click **Download** and make the required changes in a text editor.
   If you clicked **Download** you will need to drag and drop the modified custom resource file onto the page so that it updates in the web console.
7. Click the **Save** button to apply your changes.


## Using the {{site.data.reuse.openshift_short}} CLI

To modify configuration settings by using the {{site.data.reuse.openshift_short}} CLI:
1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to edit your `EventStreams` custom resource in your default editor:
   `oc edit eventstreams <instance_name>`
3. Make the required changes in your editor.
4. Save and quit the editor to apply your changes.


## Modifying Kafka broker configuration settings

Kafka supports a number of [key/value pair settings](http://kafka.apache.org/28/documentation/#brokerconfigs){:target="_blank"} for broker configuration, typically provided in a properties file.

In {{site.data.reuse.short_name}}, these settings are defined in an `EventStreams` custom resource under the `spec.strimziOverrides.kafka.config` property.

For example, to set the number of I/O threads to `24` you can add the `spec.strimziOverrides.kafka.config["num.io.threads"]` property:

```
apiVersion: eventstreams.ibm.com/v1beta1
kind: EventStreams
metadata:
  name: example-broker-config
  namespace: myproject
spec:
  # ...
  strimziOverrides:
    kafka:
      # ...
      config:
         # ...
         num.io.threads: 24
```

You can specify all the broker configuration options supported by Kafka except those managed directly by {{site.data.reuse.short_name}}. For further information, see the list of [supported configuration options](https://strimzi.io/docs/operators/0.22.0/using.html#type-KafkaClusterSpec-reference){:target="_blank"}.
