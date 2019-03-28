---
title: "Rolling back"
excerpt: "Revert to a previous version of Event Streams."
categories: installing
slug: rolling-back
toc: true
---

You can revert to an earlier version of {{site.data.reuse.short_name}} under certain conditions.

<!--"rollback", or "roll back", or use a phrase such as "revert to an earlier version".-->

## Prerequisites

Rolling back your {{site.data.reuse.short_name}} installation to an earlier version is only supported in the following cases:

- You can only roll back from a newer Helm chart version to an older chart version.
- You can only roll back to {{site.data.reuse.short_name}} 2018.3.1 (Helm chart version 1.1.0). Rolling back to earlier chart versions is not supported.
- Rollback is only supported if the [inter-broker protocol](../upgrading/#post-upgrade-tasks) version has not been changed.\\
   **Warning:** It is not possible to revert to a previous version if you have changed the inter-broker protocol version.

### Remove `oauth` job

When rolling back from {{site.data.reuse.short_name}} version 2019.1.1 to 2018.3.1 (Helm chart version 1.2.0 to 1.1.0), first remove the `oauth` job from the  `kube-system` namespace (`kube-system` is the namespace for objects created by the Kubernetes system).

Use the following command to remove the `oauth` job:

`kubectl -n kube-system delete job <release-name>-ibm-es-ui-oauth2-client-reg`

Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.

## Rolling back

### Using the UI

1. {{site.data.reuse.icp_ui_login}}
3. Click **Workloads > Helm Releases** from the navigation menu.
4. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Rollback** in the corresponding row.
5. Select the chart version to roll back to (1.1.0).
6. Click **Rollback**.

### Using the CLI

1. {{site.data.reuse.icp_cli_login}}\\
   **Important:** You must have the Cluster Administrator role to roll back a chart version.
2. Run the `helm history` command to view previous versions you can roll back to:\\
   `helm history <release-name>`\\
   Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.\\
   For example:\\
   ```
$ helm history event-streams
REVISION        UPDATED                         STATUS          CHART                           DESCRIPTION
1               Mon Oct 15 14:27:12 2018        SUPERSEDED      ibm-eventstreams-prod-1.0.0     Install complete
2               Mon Dec 10 16:49:29 2018        SUPERSEDED      ibm-eventstreams-prod-1.1.0     Upgrade complete
3               Fri Mar 29 12:16:34 2019        DEPLOYED        ibm-eventstreams-prod-1.2.0     Upgrade complete
   ```
3. Run the `helm rollback` command as follows:\\
   `helm rollback <release-name> <revision>`\\
   Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation, and `<revision>` is a number from the `REVISION` column that corresponds to the version you want to revert to, as displayed in the result of the `helm history` command.\\
   For example:\\
   `helm rollback event-streams 2`

## Post-rollback tasks

**Important:** The rollback process changes the port number for the UI. You must refresh the {{site.data.reuse.icp}} UI and [determine the URL](../../getting-started/logging-in) for the {{site.data.reuse.short_name}} UI again to obtain the new port number. You can then log in to the {{site.data.reuse.short_name}} UI.
