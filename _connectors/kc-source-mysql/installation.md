---
order: 1
forID: kc-source-mysql
categories: [source]
---

1. Download and extract the connector plugin JAR files.

    Go to the connector [Maven repository](https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql){:target="_blank"}. Open the directory for the latest version and download the file ending with `-plugin.tar.gz`.


2. {{site.data.reuse.kafkaConnectStep2_title}}

    {{site.data.reuse.kafkaConnectStep2_content_1}}
    {{site.data.reuse.kafkaConnectStep2_content1_example}}

3. {{site.data.reuse.kafkaConnectStep3_title}}

4. As a prerequisite for your connector, [set up MySQL for your Debezium connector](https://debezium.io/documentation/reference/stable/connectors/mysql.html#setting-up-mysql){:target="_blank"} and review the [connector configuration properties](https://debezium.io/documentation/reference/stable/connectors/mysql.html#_required_debezium_mysql_connector_configuration_properties){:target="_blank"}. To configure the connector for {{site.data.reuse.short_name}}, set the properties for your connector as follows in the `spec.config` section of the connector configuration YAML file. This is the file you will use to [start your connector](../../connecting/setting-up-connectors/#start-a-connector). The following example provides the configuration required for a basic username and password connection.

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
     class: io.debezium.connector.mysql.MySqlConnector
     config:
       database.server.name: <name_of_the_mysql_server_or_cluster>
       database.hostname: <mysql_server_address_or_name>
       database.user: <mysql_user_with_appropriate_privileges>
       database.password: <mysql_user’s_password>
       database.server.id: <database_server_id>
       database.port: <mysql_server_port_number>
       database.history.kafka.topic: <name_of_the_database_history_topic>
       database.history.kafka.bootstrap.servers: <list_of_kafka_brokers_that_the_connector_uses_to_write_and_recover_DDL_statements_to_the_database_history_topic>
       include.schema.changes: true
       database.include.list: <list_of_databases_hosted_by_the_specified_server>
     tasksMax: 1
     ```
