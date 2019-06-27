---
title: "Upgrading to 2019.1.1"
excerpt: "Upgrade your installation to the latest version."
categories: installing
slug: upgrading
toc: true
---

Upgrade your installation to the latest version of {{site.data.reuse.long_name}} as follows.

You can upgrade to {{site.data.reuse.short_name}} version 2019.1.1 from version 2018.3.1. If you have version 2018.3.0, you must first upgrade your {{site.data.reuse.short_name}} version [to 2018.3.1](../../2018.3.1/installing/upgrading/), and then upgrade {{site.data.reuse.icp}} [to version 3.1.1 or 3.1.2](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/installing/upgrading.html){:target="_blank"}, before following these steps to upgrade to {{site.data.reuse.short_name}} version 2019.1.1.

**Important:** {{site.data.reuse.short_name}} only supports upgrading to a newer chart version. Do not select an earlier chart version when upgrading. If you want to revert to an earlier version of {{site.data.reuse.short_name}}, see the instructions for [rolling back](../rolling-back/).

## Prerequisites

- Ensure you have {{site.data.reuse.icp}} [version 3.1.1 or later installed](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/installing.html){:target="_blank"}.
- If you are upgrading {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), download the package for the version you want to upgrade to, and make it [available](../installing/#download-the-archive) to your {{site.data.reuse.icp}} instance.

## Using the UI

1. {{site.data.reuse.icp_ui_login}}
4. Click **Workloads > Helm Releases** from the navigation menu.
5. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Upgrade** in the corresponding row.
6. Select the chart version to upgrade to from the **Version** drop-down list.
7. Ensure you set **Using previous configured values** to **Reuse Values**.
8. Click **Upgrade**.

The upgrade process begins and restarts your pods. During the process, the UI shows pods as unavailable and restarting.


After the upgrade completes, you must [perform the post-upgrade](#post-upgrade-tasks) tasks.

## Using the CLI

1. Ensure you have the latest helm chart version available on your local file system.\\
   - You can [retrieve](../../administering/helm-upgrade-command/) the charts from the UI.
   - Alternatively, if you downloaded the archive from IBM Passport Advantage, the chart file is included in the archive. Extract the PPA archive, and locate the chart file in the `/charts` directory, for example: `ibm-eventstreams-prod-1.2.0.tgz`.
2. {{site.data.reuse.icp_cli_login}}\\
   **Important:** You must have the Cluster Administrator role to upgrade the chart.
3. Save the configuration settings of your existing installation to a file as follows:\\
   `helm get values <release-name> > <saved-configuration-settings>.yaml`\\
   For example:\\
   `helm get values eventstreams1 > config-settings.yaml`
4. Run the helm upgrade command as follows, referencing the file where you saved your configuration settings and the helm chart you want to upgrade to:\\
   `helm upgrade -f <saved-configuration-settings>.yaml --set global.image.repository="<cluster_CA_domain>:8500" <release-name> <latest-chart-version>`\\
   For example, to upgrade the {{site.data.reuse.ce_short}}:\\
   `helm upgrade -f config-settings.yaml --set global.image.repository="ibmcom" eventstreams1 /Users/admin/upgrade/ibm-eventstreams-dev-1.2.0.tgz`\\
   For example, to upgrade by using a chart downloaded in the PPA archive:\\
   `helm upgrade -f config-settings.yaml --set global.image.repository="mycluster.icp:8500" eventstreams1 /Users/admin/upgrade/ibm-eventstreams-prod-1.2.0.tgz`

The upgrade process begins and restarts your pods. During the process, the UI shows pods as unavailable and restarting.

After the upgrade completes, you must [perform the post-upgrade](#post-upgrade-tasks) tasks.

## Post-upgrade tasks

Additional steps required after upgrading are described in the following sections.

### Retrieve new port number for UI

**Important:** The upgrade process changes the port number for the UI. You must refresh the {{site.data.reuse.icp}} UI and [determine the URL](../../getting-started/logging-in) for the {{site.data.reuse.short_name}} UI again to obtain the new port number. You can then log in to the {{site.data.reuse.short_name}} UI.

### Update inter-broker protocol version

{{site.data.reuse.short_name}} 2019.1.1 includes an update to Apache Kafka version [2.1.1](http://kafka.apache.org/21/documentation.html#upgrade){:target="_blank"}.

Apache Kafka 2.1 includes changes to the internal schema used to store consumer offsets. It also includes changes to the inter-broker protocol. These changes are not enabled by default, so you need manually enable the changes by running the following command.

**Warning:** It is not possible to downgrade to previous versions after you enable the changes. Do not perform this final upgrade step until you have [verified](../post-installation/#verifying-your-installation) that the upgrade to {{site.data.reuse.short_name}} 2019.1.1 has been successful.

1. Ensure you have the {{site.data.reuse.short_name}} CLI [installed](../post-installation/#installing-the-command-line-interface).
2. {{site.data.reuse.icp_cli_login}}
3. Run the following command:\\
   `cloudctl es cluster-config --static-config-all-brokers --config log.message.format.version=2.1 --config inter.broker.protocol.version=2.1`

**Note:** This command causes each of the brokers to restart. However, the Kafka cluster remains available during the restarts.

### Access management

If you have {{site.data.reuse.icp}} teams set up for [access management](../../security/managing-access/#assigning-access-to-users), you must associate the teams again with your {{site.data.reuse.long_name}} instance after successfully completing the upgrade.

To use your upgraded {{site.data.reuse.short_name}} instance with existing {{site.data.reuse.icp}} teams, re-apply the security resources to any teams you have defined as follows:

1. Check the teams you use:\\
   1. {{site.data.reuse.icp_ui_login}}
   2. Enter an {{site.data.reuse.icp}} administrator user name and password.
   3. From the navigation menu, click **Manage > Identity & Access > Teams**. Look for the teams you use with your {{site.data.reuse.short_name}} instance.
2. Ensure you have [installed](../../installing/post-installation/#installing-the-command-line-interface) the latest version of the {{site.data.reuse.short_name}} CLI.
3. Run the following command for each team that references your instance of {{site.data.reuse.short_name}}:\\
  `cloudctl es iam-add-release-to-team --namespace <namespace> --helm-release <helm-release> --team <team-name>`

<!--Without this rerun of the command, customers will find that creating service IDs in the UI will fail unless you're running as cluster administrator.-->


### Update UI bookmarks

   If you have any bookmarks to the UI, you need to update them because the port number for the {{site.data.reuse.short_name}} UI changes as part of the upgrade to version 2019.1.1.


### Browser certificates

   If you trusted certificates in your browser for using the {{site.data.reuse.short_name}} UI, you might not be able to access the UI after upgrading.

   To resolve this issue, you must delete previous certificates and trust new ones. Check the browser help for instructions, the process for deleting and accepting certificates varies depending on the type of browser you have.
