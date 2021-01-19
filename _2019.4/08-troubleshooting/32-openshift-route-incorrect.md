---
title: "Kafka cluster is not accessible by using OpenShift routes"
excerpt: "Kafka clients cannot connect to the cluster by using the OpenShift route created by the Event Streams installation."
categories: troubleshooting
slug: openshift-route-incorrect
toc: true
---

## Symptoms
If {{site.data.reuse.short_name}} is installed on {{site.data.reuse.openshift}}, Kafka clients receive timeout errors when trying to connect to the instance by using the address provided in the {{site.data.reuse.short_name}} UI and CLI. The following is an example error message:

```
org.apache.kafka.common.errors.TimeoutException: Topic <topicName> not present in metadata after 60000 ms
```

## Causes
{{site.data.reuse.short_name}} deploys {{site.data.reuse.openshift_short}} routes. When the hostname of the {{site.data.reuse.openshift_short}} cluster is too long, the generated route addresses are truncated. This causes incorrect routing of the connection within {{site.data.reuse.short_name}}.

The following table provides an example. The output of the `oc get routes` command shows that the `NAME` of the route is not the same as the prefix for the `HOST/PORT` address.

|NAME|                                           HOST/PORT|                                                                                                                                                       PATH  | SERVICES|                                         PORT |                   TERMINATION |       WILDCARD|
|---|---|---|---|---|---|--|
|\<releaseName\>-ibm-es-proxy-route-bootstrap   |<truncated>-ibm-es-proxy-route-bootstrap-eventstream-persistence.<a-very-long-hostname>       ||        \<releaseName\>-ibm-es-proxy-svc   |              bootstrap   |            passthrough/None |  None|
|\<releaseName\>-ibm-es-proxy-route-broker-0  |  <truncated>-ibm-es-proxy-route-broker-0-eventstream-persistence.<a-very-long-hostname>     ||            \<releaseName\>-ibm-es-proxy-svc       |         brk0-external   |        passthrough/None   |None|
|\<releaseName\>-ibm-es-proxy-route-broker-1 |   <truncated>-ibm-es-proxy-route-broker-1-eventstream-persistence.<a-very-long-hostname>          ||       \<releaseName\>-ibm-es-proxy-svc    |             brk1-external     |      passthrough/None  | None|
|\<releaseName\>-ibm-es-proxy-route-broker-2 |   <truncated>-ibm-es-proxy-route-broker-2-eventstream-persistence.<a-very-long-hostname>         ||        \<releaseName\>-ibm-es-proxy-svc       |          brk2-external     |      passthrough/None  | None|

## Resolving the problem
The issue is resolved in {{site.data.reuse.short_name}} 10.0 and later versions.

The workaround for 2019.4 versions is as follows:

1. Edit the ConfigMap `<releaseName>-ibm-es-proxy-cm`, for example:

   `oc edit cm <releaseName>-ibm-es-proxy-cm -n <namespace>`

2. Change `bootstrapRoutePrefix` from `<releaseName>-ibm-es-proxy-route-bootstrap` to `<truncatedAddress>-ibm-es-proxy-route-bootstrap`
3. Change `brokerRoutePrefix` from `<releaseName>-ibm-es-proxy-route-broker-` to `<truncatedAddress>-ibm-es-proxy-route-broker-`

   **Important:** The trailing hyphen at the end is required.

4. Remove the `externalListeners` entry from the map.
5. Increase the `revision` value by `1`.
6. Save the changes to the ConfigMap.
