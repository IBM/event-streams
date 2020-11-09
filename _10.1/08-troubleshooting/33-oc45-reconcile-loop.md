---
title: "Operator is generating constant log output"
excerpt: "The operator pod is showing continuous reconcilliation of an Event Streams instance and generating constant log output."
categories: troubleshooting
slug: operator-keeps-reconciling
toc: true
---

## Symptoms
The log file for the {{site.data.reuse.short_name}} operator pod shows constant looping of reconciliations when installed on {{site.data.reuse.openshift}} 4.5 or later.

```
2020-09-22 16:01:25 INFO  AbstractOperator:173 - [lambda$reconcile$3] Reconciliation #4636(watch) EventStreams(es/example): EventStreams example should be created or updated
2020-09-22 16:01:25 INFO  OperatorWatcher:35 - [eventReceived] Reconciliation #4642(watch) EventStreams(es/example): EventStreams example in namespace es was MODIFIED
```

## Causes
The {{site.data.reuse.short_name}} operator is notified that an instance of {{site.data.reuse.short_name}} has changed and needs to be reconciled. When the reconciliation is complete, the status update triggers a notification which causes a new reconciliation.

## Resolving the problem
Contact [IBM Support](../../support) to request a fix, and include issue number [ES-115](https://github.com/IBM/event-streams/issues/115){:target="_blank"} in your correspondence.
