---
title: "Uninstalling"
permalink: /installing/uninstalling/
excerpt: "Uninstalling {{site.data.reuse.long_name}}."
last_modified_at: 
toc: true
---

You can uninstall {{site.data.reuse.long_name}} by using the UI or the CLI.

## Using the UI

To delete the {{site.data.reuse.ce_short}} installation by using the UI:

1. Log in to the {{site.data.reuse.long_name}} UI as an administrator.
2. Click **Workloads > Helm Releases** from the navigation menu.
3. Locate the release name of your installation in the **Name** column, and click **Menu overflow > Delete** in the corresponding row.
4. Optional: If you enabled persistence during installation, you also need to manually remove  [PersistentVolumes](https://www-03preprod.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/delete_volume.html) and [PersistentVolumeClaims](https://www-03preprod.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/delete_app_volume.html).


## Using the CLI

Delete the {{site.data.reuse.ce_short}} installation by using the CLI:

1. {{site.data.reuse.icp_cli_login}}
2. Run the following command:\\
   `helm delete --purge <release_name>`
3. Optional: If you enabled persistence during installation, you also need to manually remove PersistentVolumeClaims and PersistentVolumes. Use the Kubernetes command line tool as follows:
    1. To delete PersistentVolumeClaims:\\
       `kubectl delete pvc <PVC_name> -n <namespace>`
    2. To delete PersistentVolumes:\\
       `kubectl delete pv <PV_name>`
