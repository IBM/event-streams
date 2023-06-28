---
title: "OpenShift upgrade: fixing scheduling on node and node degraded errors"
excerpt: "OpenShift upgrade for Event Streams installations: how to fix failed to schedule on nodes and node degraded errors."
categories: troubleshooting
slug: ocp-upgrade-fail
layout: redirects
toc: true
---

## Symptoms

Upgrading your {{site.data.reuse.openshift_short}} version where {{site.data.reuse.short_name}} is installed fails, with error messages about `failing to schedule nodes` or nodes reporting a `degraded status`, similar to the following:

```
Cluster operator machine-config cannot be upgraded between minor versions: One or more machine config pool is degraded.
```

## Causes

When your {{site.data.reuse.openshift_short}} has less than 3 worker nodes, the {{site.data.reuse.short_name}} pod anti-affinity rules allow multiple Kafka or ZooKeeper pods to be scheduled on the same node. This can cause a block for {{site.data.reuse.openshift_short}} upgrades where terminating multiple Kafka or ZooKeeper pods on the node will violate the pod disruption budget, which prevents the node being drained.

## Resolving the problem

To resolve this issue, you can add an extra node, or force a rebalance of the Kafka and ZooKeeper pods across the nodes to allow the upgrade to continue.

You can initiate a rebalance as follows:

1. Identify the nodes that have multiple Kafka pods:

   `oc get pods -o wide`

2. Cordon off the nodes with any Kafka pods running, leaving only the node available that has no running Kafka pods scheduled or ready:

   `oc adm cordon <worker_node_name>`

3. Delete one of the Kafka pods on the node with two Kafka pods running. As only one node is scheduled or ready, the Kafka pod restarts on the available node.

   `oc delete pod <pod_name>`

4. Verify that the Kafka pods are now all distributed across the nodes:

   `oc get pods -o wide`

5. Remove the cordon from the nodes to make all nodes available:

   `oc adm uncordon <worker_node_name>`

6. Repeat the previous steps for ZooKeeper pods.
