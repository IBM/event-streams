---
title: "'cloudctl es' command errors with 'FAILED' message"
permalink: /troubleshooting/cloudctl-es-fails/
excerpt: "Cloudctl es command extension responds with FAILED error"
last_modified_at:
toc: true
---

## Symptoms

When running the `cloudctl es` command, the following error message is displayed:

```
FAILED
...
```

## Causes

This can be caused if the correct initialization steps have not been performed to login to the {{site.data.reuse.icp}} cluster and initialize the command line tools.

## Resolving the problem

Ensure you have logged into the {{site.data.reuse.icp}} cluster:

```
cloudctl login -a https://CLUSTER_IP:BOOTSTRAP_PORT -u USER_ID -p PASSWORD
```

Once logged into {{site.data.reuse.icp}}, initialize the 'es' CLI tool:

```
cloudctl es init
```

Finally, run the operation again.
