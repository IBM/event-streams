---
title: "Using Apache Kafka console tools"
excerpt: "Using Apache Kafka console tools with IBM Event Streams."
categories: getting-started
slug: using-kafka-console-tools
layout: redirects
toc: true
---

Apache Kafka comes with a variety of console tools for simple administration and messaging operations. You can find these console tools in the `bin` directory of your [Apache Kafka download](https://www.apache.org/dyn/closer.cgi?path=/kafka/2.2.1/kafka_2.11-2.2.1.tgz){:target="_blank"}.

You can use many of them with {{site.data.reuse.long_name}}, although {{site.data.reuse.long_name}} does not permit connection to its ZooKeeper cluster. As Kafka has developed, many of the tools that previously required connection to ZooKeeper no longer have that requirement. {{site.data.reuse.long_name}} has its own [command-line interface (CLI)](../../installing/post-installation/#installing-the-command-line-interface-cli) and this offers many of the same capabilities as the Kafka tools in a simpler form.

The following table shows which Apache Kafka (release 2.0 or later) console tools work with {{site.data.reuse.long_name}} and whether there are CLI equivalents.

| Console tool     | Works with {{site.data.reuse.long_name}}      | CLI equivalent   |
|:-----------------|:-----------------|:-----------------|
| `kafka-acls.sh`    | No, see [managing access](../../security/managing-access/) | |
| `kafka-broker-api-versions.sh` | Yes | |
| `kafka-configs.sh --entity-type topics` | No, requires ZooKeeper access | `cloudctl es topic-update` |
| `kafka-configs.sh --entity-type brokers` | No, requires ZooKeeper access | `cloudctl es broker-config` |
| `kafka-configs.sh --entity-type brokers --entity-default` | No, requires ZooKeeper access | `cloudctl es cluster-config` |
| `kafka-configs.sh --entity-type clients` | No, requires ZooKeeper access | `cloudctl es entity-config` |
| `kafka-configs.sh --entity-type users` | No, requires ZooKeeper access | No |
| `kafka-console-consumer.sh` | Yes | |
| `kafka-console-producer.sh` | Yes | |
| `kafka-consumer-groups.sh --list` | Yes | `cloudctl es groups` |
| `kafka-consumer-groups.sh --describe` | Yes | `cloudctl es group` |
| `kafka-consumer-groups.sh --reset-offsets` | Yes | `cloudctl es group-reset` |
| `kafka-consumer-groups.sh --delete` | Yes | `cloudctl es group-delete` |
| `kafka-consumer-perf-test.sh` | Yes | |
| `kafka-delete-records.sh` | Yes | `cloudctl es topic-delete-records` |
| `kafka-preferred-replica-election.sh` | No | |
| `kafka-producer-perf-test.sh` | Yes | |
| `kafka-streams-application-reset.sh` | Yes | |
| `kafka-topics.sh --list` | Yes | `cloudctl es topics` |
| `kafka-topics.sh --describe` | Yes | `cloudctl es topic` |
| `kafka-topics.sh --create` | Yes | `cloudctl es topic-create` |
| `kafka-topics.sh --delete` | Yes | `cloudctl es topic-delete` |
| `kafka-topics.sh --alter --config` | Yes | `cloudctl es topic-update` |
| `kafka-topics.sh --alter --partitions` | Yes | `cloudctl es topic-partitions-set` |
| `kafka-topics.sh --alter --replica-assignment` | Yes | `cloudctl es topic-partitions-set` |
| `kafka-verifiable-consumer.sh` | Yes | |
| `kafka-verifiable-producer.sh` | Yes | |

## Using the console tools with {{site.data.reuse.long_name}}

The console tools are Kafka client applications and connect in the same way as regular applications.

Follow the [instructions for securing a connection](../../getting-started/client/#securing-the-connection) to obtain:
* Your cluster’s broker URL
* The truststore certificate
* An API key

Many of these tools perform administrative tasks and will need to be authorized accordingly.

Create a properties file based on the following example:

```
security.protocol=SASL_SSL
ssl.protocol=TLSv1.2
ssl.truststore.location=<certs.jks_file_location>
ssl.truststore.password=<truststore_password>
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="token" password="<api_key>";
```

Replace:
* `<certs.jks_file_location>` with the path to your truststore file
* `<truststore_password>` with `"password"`
* `<api_key>` with your API key


### Example - console producer

You can use the Kafka console producer tool with {{site.data.reuse.long_name}}.

After you've created the properties file as described previously, you can run the console producer in a terminal as follows:

```
./kafka-console-producer.sh --broker-list <broker_url> --topic <topic_name> --producer.config <properties_file>
```

Replace:
* `<broker_url>` with your cluster's broker URL
* `<topic_name>` with the name of your topic
* `<properties_file>` with the name of your properties file including full path to it


### Example - console consumer

You can use the Kafka console consumer tool with {{site.data.reuse.long_name}}.

After you've created the properties file as described previously, you can run the console consumer in a terminal as follows:

```
./kafka-console-consumer.sh --bootstrap-server <broker_url> --topic <topic_name> --from-beginning --consumer.config <properties_file>
```

Replace:
* `<broker_url>` with your cluster's broker URL
* `<topic_name>` with the name of your topic
* `<properties_file>` with the name of your properties file including full path to it
