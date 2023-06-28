---
title: "Stopping and starting Event Streams"
excerpt: "Find out how to gracefully shut down an Event Streams instance, for example, in preparation for maintenance."
categories: administering
slug: stopping-starting
layout: redirects
toc: true
---

You can stop or shut down your {{site.data.reuse.short_name}} instance if required.
You might want to do this in cases of hardware maintenance or during scheduled power outages.

Use the following instructions to gracefully shut down your {{site.data.reuse.short_name}} instance. The instance can be started again following the [starting up {{site.data.reuse.short_name}}](#starting-up-event-streams) instructions.

## Stopping {{site.data.reuse.short_name}}

To shut down your cluster gracefully, uninstall the operator to ensure your {{site.data.reuse.short_name}} instance is no longer managed and scale all components to `0` replicas as follows:

### Stop the operator

To stop the operator on {{site.data.reuse.openshift_short}}:
1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. Select the **Actions** dropdown and click **Uninstall Operator**.

To stop the operator on other Kubernetes platforms:
1. {{site.data.reuse.cncf_cli_login}}
2. To uninstall the operator, run the following command:

   `helm uninstall <release-name>`

### Scale down components

After the operator has uninstalled, you can safely scale down all components to `0` replicas, ensuring no pods are running.

To do this for all components of type `Deployment`, run:

```
kubectl get deployments -n <namespace> -l app.kubernetes.io/instance=<instance-name> -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas --no-headers > deployment.txt && while read -ra deploy; do kubectl -n <namespace> scale --replicas=0 deployment/${deploy}; done < deployment.txt
```

Where `<namespace>` is the namespace your {{site.data.reuse.short_name}} instance is installed in and `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.

**Note:** This saves the state of your deployments to a file called `deployment.txt` in the current working directory.

To do this for all components of type `StatefulSet`, run:

```
kubectl get sts -n <namespace> -l app.kubernetes.io/instance=<instance-name> -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas --no-headers > sts.txt && while read -ra sts; do kubectl -n <namespace> scale --replicas=0 sts/${sts}; done < sts.txt
```

Where `<namespace>` is the namespace your {{site.data.reuse.short_name}} instance is installed in and `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.

**Note:** This saves the state of your stateful sets to a file called `sts.txt` in the current working directory.

## Starting up {{site.data.reuse.short_name}}

To scale the {{site.data.reuse.short_name}} instance back up to the original state, install the {{site.data.reuse.short_name}} operator again following the steps in the [installing]({{ 'installpagedivert' | relative_url }}) section.

1. Install the operator, ensuring it is configured with the same [installation mode]({{ 'installpagedivert' | relative_url }}) as used for the previous installation to manage the instances of {{site.data.reuse.short_name}} in **any namespace** or a **single namespace**.
2. Wait for the operator to scale all resources back up to their original state. You can watch the progress by running:
   `kubectl get pods --watch`
