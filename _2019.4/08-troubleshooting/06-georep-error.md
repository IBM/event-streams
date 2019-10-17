---
title: "Error when creating multiple geo-replicators"
excerpt: "No meaningful error message provided when specifying invalid topic list format."
categories: troubleshooting
slug: georeplication-error
toc: true
---

## Symptoms

The following error message is displayed when setting up replication by using the CLI:

```
FAILED
Event Streams API request failed:
Error response from server. Status code: 400. The resource request is invalid. Missing required parameter topic name
```

The message does not provide accurate information about the cause of the error.

## Causes

When providing the [list of topics to geo-replicate](../../georeplication/setting-up/#using-the-cli-1), you added spaces between the topic names in the comma-separated list.


## Resolving the problem

Ensure you do not have spaces between the topic names. For example, instead of `--topics MyTopicName1, MyTopicName2, MyTopicName3`, enter `--topics MyTopicName1,MyTopicName2,MyTopicName3`.
