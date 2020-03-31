---
title: "Event Streams producer API"
excerpt: "Use the Event Streams producer API to connect other systems to your Kafka cluster."
categories: connecting
slug: rest-api
toc: true
---

{{site.data.reuse.short_name}} provides a REST API to help connect your existing systems to your {{site.data.reuse.short_name}} Kafka cluster. Using the API, you can integrate {{site.data.reuse.short_name}} with any system that supports RESTful APIs.

The REST producer API is a scalable REST interface for producing messages to {{site.data.reuse.short_name}} over a secure HTTP endpoint. Send event data to {{site.data.reuse.short_name}}, utilize Kafka technology to handle data feeds, and take advantage of {{site.data.reuse.short_name}} features to manage your data.

Use the API to connect existing systems to {{site.data.reuse.short_name}}, such as IBM Z mainframe systems with IBM z/OS Connect, systems using IBM DataPower Gateway, and so on. Create produce requests from your systems into {{site.data.reuse.short_name}}, including specifying the message key, headers, and the topics you want to write messages to.

**Note:** You must have {{site.data.reuse.short_name}} version 2019.1.1 or later to use the REST API.

## Producing messages using REST

Use the producer API to write messages to topics. To be able to produce to a topic, you must have the following available:
- The URL of the {{site.data.reuse.short_name}} API endpoint, including the port number.
- The topic you want to produce to.
- The API key that gives permission to connect and produce to the selected topic.
- The {{site.data.reuse.short_name}} certificate.

To retrieve the full URL for the {{site.data.reuse.short_name}} API endpoint:
1. Ensure you have the {{site.data.reuse.short_name}} CLI [installed](../../installing/post-installation/#installing-the-command-line-interface-cli).
2. {{site.data.reuse.icp_cli_login}}
3. Run the following command to initialize the {{site.data.reuse.short_name}} CLI: `cloudctl es init`.\\
   If you have more than one {{site.data.reuse.short_name}} instance installed, select the one where the topic you want to produce to is.\\
   Details of your {{site.data.reuse.short_name}} installation are displayed.
4. Copy the full URL from the `Event Streams API endpoint` field, including the port number.


To create a topic and generate an API key with produce permissions, and to download the certificate:
1. If you have not previously created the topic, create it now:\\
   `cloudctl es topic-create --name <topic_name> --partitions 1 --replication-factor 3`
2. Create a service ID and generate an API key:\\
   `cloudctl es iam-service-id-create --name <serviceId_name> --role editor --topic <topic_name>`\\
   For more information about roles, permissions, and service IDs, see the information about [managing access](../../security/managing-access/).
3. Copy the API key returned by the previous command.
4. Download the certificate for {{site.data.reuse.short_name}}:\\
   `cloudctl es certificates --format pem`

You have now gathered all the details required to use the producer API. You can use the usual languages for making the API call. For example, to use cURL to produce messages to a topic with the producer API, run the `curl` command as follows:

`curl -v -X POST -H "Authorization: Bearer <api_key>" -H "Content-Type: text/plain" -H "Accept: application/json" -d 'test message' --cacert es-cert.pem "<api_endpoint>/topics/<topic_name>/records"`

Where:
- `<api_key>` is the API key you generated earlier.
- `<api_endpoint>` is the full URL copied from the `Event Streams API endpoint` field earlier (format `https://<host>:<port>`)
- `<topic_name>` is the name of the topic you want to produce messages to.

For full details of the API, see the [API reference](../../../api/){:target="_blank"}.


<!--
To create a topic and API key with produce permissions by using the UI:
1. Log in to your {{site.data.reuse.short_name}} UI.
2. Click the **Topics** tab.
3. Select the topic you want to produce to. If you have not previously created the topic, create it now by clicking **Create topic**.
4. Click **Connect to this topic** on the right.
6. On the **Connect a client** tab, go to the **API key** section, and follow the instructions to generate an API key authorized to connect to the cluster and produce to the topic. Ensure you select **Produce only**. The name of the selected topic is filled in automatically.
-->
