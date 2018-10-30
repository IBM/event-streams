---
title: "Command 'cloudctl es' produces 'FAILED' message"
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

This error occurs when you have not logged in to the {{site.data.reuse.icp}} cluster and initialized the command line tool.

## Resolving the problem

Ensure you log in to the {{site.data.reuse.icp}} cluster as follows:

```
cloudctl login -a https://<master-ip>:8443 --skip-ssl-validation
```

After logging in to {{site.data.reuse.icp}}, initialize the {{site.data.reuse.long_name}} CLI as follows:

```
cloudctl es init
```

Finally, run the operation again.
