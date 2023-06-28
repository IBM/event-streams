---
title: "Uninstalling"
excerpt: "Uninstalling Event Streams."
categories: installing
slug: uninstalling
layout: redirects
toc: true
---

You can remove the {{site.data.reuse.short_name}} from your platform as follows:


## Uninstalling an {{site.data.reuse.short_name}} instance by using the CLI
You can delete an {{site.data.reuse.short_name}} installation using the Kubernetes command-line tool (`kubectl`):

1. {{site.data.reuse.cncf_cli_login}}
2. Ensure you are using the namespace where your {{site.data.reuse.short_name}} instance is located: 

   `kubectl config set-context --current --namespace=<insert-namespace-name-here>`
3. Run the following command to display the {{site.data.reuse.short_name}} instances: 

   `kubectl get eventstreams -n <namespace>`
4. Run the following command to delete your instance:
  
   `kubectl delete eventstreams <instance-name> -n <namespace>`

### Check uninstallation progress
Run the following command to check the progress:
  
  `kubectl get pods --selector app.kubernetes.io/instance=<instance_name>`

Pods will initially display a **STATUS** `Terminating` and then be removed from the output as they are deleted.

```
$ kubectl get pods --selector app.kubernetes.io/instance=minimal-prod
>
NAME                                            READY     STATUS        RESTARTS   AGE
minimal-prod-entity-operator-77dfff7c79-cnrx5   0/2       Terminating   0          5h35m
minimal-prod-ibm-es-admapi-b49f976c9-xhsrv      0/1       Terminating   0          5h35m
minimal-prod-ibm-es-recapi-6f6bd784fc-jvf9z     0/1       Terminating   0          5h35m
minimal-prod-ibm-es-ac-reg-6dffdb54f9-dfdpl     0/3       Terminating   0          5h35m
minimal-prod-ibm-es-ui-5dd7496dbc-qks7m         0/2       Terminating   0          5h35m
minimal-prod-kafka-0                            2/2       Terminating   0          5h36m
minimal-prod-zookeeper-0                        0/2       Terminating   0          5h37m
```

### Removing persistence resources
If you had enabled persistence for the {{site.data.reuse.short_name}} instance but set the `deleteClaim` storage property to `false`, you will need to manually remove the associated Persistent Volumes (PVs) and Persistent Volume Claims (PVCs) that were created at installation time.

The `deleteClaim` property is configured in the `EventStreams` custom resource and can be set to `true` during installation to ensure the PVs and PVCs are automatically removed when the instance is deleted.

For Kafka and ZooKeeper, this property can be found as follows:
 - `spec.strimziOverrides.kafka.storage.deleteClaim`
 - `spec.strimziOverrides.zookeeper.storage.deleteClaim`

For other components, this property can be found as follows:
- `spec.<component_name>.storage.deleteClaim`

**Important:** This change will cause data to be removed during an upgrade.

For example, to configure automatic deletion for the Kafka storage when uninstalling:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
...
spec:
  ...
  strimziOverrides:
    ...
    kafka:
      ...
      storage:
        type: persistent-claim
        ...
        deleteClaim: true
```

To remove any remaining storage, delete the PVCs first then delete any remaining PVs.

Delete the Persistent Volume Claims (PVCs):

1. Run the following command to list the remaining PVCs associated with the deleted instance:
  
   `kubectl get pvc --selector app.kubernetes.io/instance=<instance_name>`
2. Run the following to delete a PVC:
  
   `kubectl delete pvc <pvc_name>`

Delete remaining Persistent Volumes (PVs):

1. Run the following command to list the remaining PVs:

   `kubectl get pv`
2. Run the following command to delete any PVs that were listed in the **Volume** column of the deleted PVCs.
  
   `kubectl delete pv <pv_name>`

**Note:** Take extreme care to select the correct PV name to ensure you do not delete storage associated with a different application instance.


## Uninstalling an {{site.data.reuse.short_name}} instance by using the OpenShift web console
To delete an {{site.data.reuse.short_name}} instance on {{site.data.reuse.openshift_short}}:

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. In the **Operator Details** panel, select the **Event Streams** tab to show the  {{site.data.reuse.short_name}} instances in the selected namespace.
5. Click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the instance to be deleted to open the actions menu.
6. Click the **Delete EventStreams** menu option to open the confirmation panel.
7. Check the namespace and instance name and click **Delete** to shutdown the associated pods and delete the instance.

### Check uninstallation progress
1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Workloads** dropdown and select **Pods** to open the **Pods** dashboard.
3. Click **Select All Filters** to display pods in any state.
4. Enter the name of the {{site.data.reuse.short_name}} instance being deleted in the **Filter by name** box.
5. Wait for all the {{site.data.reuse.short_name}} pods to be displayed as **Terminating** and then be removed from the list.

### Removing persistence resources
If you had enabled persistence for the {{site.data.reuse.short_name}} instance but set the `deleteClaim` storage property to `false`, you will need to manually remove the associated Persistent Volumes (PVs) and Persistent Volume Claims (PVCs) that were created at installation time.

The `deleteClaim` property is configured in the `EventStreams` custom resource and can be set to `true` during installation to ensure the PVs and PVCs are automatically removed when the instance is deleted.

For Kafka and ZooKeeper, this property can be found as follows:
 - `spec.strimziOverrides.kafka.storage.deleteClaim`
 - `spec.strimziOverrides.zookeeper.storage.deleteClaim`

For other components, this property can be found as follows:
- `spec.<component_name>.storage.deleteClaim`

**Important:** This change will cause data to be removed during an upgrade.

For example, to configure automatic deletion for the Kafka storage when uninstalling:

```yaml
apiVersion: eventstreams.ibm.com/v1beta2
kind: EventStreams
...
spec:
  ...
  strimziOverrides:
    ...
    kafka:
      ...
      storage:
        type: persistent-claim
        ...
        deleteClaim: true
