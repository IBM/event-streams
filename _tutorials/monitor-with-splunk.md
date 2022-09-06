---
title: "Monitoring cluster health with Splunk"
description: "Monitor the health of your cluster by using Splunk to capture Kafka broker JMX metrics."
permalink: /tutorials/monitor-with-splunk/
toc: true
section: "Tutorials for IBM Event Streams"
cardType: "large"
---

You can configure {{site.data.reuse.short_name}} to allow JMX scrapers to export Kafka broker JMX metrics to external applications. This tutorial details how to export Kafka JMX metrics as graphite output to an external Splunk system using a TCP data input.

## Prequisites

- Ensure you have an {{site.data.reuse.short_name}} installation available. This tutorial is based on {{site.data.reuse.short_name}} version 11.0.0.
- When installing {{site.data.reuse.short_name}}, ensure you configure your JMXTrans deployment as described in  [Configuring secure JMX connections](../../security/secure-jmx-connections/){:target="_blank"}.
- Ensure you have a [Splunk](https://www.splunk.com/){:target="_blank"} Enterprise server installed or a Splunk Universal Forwarder that has network access to your {{site.data.resuse.icp}} cluster.
- Ensure that you have an index to receive the data and a TCP Data input configured on Splunk. Details can be found in the [Splunk documentation](https://docs.splunk.com/Documentation/SplunkCloud/latest/Data/Monitornetworkports){:target="_blank"}.

## JMXTrans

JMXTrans is a connector that reads JMX metrics and outputs a number of formats supporting a wide variety of logging, monitoring, and graphing applications. To deploy to your {{site.data.resuse.icp}} cluster, you must configure JMXTrans in your {{site.data.reuse.short_name}} custom resource.

## Solution overview

The tasks in this tutorial help achieve the following goals:

1. Set up Splunk so that it can access TCP ports for data.
2. Utilize the `Kafka.spec.JMXTrans` parameter to configure a JMXTrans deployment.

### Configure Splunk

**Tip:** You can configure Splunk with the [Splunk Operator for Kubernetes](https://splunk.github.io/splunk-operator/){:target="_blank"}.

You can add a new network input after Splunk has been installed in your namespace, as described in the [Splunk documentation](https://docs.splunk.com/Documentation/SplunkCloud/latest/Data/Monitornetworkports){:target="_blank"}.

In this tutorial we will be configuring the TCP Data input by using Splunk Web as follows:

1. In Splunk Web click on **Settings**.
2. Click **Data Inputs**.
3. Select **TCP** or **UDP**.
4. To add an input, select **New Local TCP** or **New Local UDP.**
5. Type a port number in the **Port** field. In this tutorial, we use port number `9999`.
6. If required, replace the default source value by entering a new source name in the **Source name override** field.
7. Decide on a Host value.
8. In the **index** field, provide the index where Splunk Enterprise will send data to for this input. Unless you have specified numerous indexes to handle various types of events, you can use the default value.
9. Examine the options.
10. Click the left angle bracket (<) to return to the wizard's first step if you want to edit any item. Otherwise, press **Submit**.

Your port is included in the list of TCP data inputs.

![Splunk TCP data inputs page](../../images/Splunk_tcp_data_inputs.png "Screen capture showing TCP port 9999 listed in the Splunk data inputs page.")

### Add a service for Splunk network source

Add a service that exposes the newly formed port after creating the network source.

The following is a sample service that uses a selector for a Splunk pod that the Splunk operator generated.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: <splunk-tcp-input-svc-name>
  namespace: es
spec:
  ports:
    - name: tcp-source
      protocol: TCP
      port: 9999
      targetPort: 9999
  selector:
    app.kubernetes.io/component: standalone
    app.kubernetes.io/instance: splunk-s1-standalone
    app.kubernetes.io/managed-by: splunk-operator
    app.kubernetes.io/name: standalone

```

### Configure JMX for {{site.data.reuse.short_name}}

To expose the JMX port within the cluster, set the `spec.strimziOverrides.kafka.jmxOptions` value to `{}` and enable JMXTrans.

For example:

```yaml
#...
spec:
  #...
  strimziOverrides:
    #...
    kafka:
      #...
      jmxOptions: {}
    #...
```

**Tip:** The JMX port can be password-protected to prevent unauthorized pods from accessing it. For more information, see [Configuring secure JMX connections](../../security/secure-jmx-connections/){:target="_blank"}.

The following example shows how to configure a JMXTrans deployment in the EventStreams custom resourse.

```yaml
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    jmxTrans:
      #...
      kafkaQueries:
        - targetMBean: "kafka.server:type=BrokerTopicMetrics,name=*"
          attributes: ["Count"]
          outputs: ["standardOut", "splunk"]
      outputDefinitions:
        - outputType: "com.googlecode.jmxtrans.model.output.StdOutWriter"
          name: "standardOut"
        - outputType: "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory"
          host: "<splunk-tcp-input-svc-name>.<namespace>.svc"
          port: 9999
          flushDelayInSeconds: 5
          name: "splunk"
```

Events start appearing in Splunk after we apply the `jmxTrans` option in the custom resource. The time it takes for events to appear in the Splunk index is determined by the scrape interval on JMXTrans and the size of the receive queue on Splunk.

You can increase or decrease the frequency of samples in JMXTrans and the size of the receive queue. To modify the receive queue on Splunk, create an inputs.conf file, and specify the queueSize and persistentQueueSize settings of the [tcp://<remote server>:<port>] stanza.

Splunk search will begin to show metrics. The following is an example of how JMXTrans metrics are displayed when metrics are successfully received.

![Splunk Search](../../images/Splunk_tcp_data_inputs_search.png "Screen capture showing JMXTrans metrics being displayed in Splunk.")

### Troubleshooting

- If metrics are not appearing in your external Splunk, run the following command to examine the logs for JMXTrans:

   `kubectl -n <target-namespace> get logs <jmxtrans-pod-name>`

- You can change the log level for JMXTrans by setting the required granularity value in `spec.strimziOverrides.jmxTrans.logLevel`. For example:


   ```yaml
   # ...
   spec:
     # ...
     strimziOverrides:
       # ...
       jmxTrans:
         #...
         logLevel: debug
   ```



- To check the logs from the Splunk pod, you can view the `splunkd.log` file as follows:

   `tail -f $SPLUNK_HOME/var/log/splunk/splunkd.log`

- If the Splunk Operator installation fails due to error **Bundle extract size limit**, install the Splunk Operator on {{site.data.reuse.openshift}} 4.9 or later.
