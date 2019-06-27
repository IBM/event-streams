---
title: "Redis latency due to Transparent Huge Pages"
excerpt: "Redis containers in the access controller and UI pods are suffering from latency due to Transparent Huge Pages being enabled in the Linux kernel."
categories: troubleshooting
slug: redis-latency-transparent-huge-pages
toc: true
---

## Symptoms

Redis containers in the access controller and UI pods output the following message in the logs:

```
WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
```

## Causes

The [Redis documentation](https://redis.io/topics/latency){:target="_blank"} states that having `Transparent Huge Pages` enabled in your Linux kernel can cause latency and high memory usage.

## Resolving the problem

If you are experiencing a latency problem with the access controller or UI, then disable `Transparent Huge Pages` by using the method recommended in the documentation for your host Linux distribution.
