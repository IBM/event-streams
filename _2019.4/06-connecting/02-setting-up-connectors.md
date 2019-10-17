---
title: "Setting up and running connectors"
excerpt: "Event Streams helps you set up a Kafka Connect environment, add connectors to it, and run the connectors to help integrate external systems."
categories: connecting
slug: setting-up-connectors
toc: true
---

{{site.data.reuse.long_name}} helps you set up a Kafka Connect environment, prepare the connection to other systems by adding connectors to the environment, and start Kafka Connect with the connectors to help integrate external systems.

[Log in](../../getting-started/logging-in/) to the {{site.data.reuse.short_name}} UI, and click **Toolbox** in the primary navigation. Scroll to the **Connectors** section and follow the guidance for each main task. You can also find additional help on this page.


## Setting up a Kafka Connect environment

Set up the environment for hosting Kafka Connect. You can then use Kafka Connect to stream data between {{site.data.reuse.short_name}} and other systems.

Kafka Connect can be run in standalone or distributed mode. For more details see the [explanation of Kafka Connect workers](../connectors/#workers). Kafka Connect includes shell and bash scripts for starting workers that take configuration files as arguments.

For best results running Kafka Connect alongside {{site.data.reuse.short_name}} start Kafka Connect in distributed mode in Docker containers. In this mode, work balancing is automatic, scaling is dynamic, and tasks and data are fault-tolerant. To begin using Kafka Connect in distributed mode, follow the steps below, then add the connectors to your other systems and start Kafka Connect in its Docker container.

**Note:** The Kafka Connect Docker container is designed for a Linux environment.

### Create topics

When running in distributed mode Kafka Connect uses three topics to store configuration, current offsets and status. In standalone mode Kafka Connect uses a local file.

Create the following topics:

- **connect-configs**: This topic will store the connector and task configurations.
- **connect-offsets**: This topic is used to store offsets for Kafka Connect.
- **connect-status**: This topic will store status updates of connectors and tasks.

**Note:** The topic names match the default settings. If you change these settings in your Kafka Connect properties file create topics that match the names you provided.

#### Using the UI

1. Click **Topics** in the primary navigation.
2. Click **Create topic**.
3. Set **Show all available options** to **On**.
4. Create the three topics with the following parameters, leaving other parameters as default. `Name`, `partitions`, and `replicas` can be edited in **Core configuration**, and `cleanup policy` can be edited in **Log**:

| Name             | Partitions   | Replicas            | Cleanup policy
|------------------|--------------|---------------------|-----------------
| connect-configs  | 1            | 3                   | compact

| Name             | Partitions   | Replicas            | Cleanup policy
|------------------|--------------|---------------------|-----------------
| connect-offsets  | 25           | 3                   | compact

| Name             | Partitions   | Replicas            | Cleanup policy
|------------------|--------------|---------------------|-----------------
| connect-status   | 5            | 3                   | compact

#### Using the CLI

1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI on the cluster:\\
   `cloudctl es init`
3. Run the following commands to create the topics:\\
   ```
   cloudctl es topic-create -n connect-configs -p 1 -r 3 -c cleanup.policy=compact
   cloudctl es topic-create -n connect-offsets -p 25 -r 3 -c cleanup.policy=compact
   cloudctl es topic-create -n connect-status -p 5 -r 3 -c cleanup.policy=compact
   ```


### Provide or generate an API key

This API key must provide permission to **produce** and **consume** messages for **all topics**, and also to **create topics**. This will enable Kafka Connect to securely connect to your IBM Event Streams cluster.

1. In the {{site.data.reuse.short_name}} UI, click **Toolbox** in the primary navigation. Scroll to the **Connectors** section.
2. Go to the **Set up a Kafka Connect environment** tile, and click **Set up**.
3. Go to step 4 and either paste an API key that provides permission to produce and consume messages, and also to create topics, or click **Generate API key** to create a new key.

### Download Kafka Connect

On the same page, go to step 5, and click **Download Kafka Connect ZIP** to download the compressed file, then extract the contents to your preferred location.

## Adding connectors to your Kafka Connect environment

Prepare Kafka Connect for connections to your other systems by adding the required connectors.

If you are following on from the previous step, you can click **Next** at the bottom of the page. You can also access this page by clicking **Toolbox** in the primary navigation, scrolling to the **Connectors** section, and clicking **Add connectors** on the **Add connectors to your Kafka Connect environment** tile.

To run a particular connector Kafka Connect must have access to a JAR file or set of JAR files for the connector. The quickest way to do this is by adding the JAR file(s) to the classpath of Kafka Connect. This is not the recommended approach because it does not provide classpath isolation for different connectors.

Since version 0.11.0.0 of Kafka the recommended approach is to configure the `plugin.path` in the Kafka Connect properties file to point to the location of your connector JAR(s).

If you are using the provided Kafka Connect ZIP, the resulting Docker image will copy all connectors in the `/connectors` directory into the container on the `plugin.path`. Copy the connector JAR file(s) you want to have available into the `/connectors` directory:

`cp <path_to_your_connector>.jar <extracted_zip>/connectors`

## Starting Kafka Connect with your connectors

If you are following on from the previous step, you can click **Next** at the bottom of the page. You can also access this page by clicking **Toolbox** in the primary navigation, scrolling to the **Connectors** section, and clicking **Start Kafka Connect** on the **Start Kafka Connect with your connectors** tile.

You can run Kafka Connect in standalone or distributed mode by using the `connect-standalone.sh` or `connect-distributed.sh` scripts that are included in the `bin` directory of a Kafka install.

If using the provided Kafka Connect ZIP, Kafka Connect can be built and run using Docker commands as follows.

1. Build Kafka Connect Docker container. Go to the location where you extracted the Kafka Connect ZIP file you downloaded earlier as part of setting up your environment, and build the Kafka Connect Docker image:\\
   ```
   cd kafkaconnect
   docker build -t kafkaconnect:0.0.1 .
   ```
2. Run the Docker container:\\
   `docker run -v $(pwd)/config:/opt/kafka/config -p 8083:8083 kafkaconnect:0.0.1`
3. Verify that your chosen connectors are installed in your Kafka Connect environment:\\
   `curl http://localhost:8083/connector-plugins`\\
   A list of connector plugins available is displayed.

## Starting a connector

Start a connector by using the Kafka Connect REST API. When running in distributed mode connectors are started using a POST request against your running Kafka Connect.

The endpoint requires a body that includes the configuration for the connector instance you want to start. Most connectors include examples in their documentation. The {{site.data.reuse.short_name}} UI and CLI provide additional assistance for connecting to IBM MQ. See the [connecting MQ instructions](../mq/) for more details.

For example, to create a FileStreamSource connector you can create a file with the following contents:
```
{
   "name": "my-connector",
   "config": {
      "connector.class": "FileStreamSource",
      "file": "config/connect-distributed.properties",
      "topic":"kafka-config-topic"
   }
}
```
1. Once you have created a JSON file with the configuration for your chosen connector start the connector using the REST API:\\
   ```
   curl -X POST http://localhost:8083/connectors \
	-H "Content-Type: application/json"  \
	-d @<config>.json
   ```
2. View the status of a connector by using the Kafka Connect REST API:\\
   `curl http://localhost:8083/connectors/<connector_name>/status`
   Repeat for each connector you want to start.

For more information about the other REST API endpoints (such as pausing, restarting, and deleting connectors) see the [Kafka Connect REST API documentation](https://kafka.apache.org/documentation/#connect_rest){:target="_blank"}.
