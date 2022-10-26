---
order: 1
forID: kc-source-postgresql
categories: [source]
---

1. Download and extract the connector plugin JAR files.

    Go to the connector [Maven repository](https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres){:target="_blank"}. Open the directory for the latest version and download the file ending with `-plugin.tar.gz`.


2. {{site.data.reuse.kafkaConnectStep2_title}}

    {{site.data.reuse.kafkaConnectStep2_content_1}}
    {{site.data.reuse.kafkaConnectStep2_content1_example}}

3. {{site.data.reuse.kafkaConnectStep3_title}}

4. As a prerequisite for your connector, [configure the PostgreSQL server](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-server-configuration){:target="_blank"} for your Debezium connector and review the [connector configuration properties](https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-connector-properties){:target="_blank"}. To configure the connector for {{site.data.reuse.short_name}}, set the properties for your connector as follows in the `spec.config` section of the connector configuration YAML file. This is the file you will use to [start your connector](../../connecting/setting-up-connectors/#start-a-connector). The following example provides the configuration required for a basic username and password connection.

   ```yaml
   apiVersion: eventstreams.ibm.com/v1beta2
   kind: KafkaConnector
   metadata:
     name: <connector_name>
     labels:
       # The eventstreams.ibm.com/cluster label identifies the KafkaConnect instance
       # in which to create this connector. That KafkaConnect instance
       # must have the eventstreams.ibm.com/use-connector-resources annotation
       # set to true.
       eventstreams.ibm.com/cluster: <kafka_connect_name>
   spec:
     class: io.debezium.connector.postgresql.PostgresConnector
     config:
       database.server.name: <name_of_the_postgres_server_or_cluster>
       plugin.name: pgoutput
       database.hostname: <ip_address_or_hostname_of_the_postgres_database_server>
       database.dbname: <database_name>
       database.user: <postgres_user_name>
       database.password:  <postgres_password>
       database.port: <port_for_postgres_database_server>
       database.history.kafka.topic: <kafka_topic_name>
       database.history.kafka.bootstrap.servers: <bootstrap_server_address>
     tasksMax: 1
   ```
