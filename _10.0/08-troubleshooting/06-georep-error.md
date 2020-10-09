---
title: "Error when creating multiple geo-replicators"
excerpt: "No meaningful error message provided when specifying invalid topic list format."
categories: troubleshooting
slug: georeplication-error
toc: true
---

## Symptoms

After providing a list of topic names when creating a geo-replicator, only the first topic successfully replicates data.

The additional topics specified are either not displayed in the destination cluster UI **Topics** view, or are displayed as `<origin-release>.<topic-name>` but are not enabled for geo-replication.

## Causes

When using the CLI to set up replication, the [list of topics to geo-replicate](../../georeplication/setting-up/#using-the-cli-1) included spaces between the topic names in the comma-separated list.

## Resolving the problem

Ensure you do not have spaces between the topic names. For example, if you specified the `topics` parameter with spaces such as:

```
--topics MyTopicName1, MyTopicName2, MyTopicName3
--topics "MyTopicName1, MyTopicName2, MyTopicName3"
```

Remove the spaces between the topic names and re-apply the command using a `topics` parameter with no spaces such as:

```
--topics MyTopicName1,MyTopicName2,MyTopicName3
```
