---
title: "FileStream"
sortTitle: "FileStream"
connectorID: kc-source-filestream
direction: source
support: community
type: kafkaConnect
iconInitial: Fs
documentationURL: https://kafka.apache.org/quickstart#quickstart_kafkaconnect
download:
  -  { type: 'GitHub', url: 'https://github.com/apache/kafka/tree/trunk/connect/file/src/main/java/org/apache/kafka/connect/file' }
---

FileStream source connector for reading data from a local file and sending it to a Kafka topic. This connector is meant for use in standalone mode.

**Note:** The FileStream source connector is not intended for production use.