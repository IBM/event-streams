---
title: "Command 'cloudctl es' produces 'FAILED' message"
excerpt: "Cloudctl es command extension responds with FAILED error."
categories: troubleshooting
slug: cloudctl-es-fails
layout: redirects
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
...
```

## Causes

This error occurs when you have not logged in to the cluster and initialized the command line tool.

## Resolving the problem


{{site.data.reuse.cp_cli_login}}

Initialize the {{site.data.reuse.long_name}} CLI as follows:

`cloudctl es init`

Re-run the failed operation again.
