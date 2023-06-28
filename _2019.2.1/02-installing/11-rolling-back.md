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

Rolling back your {{site.data.reuse.short_name}} 2019.2.1 installation to an earlier version is only supported in the following cases:

- You can only roll back from a newer Helm chart version to an older chart version.
- You can only roll back to {{site.data.reuse.short_name}} 2019.1.1 (Helm chart version 1.2.0). Rolling back to earlier chart versions is not supported.

## Rolling back

### Using the UI

1. {{site.data.reuse.icp_ui_login}}
3. Click **Workloads > Helm Releases** from the navigation menu.
4. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Rollback** in the corresponding row.
5. Select the chart version to roll back to (1.2.0).
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
3               Fri Mar 29 12:16:34 2019        SUPERSEDED      ibm-eventstreams-prod-1.2.0     Upgrade complete
4               Fri Jun 28 16:16:34 2019        DEPLOYED        ibm-eventstreams-prod-1.3.0     Upgrade complete
   ```
3. Run the `helm rollback` command as follows:\\
   `helm rollback <release-name> <revision>`\\
   Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation, and `<revision>` is a number from the `REVISION` column that corresponds to the version you want to revert to, as displayed in the result of the `helm history` command.\\
   For example:\\
   `helm rollback event-streams 3`
