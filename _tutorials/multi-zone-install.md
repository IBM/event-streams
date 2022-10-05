---
title: "Installing a multizone cluster"
description: "See an example of setting up a multizone Event Streams in a non-zone-aware cluster."
permalink: /tutorials/multi-zone-tutorial/
toc: true
section: "Tutorials for IBM Event Streams"
cardType: "large"
---

The following tutorial explains how to set up a [multizone](../../installing/preparing-multizone/) {{site.data.reuse.short_name}} cluster in a non-zone-aware cluster.

This tutorial provides instructions for installing an {{site.data.reuse.short_name}} cluster across 3 availability zones. Firstly, the instructions go through how to prepare your cluster for multiple zones by labelling your nodes, and secondly, how to use those labels to set up the zones when installing {{site.data.reuse.short_name}}.

## Prerequisites

This tutorial is based on the following software versions:
- {{site.data.reuse.openshift_short}} version 4.10
- {{site.data.reuse.short_name}} version 11.0.4

## Labels on worker nodes

In a multizone {{site.data.reuse.openshift_short}} cluster, each node will have a label indicating the availability zone from which the node is being provisioned from, for example:

`topology.kubernetes.io/zone=us-south-1`

To verify that your cluster is zone aware, you can run the following command:

`oc get nodes --show-labels`

After running the command, you can inspect the labels for each node by looking for a label similar to `topology.kubernetes.io/zone=<availability_zone>`.

If the node labels are not listed (which is possible on earlier versions of {{site.data.reuse.openshift_short}} than 4.10), follow the instructions provided in [preparing for a multizone cluster](../../installing/preparing-multizone/#zone-awareness) to add labels to the nodes of you OpenShift cluster.

## Enabling the operator for multizone deployments

The operator does not have sufficient permissions to do a multizone installation. Therefore, a cluster role and a cluster role binding are required to enable multizone deployments. To get these you will need to apply the following YAML content on to the cluster:

- Cluster role:

   ```
      kind: ClusterRole
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: eventstreams-kafka-broker
          labels:
            app: eventstreams
      rules:
      - verbs:
            - get
            - create
            - watch
            - update
            - delete
            - list
        apiGroups:
            - rbac.authorization.k8s.io
        resources:
            - clusterrolebindings
      - verbs:
            - get
            - create
            - watch
            - update
            - delete
            - list
        apiGroups:
            - ""
        resources:
            - nodes
   ```

- Cluster role binding where `<operator_namespace>` is the namespace the operator pod is deployed in:

   ```
   kind: ClusterRoleBinding
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: eventstreams-kafka-broker
   subjects:
   - kind: ServiceAccount
     name: eventstreams-cluster-operator-namespaced
     namespace: <operator_namespace>
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: eventstreams-kafka-broker
   ```

For more details, see [preparing for a multizone cluster](../../installing/preparing-multizone/#kafka-rack-awareness).

## Installing {{site.data.reuse.short_name}}

When installing a multizone {{site.data.reuse.short_name}} instance, the operator needs to know what label to base its zoning on. This can be set in the {{site.data.reuse.short_name}} custom resource by using the zone label as the topology key in the `spec.strimziOverrides.kafka.rack` field. For example, the following snippet shows the `rack.topologyKey` field set to `topology.kubernetes.io/zone`.

```
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
metadata:
  name: example-broker-config
  namespace: myproject
spec:
  # ...
  strimziOverrides:
    # ...
    kafka:
      # ...
      rack:
        topologyKey: topology.kubernetes.io/zone
      # ...
```

## Creating topics for multizone setup

It is important that you do not [configure topics](../../administering/managing-multizone/#topic-configuration) where the minimum in-sync replicas setting cannot be met in the event of a zone failure.

**Warning:** Do not create a topic with 1 replica. Setting 1 replica means the topic will become unavailable during an outage, which means it loses data.

In this tutorial, we create a topic with 6 replicas, setting the minimum in-sync replicas configuration to 4. This means if a zone is lost, 2 brokers would be lost and therefore 2 replicas.

The minimum in-sync replicas would still mean the system remains operational with no data loss, as 4 brokers still remain, with four replicas of the topics data.
