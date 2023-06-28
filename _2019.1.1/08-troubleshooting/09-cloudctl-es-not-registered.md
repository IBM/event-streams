---
title: "Command 'cloudctl es' fails with 'not a registered command' error"
excerpt: "Cloudctl es command extension not registered."
categories: troubleshooting
slug: cloudctl-es-not-registered
layout: redirects
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
'es' is not a registered command. See 'cloudctl help'.
```

## Causes

This error occurs when you attempt to use the {{site.data.reuse.long_name}} CLI before it is installed.

## Resolving the problem

Log into the {{site.data.reuse.long_name}} UI, and [install the CLI](../../installing/post-installation/#installing-the-command-line-interface).
