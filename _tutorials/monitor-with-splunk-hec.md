---
title: "Monitoring cluster health with a Splunk HTTP Event Collector"
description: "Monitor the health of your cluster by using Splunk to capture Kafka broker JMX metrics."
permalink: /tutorials/monitor-with-splunk-hec/
toc: true
section: "Tutorials for IBM Event Streams"
cardType: "large"
---

You can configure {{site.data.reuse.short_name}} to allow JMX scrapers to export Kafka broker JMX metrics to external applications. This tutorial details how to export Kafka JMX metrics as graphite output, and then use [Logstash](https://www.elastic.co/products/logstash){:target="_blank"} to write the metrics to an external Splunk system as an HTTP Event Collector.

## Prerequisites

- Ensure you have an {{site.data.reuse.short_name}} installation available. This tutorial is based on {{site.data.reuse.short_name}} version 11.0.0.
- When installing {{site.data.reuse.short_name}}, ensure you configure your JMXTrans deployment as described in  [Configuring secure JMX connections](../../security/secure-jmx-connections/){:target="_blank"}.
- Ensure you have a [Splunk](https://www.splunk.com/){:target="_blank"} Enterprise server installed or a Splunk Universal Forwarder that has network access to your {{site.data.resuse.icp}} cluster.
- Ensure that you have an index to receive the data and an HTTP Event Collector configured on Splunk. Details can be found in the [Splunk documentation](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector){:target="_blank"}
- Ensure you have [configured access to the Docker registry](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_images/using_docker_cli.html){:target="_blank"} from the machine you will be using to deploy Logstash.

## JMXTrans

JMXTrans is a connector that reads JMX metrics and outputs a number of formats supporting a wide variety of logging, monitoring, and graphing applications. To deploy to your {{site.data.reuse.openshift}} cluster, you must configure JMXTrans in you {{site.data.reuse.short_name}} CR.

**Note:** JMXTrans is not supported in {{site.data.reuse.short_name}} versions 11.2.0 and later. 

## Solution overview

The tasks in this tutorial help achieve the following:

1. Set up splunk with HTTP Event Collector.
2. Logstash packaged into a Docker image to load configuration values and connection information.
3. Docker image pushed to the {{site.data.reuse.openshift}} cluster Docker registry into the namespace where Logstash will be deployed.
4. Utilize the `Kafka.spec.JMXTrans` parameter to configure a JMXTrans deployment.

### Configure Splunk

**Tip:** You can configure Splunk with the [Splunk Operator for Kubernetes](https://splunk.github.io/splunk-operator/){:target="_blank"}. This tutorial is based on the Splunk operator version `2.2.0`.

With the HTTP Event Collector (HEC), you can send data and application events to a Splunk deployment over the HTTP and Secure HTTP (HTTPS) protocols. HEC uses a token-based authentication model. For more information about setting up the HTTP Event Collector, see the [Splunk documentation](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector){:target="_blank"}.

In this tutorial we will be configuring the HTTP Event Collector by using Splunk Web as follows:

1. In the Splunk Web **click Settings** > **Add Data**.
1. Click **Monitor**.
1. Click **HTTP Event Collector**.
1. In the **Name** field, enter a name for the token, we'll add the name `splunk-hec` for this demo.
1. Click **Next**.
1. Click **Review**.
1. Confirm that all settings for the endpoint are what you want.
1. If all settings are what you want, click **Submit**. Otherwise, click **<** to make changes.
1. Copy the token value that Splunk Web displays and you can then use the token to send data to HEC.

Your name for the token is included in the list of data input names for the HTTP Event Collector.

![Splunk hec data inputs page](../../images/Splunk_hec_data_inputs.png "Screen capture showing the name splunk-hec listed in the Splunk data inputs page.")

### Configure and deploy Logstash

#### Example Dockerfile.logstash

Create a Dockerfile called `Dockerfile.logstash` as follows.

```conf
FROM docker.elastic.co/logstash/logstash:<required-logstash-version>
RUN /usr/share/logstash/bin/logstash-plugin install logstash-input-graphite
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
COPY pipeline/ /usr/share/logstash/pipeline/
COPY config/ /usr/share/logstash/config/
```

#### Example logstash.yml

Create a Logstash settings file called `logstash.yml` as follows.

```yaml
path.config: /usr/share/logstash/pipeline/
```

#### Example logstash.conf

Create a Logstash configuration file called `logstash.conf` as follows.

```conf
input {
    graphite {
        host => "localhost"
        port => 9999
        mode => "server"
    }
}
output {
    http {
        http_method => "post"
        url => "https://<splunk-host-name-or-ip-address>:<splunk-http-event-collector-port>/services/collector/event"
        headers => ["Authorization", "Splunk <splunk-http-event-collector-token>"]
        mapping => {"event" => "%{message}"}
        ssl_verification_mode => "none" # To skip ssl verification
    }
}
```

#### Building the Docker image

Build the Docker images as follows.

1. Ensure that `Dockerfile.jmxtrans`, `Dockerfile.logstash` and `run.sh` are in the same directory. Edit `Dockerfile.logstash` and replace `<required-logstash-version>` with the Logstash version you would like to use as a basis.
2. Ensure that `logstash.yml` is in a subdirectory called `config/` of the directory in step 1.
3. Ensure that `logstash.conf` is in a subdirectory called `pipeline/` of the directory in step 1.
4. Edit `logstash.conf`, and replace `<splunk-host-name-or-ip-address>` with the external Splunk Enterprise, Splunk Universal forwarder, or Splunk Cloud host name or IP address.\\
   Replace `<splunk-http-event-collector-port>` with the HTTP Event Collector port number.\\
   Replace `<splunk-http-event-collector-token>` with the HTTP Event Collector token setup on the Splunk HTTP Event Collector Data input.
5. Create the logstash image: `docker build -t <registry url>/logstash:<tag> -f Dockerfile.logstash .`
6. Push the image to your {{site.data.reuse.ocp}} cluster Docker registry: `docker push <registry url>/logstash:<tag>`

#### Example Logstash deployment

The following is an example of a deployment YAML file that sets up a Logstash instance.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: es
spec:
  selector:
    matchLabels:
      app: logstash
  replicas: 1
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
        - name: logstash
          image: >-
            <registry url>/logstash:<tag>
          ports:
            - containerPort: 9999
```

#### Example Logstash service configuration

Add a service that adds discovery and routing to the the newly formed pods after creating the Logstash instance. The following is an example of a service that uses a selector for a Logstash pod. In this example, 9999 is the port configured in `logstash.conf` we created earlier.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <logstash-service-name>
  namespace: es
  labels:
    app.kubernetes.io/name: logstash
spec:
  selector:
    app: logstash
  labels:
  ports:
    - protocol: TCP
      port: 9999
      targetPort: 9999
```

### Configure JMX for {{site.data.reuse.short_name}}

To expose the JMX port within the cluster, set the `spec.strimziOverrides.kafka.jmxOptions` value to `{}` and enable JMXTrans.

For example:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
# ...
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      jmxOptions: {}
```

**Tip:** The JMX port can be password-protected to prevent unauthorized pods from accessing it. For more information, see [Configuring secure JMX connections](../../security/secure-jmx-connections/){:target="_blank"}.

The following example shows how to configure a JMXTrans deployment in the EventStreams custom resources.

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
          outputs: ["standardOut", "logstash"]
      outputDefinitions:
        - outputType: "com.googlecode.jmxtrans.model.output.StdOutWriter"
          name: "standardOut"
        - outputType: "com.googlecode.jmxtrans.model.output.GraphiteWriterFactory"
          host: "<logstash-service-name>.<namespace>.svc"
          port: 9999
          flushDelayInSeconds: 5
          name: "logstash"
```

Events start appearing in Splunk after we apply the `jmxTrans` option in the custom resource. The time it takes for events to appear in the Splunk index is determined by the scrape interval on JMXTrans and the size of the receive queue on Splunk.

![Splunk Search](../../images/Splunk_hec_data_inputs_search.png "Screen capture showing JMXTrans metrics being displayed in Splunk.")

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


- If you require additional logs and `stdout` from Logstash, edit the `logstash.conf` file and add the `stdout` output. You can also modify `logstash.yml` to boost the log level.

   Example `logstash.conf` file:

   ```conf
   input {
       http { # input plugin for HTTP and HTTPS traffic
           port => 5044 # port for incoming requests
           ssl => false # HTTPS traffic processing
       }
       graphite {
           host => "0.0.0.0"
           port => 9999
           mode => "server"
       }
   }
   output {
       http {
           http_method => "post"
           url => "https://<splunk-host-name-or-ip-address>:<splunk-http-event-collector-port>/services/collector/raw"
           headers => ["Authorization", "Splunk <splunk-http-event-collector-token>"]
           format => "json"
           ssl_verification_mode => "none"
       }
       stdout {}
   }
   ```

   Example `logstash.yml` file:

   ```yaml
   path.config: /usr/share/logstash/pipeline/
   log.level: trace
   ```
