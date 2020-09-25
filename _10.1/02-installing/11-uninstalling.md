---
title: "Uninstalling"
excerpt: "Uninstalling Event Streams."
categories: installing
slug: uninstalling
toc: true
---

You can remove an {{site.data.reuse.short_name}} instance by using the `oc` utility or the {{site.data.reuse.openshift_short}} web console.
You can also remove the {{site.data.reuse.short_name}} operator itself.


## Uninstalling an {{site.data.reuse.short_name}} instance

### Uninstalling using the {{site.data.reuse.openshift_short}} web console
To delete an {{site.data.reuse.short_name}} instance:

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. In the **Operator Details** panel, select the **Event Streams** tab to show the  {{site.data.reuse.short_name}} instances in the selected namespace.
5. Click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the instance to be deleted to open the actions menu.
6. Click the **Delete EventStreams** menu option to open the confirmation panel.
7. Check the namespace and instance name and click **Delete** to shutdown the associated pods and delete the instance.

#### Check uninstallation progress
1. {{site.data.reuse.openshift_ui_login}}
2. Expand the **Workloads** dropdown and select **Pods** to open the **Pods** dashboard.
3. Click **Select All Filters** to display pods in any state.
4. Enter the name of the {{site.data.reuse.short_name}} instance being deleted in the **Filter by name** box.
5. Wait for all the {{site.data.reuse.short_name}} pods to be displayed as **Terminating** and then be removed from the list.

#### Removing persistence resources
If you had enabled persistence for the {{site.data.reuse.short_name}} instance but set the `deleteClaim` storage property to `false`, you will need to manually remove the associated Persistent Volumes (PVs) and Persistent Volume Claims (PVCs) that were created at installation time.

The `deleteClaim` property is configured in the `EventStreams` custom resource and can be set to `true` during installation to ensure the PVs and PVCs are automatically removed when the instance is deleted.

For Kafka and ZooKeeper, this property can be found as follows:
 - `spec.strimziOverrides.kafka.storage.deleteClaim`
 - `spec.strimziOverrides.zookeeper.storage.deleteClaim`

For other components, this property can be found as follows:
- `spec.<component_name>.storage.deleteClaim`

**Important:** This change will cause data to be removed during an upgrade. 

For example, to configure automatic deletion for the Kafka storage when uninstalling:

```
apiVersion: eventstreams.ibm.com/v1beta1
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


### Uninstalling using the CLI

You can delete an {{site.data.reuse.short_name}} installation using the `oc` command line tool:

1. {{site.data.reuse.openshift_cli_login}}
2. Ensure you are using the project where your {{site.data.reuse.short_name}} instance is located:
`oc project <project_name>`
2. Run the following command to display the {{site.data.reuse.short_name}} instances:
`oc get es`
4. Run the following command to delete your instance:
`oc delete es --selector app.kubernetes.io/instance=<instance_name>`

#### Check uninstallation progress
Run the following command to check the progress:
`oc get pods --selector app.kubernetes.io/instance=<instance_name>`

Pods will initially display a **STATUS** `Terminating` and then be removed from the output as they are deleted.

```
$ oc get pods --selector app.kubernetes.io/instance=minimal-prod
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

#### Removing persistence resources
If you had enabled persistence for the {{site.data.reuse.short_name}} instance but set the `deleteClaim` storage property to `false`, you will need to manually remove the associated Persistent Volumes (PVs) and Persistent Volume Claims (PVCs) that were created at installation time.

The `deleteClaim` property is configured in the `EventStreams` custom resource and can be set to `true` during installation to ensure the PVs and PVCs are automatically removed when the instance is deleted.

For Kafka and ZooKeeper, this property can be found as follows:
 - `spec.strimziOverrides.kafka.storage.deleteClaim`
 - `spec.strimziOverrides.zookeeper.storage.deleteClaim`

For other components, this property can be found as follows:
- `spec.<component_name>.storage.deleteClaim`

**Important:** This change will cause data to be removed during an upgrade. 

For example, to configure automatic deletion for the Kafka storage when uninstalling:

```
apiVersion: eventstreams.ibm.com/v1beta1
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

Delete the PVCs:

1. Run the following command to list the remaining PVCs associated with the deleted instance:
`oc get pvc --selector app.kubernetes.io/instance=<instance_name>`

2. Run the following to delete a PVC:
`oc delete pvc <pvc_name>`

Delete remaining PVs:
1. Run the following command to list the remaining PVs:
`oc get pv`
2. Run the following command to delete any PVs that were listed in the **Volume** column of the deleted PVCs.
`oc delete pv <pv_name>`

**Note:** Take extreme care to select the correct PV name to ensure you do not delete storage associated with a different application instance.


## Uninstalling an {{site.data.reuse.short_name}} operator
To delete an {{site.data.reuse.short_name}} operator:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Operators** and click **Installed Operators**.
3. In the **Project** dropdown select the required namespace. For cluster-wide operators, select the `openshift-operators` project.
6. Click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the {{site.data.reuse.long_name}} operator to be deleted to open the actions menu.
7. Click the **Uninstall Operator** menu option to open the confirmation panel.
8. Check the namespace and operator name, then click **Remove** to uninstall the operator.

## Removing {{site.data.reuse.short_name}} Custom Resoure Definitions
The {{site.data.reuse.short_name}} Custom Resource Definitions (CRDs) are not deleted automatically. You must manually delete any CRDs that you do not want:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Administration** and click **Custom Resource Definitions**.
3. Enter `eventstreams` in the **Filter by name** box to filter the CRDs associated with {{site.data.reuse.short_name}}.
4. Click ![More options icon](../../images/more_options.png "More options icon at end of each row."){:height="30px" width="15px"} **More options** next to the CRD to be deleted to open the actions menu.
5. Click the **Delete Custom Resource Definition** menu option to open the confirmation panel.
6. Check the name of the CRD and click **Delete** to remove the CRD.


## Uninstalling {{site.data.reuse.icpcs}}
For information about uninstalling {{site.data.reuse.icpcs}} see the {{site.data.reuse.icpcs}} [documentation](https://www.ibm.com/support/knowledgecenter/en/SSHKN6/installer/3.x.x/uninstallation.html){:target="_blank"}.