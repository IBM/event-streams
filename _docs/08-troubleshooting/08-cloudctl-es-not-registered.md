---
title: "'cloudctl es' command fails with 'not a registered command' error"
permalink: /troubleshooting/cloudctl-es-not-registered/
excerpt: "Cloudctl es command extension not registered"
last_modified_at:
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
'es' is not a registered command. See 'cloudctl help'.
```

## Causes

This is seen if the {{site.data.reuse.long_name}} Command Line Interface has not been installed.

## Resolving the problem

To install the CLI, log into the {{site.data.reuse.long_name}} UI, select the **Toolbox** tab, click the **Find out more** button under **IBM Event Streams command-line interface** and follow the instructions provided.
