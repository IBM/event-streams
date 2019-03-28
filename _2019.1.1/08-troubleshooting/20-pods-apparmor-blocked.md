---
title: "Pods fail to start, status is blocked"
excerpt: "Pods fail to start, status is blocked."
categories: troubleshooting
slug: pods-apparmor-blocked
toc: true
---

## Symptoms

When installing {{site.data.reuse.short_name}} on {{site.data.reuse.icp}} 3.1.1 running on Red Hat Enterprise Linux, the following error message is displayed:

```
Error: timed out waiting for the condition
```

The installation might still complete, but {{site.data.reuse.short_name}} is not available. When you check the status of the pods by using the command `kubectl get pods`, they are showing as `blocked`:

```
NAME                                     READY     STATUS    RESTARTS   AGE
es1-kafka-ibm-es-secret-copy-job-zkgk8   0/1       Blocked   0          34s
es1-kafka-ibm-es-elastic-sts-0           0/1       Blocked   0          34s
es1-kafka-ibm-es-elastic-sts-1           0/1       Blocked   0          34s
es1-kafka-ibm-es-indexmgr-deploy-69-45   0/1       Blocked   0          34s
es1-kafka-ibm-es-kafka-sts-0             0/4       Blocked   0          34s
es1-kafka-ibm-es-kafka-sts-1             0/4       Blocked   0          34s
es1-kafka-ibm-es-kafka-sts-2             0/4       Blocked   0          34s
es1-kafka-ibm-es-proxy-deploy-56bb       0/1       Blocked   0          34s
es1-kafka-ibm-es-proxy-deploy-56bbc4     0/1       Blocked   0          34s
es1-kafka-ibm-es-rest-deploy-c76f46      0/3       Blocked   0          34s
es1-kafka-ibm-es-role-mappings-vjb8      0/1       Blocked   0          34s
es1-kafka-ibm-es-ui-deploy-575779998d    0/3       Blocked   0          34s
es1-kafka-ibm-es-zookeeper-sts-0         0/1       Blocked   0          34s
es1-kafka-ibm-es-zookeeper-sts-1         0/1       Blocked   0          34s
es1-kafka-ibm-es-zookeeper-sts-2         0/1       Blocked   0          34s
```

When you describe the pods for more information, the following error message is displayed:

```
Status:             Pending
Reason:             AppArmor
Message:            Cannot enforce AppArmor: AppArmor is not enabled on the host
```

For example, taking the first pod from the previous list and running `kubectl describe` provides the following message:

```
kubectl describe pod/es1-kafka-ibm-es-secret-copy-job-zkgk8 -n event-streams

Name:               es1-kafka-ibm-es-secret-copy-job-zkgk8
...
Annotations:        container.apparmor.security.beta.kubernetes.io/ips-copier=runtime/default
                    kubernetes.io/psp=ibm-restricted-psp
                    seccomp.security.alpha.kubernetes.io/pod=docker/default
Status:             Pending
Reason:             AppArmor
Message:            Cannot enforce AppArmor: AppArmor is not enabled on the host
IP:
Controlled By:      Job/es1-kafka-ibm-es-secret-copy-job
```

## Causes

Pods fail to start due to a setting in the `ibm-restricted-psp` PodSecurityPolicy that {{site.data.reuse.short_name}} uses to install.

The AppArmor strategy plug-in in the pod admission controller is injecting the AppArmor annotations into the pod, and the admission controller blocks the pod from starting.


## Resolving the problem

Upgrading to {{site.data.reuse.icp}} version 3.1.2 resolves the issue.

An alternative solution is to edit the `ibm-restricted-psp` PodSecurityPolicy by using the following command:

`kubectl edit PodSecurityPolicy ibm-restricted-psp`

Remove the following lines:

```
apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
```
