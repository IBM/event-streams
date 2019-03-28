---
title: "Kafka client applications are unable to connect to the cluster. Users are unable to login to the UI."
excerpt: "Client applications are unable to produce or consume messages, connection errors are reported. Users are unable to login to the UI."
categories: troubleshooting
slug: client-connect-error
toc: true
---

## Symptoms
Client applications are unable to produce or consume messages. The logs for producer and consumer applications contain the following error message:

```
org.apache.kafka.common.config.ConfigException: No resolvable bootstrap urls given in bootstrap.servers
```

The {{site.data.reuse.short_name}} UI reports the following error:

```
CWOAU0062E: The OAuth service provider could not redirect the request because the redirect URI was not valid. Contact your system administrator to resolve the problem.
```

## Causes
An invalid host name or IP address was specified in the `External access settings` when configuring the [installation](../../installing/configuring/#configuring-external-access).

## Resolving the problem
You need to reinstall {{site.data.reuse.short_name}} and supply the correct external host name or IP address.
