---
title: "Running a starter application"
excerpt: "Create a starter application to learn more about using Event Streams."
categories: getting-started
slug: generating-starter-app
toc: true
---

To learn more about how to create applications that can take advantage of {{site.data.reuse.long_name}} capabilities, you can use the starter application. The starter application can produce and consume messages, and you can specify the topic to send messages to and the contents of the message.

## About the application
The starter application provides a demonstration of a Java application that uses the [Vert.x Kafka Client](https://vertx.io/docs/vertx-kafka-client/java/){:target="_blank"} to send events to, and receive events from, {{site.data.reuse.short_name}}. It also includes a user interface to easily view message propagation. The source code is provided in [GitHub](https://github.com/ibm-messaging/kafka-java-vertx-starter){:target="_blank"} to allow you to understand the elements required to create your own Kafka application.

## Downloading the application
If you do not already have the application, download the JAR file from the {{site.data.reuse.short_name}} UI.
1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click the **Try the starter application** tile, or click **Toolbox** in the primary navigation, go to the **Starter application** section, and click **Get started**.
3. Click **Download JAR from GitHub**.
4. Download the JAR file for the latest release.

## Generate security and configuration files
Before you can run the application, generate security and configuration files to connect to your {{site.data.reuse.short_name}} and the target topic.

Some of the following steps depend on your [access permissions](../../security/managing-access/):
- If you have logged in to the {{site.data.reuse.short_name}} UI by using an {{site.data.reuse.icpfs}} Identity and Access Management (IAM) user ID, and are not permitted to generate credentials, you will not see the **Generate properties** button. You will have to obtain security and configuration files from your administrator before running the application.
-   If you have logged in to the {{site.data.reuse.short_name}} UI by using a SCRAM `KafkaUser`, you will need `topic read` and `topic write` permissions to generate the properties as described in [managing access to the UI with SCRAM](../../security/managing-access/#managing-access-to-the-ui-with-scram). If permitted, these properties will be generated with the credentials of the current user. No additional `KafkaUsers` will be generated. If you are not permitted to create topics, you will not be able to create a topic as mentioned in the steps later in this section, and will have to use a pre-existing topic.

1. From the **Starter application** menu opened in [the previous step](#downloading-the-application), click **Generate properties** to open the side panel.
2. Enter an application name in the **Starter application name** field. This value is used by {{site.data.reuse.short_name}} to create a `KafkaUser`, which will provide your application with credentials to connect to {{site.data.reuse.short_name}} securely.
   **Note:** This name must be unique to avoid potential clashes with pre-existing KafkaUser resources.

3. Select a new or existing topic to connect to.
   **Note:** When creating a new topic the name must be unique to avoid potential clashes with pre-existing topics.
4. Click the **Generate and download .zip** button to download the compressed file, then extract the contents to your preferred location.

## Running the application

Before running the application, ensure you have the following available:
1. The application [JAR file](#downloading-the-application).
2. A directory containing [security and configuration files](#generate-security-and-configuration-files)

Run the following command to start the application:

```
java -Dproperties_path=<configuration_properties_path> -jar <jar_path>/demo-all.jar
```

Where:
- `configuration_properties_path` is the path to the directory containing the extracted security and configuration files.
- `jar_path` is the path to the downloaded application JAR file.

Wait for the application to be ready. It will print out the following message:
```
Application started in Xms
```

When the application is ready, access the UI by using the following URL: [http://localhost:8080](http://localhost:8080). Use the start button in the UI to produce messages and see them consumed.
