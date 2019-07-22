---
title: "Diagnosing installation issues"
excerpt: "To help troubleshoot installation issues, you can run diagnostics scripts."
categories: troubleshooting
slug: diagnosing-installation-issues
toc: false
---

To help troubleshoot and resolve installation issues, you can run a diagnostic script that checks your deployment for potential problems.

**Important:** Do not use the script before the installation process completes. Despite a successful installation message, some processes might still need to complete, and it can take up to 10 minutes before {{site.data.reuse.long_name}} is available to use.

To run the script:

1. Download the `installation-diagnostic-script.sh` script from [GitHub](https://github.com/IBM/event-streams/tree/master/support){:target="_blank"}.
2. Ensure you have installed the Kubernetes command line tool and the {{site.data.reuse.icp}} CLI as noted in the [installation prerequisites](../../installing/prerequisites/).
3. {{site.data.reuse.icp_cli_login}}
4. Run the script as follows:\\
    `./installation-diagnostic-script.sh -n <namespace> -r <release-name>`

If you have been waiting for more than an hour, add the `--restartoldpods` option to recreate lost events (by default, events are deleted after an hour). This option restarts **Failed** or **Pending** pods that are an hour old or more.

For example, the following installation has pods that are in pending state, and running the diagnostic script reveals that the issue is caused by not having sufficient memory and CPU resources available to the pods:

```
Starting release diagnostics...
Checking kafka-sts pods...
kafka-sts pods found
Checking zookeeper-sts pods...
zookeeper-sts pods found
Checking the ibm-es-iam-secret API Key...
API Key found
Checking for Pending pods...
Pending pods found, checking pod for failed events...
------------------
Name: caesar-ibm-es-kafka-sts-0
Type: Pod
FirstSeen: 2m
LastSeen: 1m
Issue: 0/4 nodes are available: 1 Insufficient memory, 4 Insufficient cpu.
------------------
Name: caesar-ibm-es-kafka-sts-1
Type: Pod
FirstSeen: 2m
LastSeen: 1m
Issue: 0/4 nodes are available: 1 Insufficient memory, 4 Insufficient cpu.
------------------
Name: caesar-ibm-es-kafka-sts-2
Type: Pod
FirstSeen: 2m
LastSeen: 1m
Issue: 0/4 nodes are available: 1 Insufficient memory, 4 Insufficient cpu.
------------------
No failed events found for pod caesar-ibm-es-rest-deploy-6ff498d779-stf79
------------------
Checking for CrashLoopBackOff pods...
No CrashLoopBackOff pods found
Release diagnostics complete. Please review output to identify potential problems.
If unable to identify or fix problems, please contact support.
```