```

To remove any remaining storage, delete the PVCs first then delete any remaining PVs.

Delete the Persistent Volume Claims (PVCs):

1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Storage** dropdown and select **Persistent Volume Claims** to open the **Persistent Volume Claims** page.
3. In the **Project** dropdown select the required namespace.
4. Click **Select All Filters** to display PVCs in any state.
5. Enter the name of the {{site.data.reuse.short_name}} instance in the **Filter by name** box.
6. For each PVC to be deleted, make a note of the **Persistent Volume** listed for that PVC and then click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** to open the actions menu.
7. Click the **Delete Persistent Volume Claim** menu option to open the confirmation panel.
8. Check the PVC name and namespace, then click **Delete** to remove the PVC.

Delete remaining Persistent Volumes (PVs):

1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Storage** dropdown and select **Persistent Volumes** to open the **Persistent Volumes** page.
3. In the **Project** dropdown select the required namespace.
4. For each PV you made a note of when deleting PVCs, click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** to open the actions menu.
5. Click the **Delete Persistent Volume** menu option to open the confirmation panel.
6. Check the PV name and click **Delete** to remove the PV.

**Note:** Take extreme care to select the correct PV name to ensure you do not delete storage associated with a different application instance.

## Uninstalling an {{site.data.reuse.short_name}} operator on {{site.data.reuse.openshift_short}}
To delete an {{site.data.reuse.short_name}} operator:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Operators** and click **Installed Operators**.
3. In the **Project** dropdown select the required namespace. For cluster-wide operators, select the `openshift-operators` project.
4. Click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the {{site.data.reuse.long_name}} operator to be deleted to open the actions menu.
5. Click the **Uninstall Operator** menu option to open the confirmation panel.
6. Check the namespace and operator name, then click **Remove** to uninstall the operator.

The {{site.data.reuse.short_name}} Custom Resource Definitions (CRDs) are not deleted automatically on {{site.data.reuse.openshift_short}}. You must manually delete any CRDs that you do not want:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Administration** and click **Custom Resource Definitions**.
3. Enter `eventstreams` in the **Filter by name** box to filter the CRDs associated with {{site.data.reuse.short_name}}.
4. Click ![More options icon]({{ 'images' | relative_url }}/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the CRD to be deleted to open the actions menu.
5. Click the **Delete Custom Resource Definition** menu option to open the confirmation panel.
6. Check the name of the CRD and click **Delete** to remove the CRD.


## Uninstalling an {{site.data.reuse.short_name}} operator on other Kubernetes platforms
To delete an {{site.data.reuse.short_name}} operator:

1. {{site.data.reuse.cncf_cli_login}}
2. Run the following command to select the namespace the operator is installed on:

   `kubectl config set-context --current --namespace=<operator-namespace-name-here>`
3. Run the following command to list the helm releases installed on that namespace: 
  
   `helm list`
4. Find the {{site.data.reuse.short_name}} operator release, it should have the chart as `ibm-eventstreams-operator-<version-number>`
5. Run the following command to uninstall the {{site.data.reuse.short_name}} operator and the {{site.data.reuse.short_name}} Custom Resoure Definitions (CRDs):
  
   `helm uninstall <release-name>`


## Uninstalling {{site.data.reuse.icpfs}} on OpenShift
If you have {{site.data.reuse.icpfs}}, see the [{{site.data.reuse.fs}} documentation](https://www.ibm.com/support/knowledgecenter/en/SSHKN6/installer/3.x.x/uninstallation.html){:target="_blank"} for information about uninstalling it.
