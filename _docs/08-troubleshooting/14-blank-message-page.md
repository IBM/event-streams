---
title: "The Messages page is blank"
permalink: /troubleshooting/messages-page-blank/
excerpt: "The Messages page in the Event Streams UI is blank for both real and simulated topics."
last_modified_at:
toc: true
---

## Symptoms

When using the {{site.data.reuse.long_name}} UI, the **Messages** page loads, but then becomes blank when viewing any topic (either real or simulated).

## Causes

The `vm.max_map_count` property on one or more of your nodes is below the required value of `262144`. This causes the message indexing capabilities to fail, resulting in this behaviour.

## Resolving the problem

Ensure you set the `vm.max_map_count` property to at least `262144` on all {{site.data.reuse.icp}} nodes in your cluster (not only the master node). Run the following commands on each node: \\
    `sudo sysctl -w vm.max_map_count=262144`\\
    `echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf`\\
**Important:** This property might have already been updated by other workloads to be higher than the minimum required.
