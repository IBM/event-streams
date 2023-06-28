---
title: "Preparing for multizone clusters"
excerpt: "Prepare for installing your Event Streams on multizone clusters."
categories: installing
slug: preparing-multizone
layout: redirects
toc: true
---

{{site.data.reuse.long_name}} supports [multiple availability zones](../planning/#multiple-availability-zones) for your clusters. Multizone clusters add resilience to your {{site.data.reuse.short_name}} installation.

For guidance about handling outages in a multizone setup, see [managing a multizone setup](../../administering/managing-multizone/).

## Zone awareness

Kubernetes uses zone-aware information to determine the zone location of each of its nodes in the cluster to enable scheduling of pod replicas in different zones.

Some clusters, typically AWS, will already be zone aware. For clusters that are not zone aware, each Kubernetes node will need to be set up with a zone label.

To determine if your cluster is zone aware:

1. {{site.data.reuse.cncf_cli_login}}
2. Run the following command:

   `kubectl get nodes --show-labels`

If your Kubernetes cluster is zone aware, the [label](https://kubernetes.io/docs/reference/kubernetes-api/labels-annotations-taints/){:target="_blank"} `topology.kubernetes.io/zone` is displayed against each node.
 
The value of the label is the zone the node is in, for example, `es-zone-1`.

If your Kubernetes cluster is not zone aware, all cluster nodes will need to be labeled using a value that identifies the zone that each node is in. For example, run the following command to label and allocate a node to `es-zone-1`:

   `kubectl label node <node-name> topology.kubernetes.io/zone=es-zone-1`

The zone label is needed to set up rack awareness when [installing for multizone](../configuring/#applying-kafka-rack-awareness).


## Kafka rack awareness

In addition to zone awareness, Kafka rack awareness helps to spread the Kafka broker pods and Kafka topic replicas across different availability zones, and also sets the brokers' `broker.rack` configuration property for each Kafka broker.

To set up Kafka rack awareness, Kafka brokers require a cluster role to provide permission to view which Kubernetes node they are running on.

Before applying [Kafka rack awareness](../configuring/#applying-kafka-rack-awareness) to an {{site.data.reuse.short_name}} installation, apply a cluster role and a cluster role binding:

1. Create a file called `eventstreams-kafka-broker.yaml` and copy the following YAML content to create the cluster role:

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
2. Apply the cluster role by using the following command:

   `kubectl apply -f eventstreams-kafka-broker.yaml`

3. Create a file called `eventstreams-kafka-broker-crb.yaml` and copy the following YAML content to create the cluster role binding:

   ```
   kind: ClusterRoleBinding
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: eventstreams-kafka-broker
   subjects:
   - kind: ServiceAccount
     name: eventstreams-cluster-operator
     namespace: <operator_namespace>
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: eventstreams-kafka-broker
   ```

4. Apply the cluster role  binding by using the following command:

   `kubectl apply -f eventstreams-kafka-broker-crb.yaml`
