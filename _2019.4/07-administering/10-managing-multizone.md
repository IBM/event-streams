---
title: "Managing a multizone setup"
excerpt: "Find out more about managing multizone clusters, including what to do in the event of a failure."
categories: administering
slug: managing-multizone
layout: redirects
toc: true
---

If you have set up your {{site.data.reuse.short_name}} installation to use [multiple availability zones](../../installing/preparing-multizone/), follow the guidance here if one of your nodes containing Kafka or ZooKeeper experiences problems.

## Topic configuration

Only create Kafka topics where the minimum in-sync replicas configuration can be met in the event of a zone failure. This requires considering the minimum in-sync replicas value in relation to the replication factor set for the topic, and the number of availability zones being used for spreading out your Kafka brokers.

For example, if you have 3 availability zones and 6 Kafka brokers, losing a zone means the loss of 2 brokers. In the event of such a zone failure, the following topic configurations will guarantee that you can continue to produce to and consume from your topics:

- If the replication factor is set to 6, then the suggested minimum in-sync replica is 4.
- If the replication factor is set to 5, then the suggested minimum in-sync replica is 3.

## Updating an existing installation

If you are changing an existing installation, such as adding new nodes, follow these steps to change the zone configuration.

For example, if one of your nodes containing Kafka or ZooKeeper pods fails, and it cannot be recovered, you can [label another node](../../installing/preparing-multizone/#setting-up-non-zone-aware-clusters) with that role label, and then the pod can be moved to the new node.

1. {{site.data.reuse.icp_cli_login321}}
2. Label the node according to your requirements. For example, if you want another Kafka broker, then label the node with the Kafka role and zone labels:\\
   `kubectl label node <node-name> node-role.kubernetes.io/kafka=true`
3. List the ConfigMaps in your {{site.data.reuse.short_name}} installation:\\
   `kubectl get configmaps -n <namespace>`
4. Look for the ConfigMap that has the suffix `zone-gen-job-cm`.
5. Download and save the configuration for the job stored in the ConfigMap:\\
   `kubectl get configmap <release-name>-ibm-zone-gen-job-cm -o jsonpath='{.data.job}' > zonegen.yml`
6. Run the following command to add the new node to your Kafka configuration:\\
   `kubectl create -f ./zonegen.yml`

When the new node role label is applied, Kubernetes schedules the failed Kafka or ZooKeeper to run on that node.
