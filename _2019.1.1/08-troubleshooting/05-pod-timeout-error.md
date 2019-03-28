---
title: "ConsumerTimeoutException when pods available"
excerpt: "Pods are available, but timeout error received."
categories: troubleshooting
slug: pod-timeout-error
toc: true
---

## Symptoms

Attempts to communicate with a pod results in timeout errors such as `kafka.consumer.ConsumerTimeoutException`.

## Causes

When querying the status of pods in the Kubernetes cluster, pods show as being in **Ready** state can still be in the process of starting up. This latency is a result of the external ports being active on the pods before the underlying services are ready to handle requests.

The period of this latency depends on the configured topology and performance characteristics of the system in use.

## Resolving the problem

Allow additional time for pod startup to complete before attempting to communicate with it.
