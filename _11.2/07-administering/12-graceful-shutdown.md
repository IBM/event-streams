---
title: "Stopping and starting Event Streams"
excerpt: "Find out how to gracefully shut down an Event Streams instance, for example, in preparation for maintenance."
categories: administering
slug: stopping-starting
toc: true
---

You can stop or shut down your {{site.data.reuse.short_name}} instance if required.
You might want to do this in cases of hardware maintenance or during scheduled power outages.

Use the following instructions to gracefully shut down your {{site.data.reuse.short_name}} instance. The instance can be started again following the [starting up {{site.data.reuse.short_name}}](#starting-up-event-streams) instructions.

## Stopping {{site.data.reuse.short_name}}

To shut down your cluster gracefully, follow these steps: 
1. Enable `StrimziPodSetOnlyReconciliation` mode 
2. Scale down components
3. Uninstall the operator

### Enabling StrimziPodSetOnlyReconciliation mode in {{site.data.reuse.short_name}} operator

Running the operator in this mode ensures that your {{site.data.reuse.short_name}} instance is no longer managed by the `EventStreams` operator. However, the operator still continues to reconcile the `StrimziPodSets` resources, which can be used to scale down Kafka and Zookeeper pods.

#### Using the Kubernetes command-line tool (`kubectl`)

1. To enable the `StrimziPodSetOnlyReconciliation` mode, follow these steps: 

   **Note:** This command requires the [`yq` YAML](https://github.com/mikefarah/yq){:target="_blank"} parsing and editing tool.
   - If you are running on the {{site.data.reuse.openshift_short}}, run the following command to update the `ClusterServiceVersion` of the `EventStreams` operator:

      ```shell
      kubectl get csv -n <namespace> ibm-eventstreams.v<operator_version> -oyaml | yq e "(.spec.install.spec.deployments[0].spec.template.spec.containers[0].env[] | select(.name==\"STRIMZI_POD_SET_RECONCILIATION_ONLY\")) .value=\"true\"" | kubectl apply -f -
      ```

   - If you are running on other Kubernetes platforms, run the following command to update the deployment resource of the `EventStreams` operator:

      ```shell
      kubectl get deploy -n <namespace> eventstreams-cluster-operator -oyaml | yq e "(.spec.template.spec.containers[0].env[] | select(.name==\"STRIMZI_POD_SET_RECONCILIATION_ONLY\")) .value=\"true\"" | kubectl apply -f -
      ```

   Where `<namespace>` is the namespace your `EventStreams` operator is installed in and `<operator_version>` is the version of the operator that is installed.
2. Wait for the operator pod to reconcile. This is indicated by the `Running` state. You can watch the progress by running the following command:

   `kubectl get pods -n <namespace> --watch`

   Where `<namespace>` is the namespace your `EventStreams` operator is installed in.

#### Using the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. Navigate to the `ClusterServiceVersion` yaml of the `EventStreams` operator.
5. Set the following environment variable under `spec.install.spec.deployments[0].spec.template.spec.containers[0].env[]` to `true`:
   
   ```yaml
            -  name: STRIMZI_POD_SET_RECONCILIATION_ONLY
               value: 'true'
   ```
6. Wait for all {{site.data.reuse.short_name}} pods to reconcile. This is indicated by the `Running` state. You can watch the progress by running the following command:

   `kubectl get pods -n <namespace> --watch`

   Where `<namespace>` is the namespace your `EventStreams` operator is installed in.

### Scale down components

After starting the operator in `StrimziPodSetOnlyReconciliation` mode, you can safely scale down all components to `0` replicas, ensuring no pods are running.

To do this for all components of type `Deployment`, run:

```shell
kubectl get deployments -n <namespace> -l app.kubernetes.io/instance=<instance-name> -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas --no-headers > deployment.txt && while read -ra deploy; do kubectl -n <namespace> scale --replicas=0 deployment/${deploy}; done < deployment.txt
```

Where `<namespace>` is the namespace your {{site.data.reuse.short_name}} instance is installed in and `<instance-name>` is the name of your {{site.data.reuse.short_name}} instance.

**Note:** This saves the state of your deployments to a file called `deployment.txt` in the current working directory.

To scale down all components of type `StrimziPodSet`, run the following command to delete the `spec.pods` configuration in the `StrimziPodSet` resources:

```shell
kubectl patch -n <namespace> `kubectl get sps -n <namespace> -o name` --type json -p '[{"op":"replace","path":"/spec/pods","value":[]}]'
```

Where `<namespace>` is the namespace your {{site.data.reuse.short_name}} instance is installed in.  

### Uninstall the operator

Select your platform to see the instructions for:

- Uninstalling {{site.data.reuse.short_name}} operator on [{{site.data.reuse.openshift_short}}](../../installing/uninstalling/#uninstalling-an-event-streams-operator-on-openshift-container-platform).
- Uninstalling {{site.data.reuse.short_name}} operator on other [Kubernetes platforms](../../installing/uninstalling/#uninstalling-an-event-streams-operator-on-other-kubernetes-platforms).

## Starting up {{site.data.reuse.short_name}}

To scale the {{site.data.reuse.short_name}} instance back up to the original state, install the {{site.data.reuse.short_name}} operator again following the steps in the [installing]({{ 'installpagedivert' | relative_url }}) section.

1. Install the operator, ensuring it is configured with the same [installation mode]({{ 'installpagedivert' | relative_url }}) as used for the previous installation to manage the instances of {{site.data.reuse.short_name}} in **any namespace** or a **single namespace**.
2. Wait for the operator to scale all resources back up to their original state. You can watch the progress by running:
   `kubectl get pods --watch`
