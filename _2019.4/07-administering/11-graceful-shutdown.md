---
title: "Stopping and starting Event Streams"
excerpt: "Find out how to gracefully shut down your Event Streams cluster, for example, in preparation for maintenance."
categories: administering
slug: stopping-starting
toc: true
---

You can stop your {{site.data.reuse.short_name}} cluster if required, for example, in preparation for maintenance.

Use the following instructions to gracefully shut down your {{site.data.reuse.short_name}} cluster. You can then start the cluster up again when it is ready.

## Stopping

To shut down your cluster gracefully, scale all deployments and stateful sets to 0 replicas as follows.

1. {{site.data.reuse.icp_cli_login321}}

2. Retrieve all deployments and stateful sets in your {{site.data.reuse.short_name}} namespace associated with the release, and scale them down to 0 replicas:

    ```
    kubectl get deployments -n <namespace> -l release=<release-name> -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas --no-headers > <deploy-replicas-filename> && while read -ra deploy; do kubectl -n <namespace> scale --replicas=0 deployment/${deploy}; done < <deploy-replicas-filename>
    kubectl get sts -n <namespace> -l release=<release-name> -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas --no-headers > <sts-replicas-filename> && while read -ra sts; do kubectl -n <namespace> scale --replicas=0 sts/${sts}; done < <sts-replicas-filename>
    ```

Where:
- `<namespace>` is the location of your installation.
- `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.
- `<deploy-replicas-filename>` is the file where deployment - replica pairs are to be saved (provide a name, for example, `deploy-replicas.yaml`).
- `<sts-replicas-filename>` is the file where stateful set - replica pairs are to be saved (provide a name, for example, `sts-replicas.yaml`).


## Starting up

To start up your cluster and scale it back up to its previous state, run the following commands.

1. {{site.data.reuse.icp_cli_login321}}

2. Retrieve and apply the previous configuration for your {{site.data.reuse.short_name}} instance:

    ```
    while IFS= read -ra deploy; do d=$(echo $deploy | cut -f1 -d" "); rep=$(echo $deploy | cut -f2 -d" "); kubectl -n <namespace> scale --replicas=$rep deployment/${d}; done < <deploy-replicas-filename>
    while IFS= read -ra sts; do s=$(echo $sts | cut -f1 -d" "); rep=$(echo $sts | cut -f2 -d" "); kubectl -n <namespace> scale --replicas=$rep sts/${s}; done < <sts-replicas-filename>
    ```

Where:
- `<namespace>` is the location of your installation.
- `<deploy-replicas-filename>` is the file where you saved deployment - replica pairs (for example, `deploy-replicas.yaml`).
- `<sts-replicas-filename>` is the file where you saved stateful set - replica pairs (for example, `sts-replicas.yaml`).
