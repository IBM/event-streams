---
title: "FileStream"
sortTitle: "FileStream"
connectorID: kc-sink-filestream
direction: sink
support: community
type: kafkaConnect
iconInitial: Fs
documentationURL: https://kafka.apache.org/quickstart#quickstart_kafkaconnect
download:
  -  { type: 'GitHub', url: 'https://github.com/apache/kafka/tree/trunk/connect/file/src/main/java/org/apache/kafka/connect/file' }
---

FileStream sink connector for reading data from a Kafka topic and writing it to a local file. This connector is meant for use in standalone mode.

**Note:** The FileStream sink connector is not intended for production use.