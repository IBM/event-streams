---
title: "The UI cannot load data"
excerpt: "test"
categories: troubleshooting
slug: problem-with-piping
toc: true
---

## Symptoms

When using the {{site.data.reuse.long_name}} UI, the **Monitor** and the **Topics > Producers** tabs do not load, displaying the following message:

![Problem with piping message.](../../images/pipe_broken.png "Screen capture showing message Uh oh. There's a problem with the piping. We can't load this data.")

## Causes

The {{site.data.reuse.icp}} monitoring service might not be installed. In general, the monitoring service is installed by default during the  {{site.data.reuse.icp}} installation. However, some deployment methods do not install the service.

## Resolving the problem

Install the {{site.data.reuse.icp}} monitoring service from the [Catalog or CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_metrics/monitoring_service.html#install_monitsrv){:target="_blank"}.
