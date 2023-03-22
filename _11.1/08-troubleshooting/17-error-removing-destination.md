---
title: "Unable to remove destination cluster"
excerpt: "Error is displayed when trying to remove a destination cluster."
categories: troubleshooting
slug: error-removing-destination
toc: true
---

## Symptoms

When trying to remove an offline geo-replication destination cluster, the following error message is displayed in the UI:

```
Failed to retrieve data for this destination cluster.
```

## Causes

There could be several reasons, for example, the cluster might be offline, or the service ID of the cluster might have been revoked.

## Resolving the problem

1. Go to your origin cluster. {{site.data.reuse.es_cli_init_111}}
3. Retrieve destination cluster IDs by using the following command:\\
   `cloudctl es geo-clusters`\\
   Look for the destination cluster ID that you want to remove.
4. Run the following command:\\
   `cloudctl es geo-cluster-remove --destination <destination-cluster-id> --force`
