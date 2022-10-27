---
order: 1
forID: kc-sink-elastic
categories: [sink]
---

1. Download the connector plugin JAR file.

    Go to the connector [releases page](https://github.com/ibm-messaging/kafka-connect-elastic-sink/releases){:target="_blank"} and download the JAR file for the latest release.

2. {{site.data.reuse.kafkaConnectStep2_title}}

    {{site.data.reuse.kafkaConnectStep2_content_1}}
    {{site.data.reuse.kafkaConnectStep2_content1_example}}

3. {{site.data.reuse.kafkaConnectStep3_title}}

4. To connect Elasticsearch to Kafka Connect, obtain the KeyStore details from Elasticsearch, convert the details into JKS format, store the JKS file in a OpenShift secret, and mount the file on to the Kafka Connect pod

5. To configure the connector for {{site.data.reuse.short_name}}, set the properties for your connector as follows in the `spec.config` section of the connector configuration YAML file. This is the file you will use to [start your connector](../../connecting/setting-up-connectors/#start-a-connector).

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
     class: com.ibm.eventstreams.connect.elasticsink.ElasticSinkConnector
     config:
       key.ignore: true
       value.converter: org.apache.kafka.connect.json.JsonConverter
       topics: <topic_name>
       es.document.builder: com.ibm.eventstreams.connect.elasticsink.builders.JsonDocumentBuilder
       value.converter.schemas.enable: false
       es.user.name: <elastic_username>
       es.tls.keystore.location: <location_of_mounted_tls_keystore_in_kafka_connect_pod>
       key.converter: org.apache.kafka.connect.storage.StringConverter
       es.tls.keystore.password: <tls_keystore_password>
       es.identifier.builder: com.ibm.eventstreams.connect.elasticsink.builders.DefaultIdentifierBuilder
       connector.class: com.ibm.eventstreams.connect.elasticsink.ElasticSinkConnector
       es.password: <elastic_search_user_password>
       es.connection: <connection_to_elastic_search_instance>
       type.name: _doc
       es.index.builder: com.ibm.eventstreams.connect.elasticsink.builders.DefaultIndexBuilder
       schema.ignore: true
     tasksMax: 1
   ```
