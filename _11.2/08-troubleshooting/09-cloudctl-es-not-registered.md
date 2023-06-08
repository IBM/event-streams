---
title: "Event Streams CLI fails with 'not a registered command' error"
excerpt: "Event Streams CLI command extension not registered."
categories: troubleshooting
slug: cloudctl-es-not-registered
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
'es' is not a registered command. See 'cloudctl help'.
```

A similar error message is displayed when running the `kubectl es` command:

```
FAILED
'es' is not a registered command. See 'kubectl help'.
```

## Causes

This error occurs when you attempt to use the {{site.data.reuse.long_name}} CLI before it is installed.

## Resolving the problem

Log in to the {{site.data.reuse.long_name}} UI, and [install the CLI](../../installing/post-installation/#installing-the-event-streams-command-line-interface).
