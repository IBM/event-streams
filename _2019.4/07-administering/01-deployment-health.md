---
title: "Monitoring deployment health"
excerpt: "Understand the health of your deployment at a glance, and learn how to find information about problems."
categories: administering
slug: deployment-health
toc: true
---

Understand the health of your {{site.data.reuse.long_name}} deployment at a glance, and learn how to find information about problems.

## Using the UI

The {{site.data.reuse.long_name}} UI provides information about the health of your environment at a glance. In the bottom right corner of the UI, a message shows a summary status of the system health. If there are no issues, the message states **System is healthy**.

If any of the {{site.data.reuse.long_name}} resources experience problems, the message states **component isn't ready**.

To find out more about the problem:

1. Click the message to expand it, and then expand the section for the component that does not have a green tick next to it.\\
   ![Example system health](../../images/component-not-ready_201941.png "Example screen capture showing when a component is not ready, stating "Pod 2 is not ready" as a link."){:height="50%" width="50%"}
2. Click the **Pod is not ready** link to open more details about the problem. The link opens the {{site.data.reuse.icp}} UI. Log in as an administrator.
3. To understand why the {{site.data.reuse.long_name}} resource is not available, click the **Events** tab to view details about the cause of the problem.
4. For more detailed information about the problem, click the **Overview** tab, and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > View logs** on the right in the **Pod details** panel.
5. For guidance on resolving common problems that might occur, see the [troubleshooting section](../../troubleshooting/intro/).

## Using the CLI

You can check the health of your {{site.data.reuse.long_name}} environment using the Kubernetes CLI.

1. Ensure you have the [Kubernetes command line tool installed](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/cfc_cli.html){:target="_blank"}, and configure access to your cluster.
2. To check the status and readiness of the pods, run the following command, where `<namespace>` is the space used for your {{site.data.reuse.long_name}} installation:\\
   `kubectl -n <namespace> get pods`\\
   The command lists the pods together with simple status information for each pod.
3. To retrieve further details about the pods, including events affecting them, use the following command:\\
   `kubectl -n <namespace> describe pod <pod-name>`
4. To retrieve detailed log data for a pod to help analyze problems, use the following command:\\
   `kubectl -n <namespace> logs <pod-name> -c <container_name>`

For more information about using the `kubectl` command for debugging, see the [Kubernetes documentation](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application-introspection/#using-kubectl-describe-pod-to-fetch-details-about-pod){:target="_blank"}.

**Note:** After a component restarts, the `kubectl` command retrieves the logs for the new instance of the container. To retrieve the logs for a previous instance of the container, add the `–previous` option to the `kubectl logs` command.

**Tip:** You can also use the [management logging service, or Elastic Stack](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_metrics/logging_elk.html){:target="_blank"}, deployed by {{site.data.reuse.icp}} to find more log information. Setting up the built-in Elastic Stack is part of the [installation planning tasks](../../installing/planning/#logging).
