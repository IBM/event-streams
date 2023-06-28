---
title: "Rolling back"
excerpt: "Revert to a previous version of Event Streams."
categories: installing
slug: rolling-back
layout: redirects
toc: true
---

You can revert to an earlier version of {{site.data.reuse.short_name}} under certain conditions.

<!--"rollback", or "roll back", or use a phrase such as "revert to an earlier version".-->

## Prerequisites

Rolling back your {{site.data.reuse.short_name}} 2019.4.1 installation to an earlier version is only supported in the following cases:

- You can only roll back from a newer Helm chart version to an older chart version.
- You can only roll back to {{site.data.reuse.short_name}} 2019.2.1 (Helm chart version 1.3.0). Rolling back to earlier chart versions is not supported.
- Rolling back to an earlier {{site.data.reuse.short_name}} version is only supported if you have not [modified your settings](../../administering/modifying-installation/) after deployment.

## Rolling back

### Using the UI

1. {{site.data.reuse.icp_ui_login321}}
3. Click **Workloads > Helm Releases** from the navigation menu.
4. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Rollback** in the corresponding row.
5. Select the chart version to roll back to (1.3.0).
6. Click **Rollback**.

### Using the CLI

1. {{site.data.reuse.icp_cli_login321}}\\
   **Important:** You must have the Cluster Administrator role to roll back a chart version.
2. Run the `helm history` command to view previous versions you can roll back to:\\
   `helm history <release-name>`\\
   Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.\\
   For example:\\
   ```
$ helm history event-streams
REVISION        UPDATED                         STATUS          CHART                           DESCRIPTION
1               Mon Dec 17 14:27:12 2018        SUPERSEDED      ibm-eventstreams-prod-1.1.0     Install complete
2               Wed Apr 10 16:49:29 2018        SUPERSEDED      ibm-eventstreams-prod-1.2.0     Upgrade complete
3               Mon Jul 15 12:16:34 2019        SUPERSEDED      ibm-eventstreams-prod-1.3.0     Upgrade complete
4               Wed Oct 23 16:16:34 2019        DEPLOYED        ibm-eventstreams-prod-1.4.0     Upgrade complete
   ```
3. Run the `helm rollback` command as follows:\\
   `helm rollback <release-name> <revision>`\\
   Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation, and `<revision>` is a number from the `REVISION` column that corresponds to the version you want to revert to, as displayed in the result of the `helm history` command.\\
   For example:\\
   `helm rollback event-streams 3`

## Post-rollback tasks

Rolling back to version 2019.2.1 deletes the `restProxyExternalPort` value from the release ConfigMap, which means you will not be able to access the UI or use  the schema registry feature. Use the following `kubectl patch` command to fix this issue.

1. {{site.data.reuse.icp_cli_login321}}
2. Retrieve the `restProxyExternalPort` value as follows:\\
   `kubectl get svc $(kubectl get svc -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep rest-proxy-external) -o jsonpath='{range .spec.ports[?(@.name=="admin-rest-https")]}{.nodePort}{"\n"}{end}'`
3. Run the following command:\\
   `kubectl patch configmap <release-name>-ibm-es-release-cm -n <namespace> --type='json' -p='[{"op": "add", "path": "/data/restProxyExternalPort", "value": "<restProxyExternalPort>"}]'`

   Where:
   - `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.
   - `<namespace>` is the location of your installation.
   - `<restProxyExternalPort>` is the port you retrieved in the previous step.
