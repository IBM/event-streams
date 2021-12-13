---
title: "UI is unable to display consumer groups for a topic"
excerpt: "The Event Streams UI is unable to display consumer groups for a topic and the Admin REST component reports an invalid negative offset exception in the log."
categories: troubleshooting
slug: invalid-negative-offset
toc: true
---

## Symptoms

The {{site.data.reuse.short_name}} UI is unable to display consumer groups for a particular topic and the log output for the Admin REST component shows an exception similar to the following:

```
java.lang.IllegalArgumentException: Invalid negative offset
```

## Causes

See [Kafka issue 9507](https://issues.apache.org/jira/browse/KAFKA-9507){:target="_blank"}.

When processing a list offsets request, the Kafka AdminClient does not filter out offsets with value `-1`, and receives an `IllegalArgumentException` when it creates the response.

## Resolving the problem

Contact [IBM Support]({{ 'support' | relative_url }}) to request a fix, and include issue number [139](https://github.com/IBM/event-streams/issues/139){:target="_blank"} in your correspondence.


Resolved in {{site.data.reuse.short_name}} version 10.0.0 and later.
