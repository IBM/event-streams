---
title: "Command 'cloudctl es' produces 'FAILED' message"
excerpt: "Cloudctl es command extension responds with FAILED error."
categories: troubleshooting
slug: cloudctl-es-fails
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
...
```

## Causes

This error occurs when you have not logged in to the cluster and initialized the command-line tool.

## Resolving the problem

{{site.data.reuse.es_cli_init_111}}

Re-run the failed operation again.
