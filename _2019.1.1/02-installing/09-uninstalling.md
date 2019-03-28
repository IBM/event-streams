---
title: "Uninstalling"
excerpt: "Uninstalling Event Streams."
categories: installing
slug: uninstalling
toc: true
---

You can uninstall {{site.data.reuse.long_name}} by using the UI or the CLI.

## Using the UI

To delete the {{site.data.reuse.short_name}} installation by using the UI:

1. Log in to the {{site.data.reuse.short_name}} UI as an administrator.
2. Click **Workloads > Helm Releases** from the navigation menu.
3. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Delete** in the corresponding row.
4. Optional: If you enabled persistence during installation, you also need to manually remove  [PersistentVolumes](https://www-03preprod.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/delete_volume.html){:target="_blank"} and [PersistentVolumeClaims](https://www-03preprod.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/delete_app_volume.html){:target="_blank"}.


## Using the CLI

Delete the {{site.data.reuse.short_name}} installation by using the CLI:

1. {{site.data.reuse.icp_cli_login}}
2. Run the following command:\\
   `helm delete --purge <release_name>`
3. Optional: If you enabled persistence during installation, you also need to manually remove PersistentVolumeClaims and PersistentVolumes. Use the Kubernetes command line tool as follows:
    1. To delete PersistentVolumeClaims:\\
       `kubectl delete pvc <PVC_name> -n <namespace>`
    2. To delete PersistentVolumes:\\
       `kubectl delete pv <PV_name>`

## Cleaning up after uninstallation

The uninstallation process might leave behind artifacts that you have to [clear manually](../../troubleshooting/cleanup-uninstall/).
