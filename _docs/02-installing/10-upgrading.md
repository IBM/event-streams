---
title: "Upgrading"
permalink: /installing/upgrading/
excerpt: "Upgrade your installation to the latest version."
toc: true
---

Upgrade your installation to the latest version of {{site.data.reuse.long_name}} as follows.

## Upgrading to 2018.3.1

Use the CLI to upgrade {{site.data.reuse.short_name}}. You cannot use the UI to upgrade to {{site.data.reuse.short_name}} 2018.3.1.

<!--## Using the CLI-->

1. Ensure you have the latest helm chart version available on your local file system.\\
   - You can [retrieve](../../administering/helm-upgrade-command/) the charts from the UI.
   - Alternatively, if you [downloaded](../../installing/downloading/) the archive from IBM Passport Advantage, the chart file is included in the archive. Ensure it is available to your {{site.data.reuse.icp}} instance.
2. {{site.data.reuse.icp_cli_login}}\\
   **Important:** You must have the Cluster Administrator role to install the chart.
3. Optional: Due to a known defect in the Kafka health check, the upgrade process creates a short outage period whilst the upgrade takes place where messages cannot be sent to topics. If you want to avoid an outage, follow these steps to upgrade the health check before upgrading {{site.data.reuse.short_name}}:\\
   1. Run the following command:\\
      `kubectl edit sts <release-name>-ibm-es-kafka-sts`\\
      This command opens the stateful set configuration in the default editor (for example, the vi editor).
   2. There are four `image:` tags in the statefulset definition, search for the tag containing the word `healthcheck`.\\
      An example of the string for a {{site.data.reuse.ce_short}} installation is as follows:\\
      ```
      image: ibmcom/eventstreams-healthcheck-ce:2018-09-18-11.23.15-1a8f35a71d2b2edc91bf1eccf664d821e04f8420
      ```
      If you installed from an image downloaded from IBM Passport Advantage, your {{site.data.reuse.icp}} docker registry name would be displayed instead of `ibmcom`, and the string would not have `ce` included.
   3. Update the tag with the unique identifier after `ibmcom/`.\\
      **Note:** The `ibmcom/` can also be `docker/` or a different `<repository-name>/`.\\
      - For {{site.data.reuse.ce_short}} installations, the unique identifier is as follows:\\
         ```
         eventstreams-healthcheck-ce-icp-linux-amd64:2018-11-21-16.21.30-9947d87
         ```
      - For {{site.data.reuse.short_name}} downloaded from IBM Passport Advantage, the unique identifier is as follows:\\
         ```
         eventstreams-healthcheck-icp-linux-amd64:2018-11-21-16.21.30-9947d87
         ```
         \\
         The following example shows the changing of the tag for a {{site.data.reuse.ce_short}} installation after `ibmcom/`:\\
      From
      ```
      ibmcom/eventstreams-healthcheck-ce:2018-09-18-11.23.15-1a8f35a71d2b2edc91bf1eccf664d821e04f8420
      ```
      To
      ```
      ibmcom/eventstreams-healthcheck-ce-icp-linux-amd64:2018-11-21-16.21.30-9947d87
      ```
   4. Save your changes and exit the editor.
4. Optional: The helm resource requirements changed for release 2018.3.1. If you modified the [default settings](../prerequisites/#helm-resource-requirements) for your existing installation, ensure you have the ZooKeeper memory limit set to at least 1 GB, the ZooKeeper request memory set to at least 750 MB, and the Elastic Search memory limit set to at least 4 GB.\\
   To set the values, run the `helm upgrade` command as follows:
   - Set the ZooKeeper memory limit and request memory to at least 1 GB and 750 MB, respectively:\\
      `helm upgrade --reuse-values  --set zookeeper.resources.limits.memory=1Gi --set zookeeper.resources.requests.memory=750Mi <release-name> <chart-file>.tgz`\\
      For example:\\
      `helm upgrade --reuse-values  --set zookeeper.resources.limits.memory=1Gi --set zookeeper.resources.requests.memory=750Mi event-streams-1 ibm-eventstreams-dev-1.0.0.tgz`
   - Set the Elastic Search memory limit to at least 4 GB:\\
      `helm upgrade --reuse-values  --set messageIndexing.resources.limits.memory=4Gi <release-name> <chart-file>.tgz`\\
      For example:\\
      `helm upgrade --reuse-values  --set messageIndexing.resources.limits.memory=4Gi event-streams-1 ibm-eventstreams-dev-1.0.0.tgz`
5. Save the configuration settings of your existing installation to a file as follows:\\
   `helm get values <release-name> > <saved-configuration-settings>.yaml`\\
   For example:\\
   `helm get values eventstreams1 > config-settings.yaml`
6. Run the helm upgrade command as follows, referencing the file where you saved your configuration settings and the helm chart you want to upgrade to:\\
   `helm upgrade -f <saved-configuration-settings>.yaml <release-name> <latest-chart-version> --set global.arch=amd64`\\
   For example:\\
   `helm upgrade -f config-settings.yaml eventstreams1 /Users/admin/upgrade/ibm-eventstreams-dev-1.1.0.tgz --set global.arch=amd64`

The upgrade process begins and restarts your pods. During the process, the UI shows pods as unavailable and restarting. When the upgrade is complete, refresh your browser, and continue to use the {{site.data.reuse.short_name}} UI.

Depending on your set-up, consider completing the post-upgrade tasks.

### Post-upgrade tasks

Depending on your set-up, you might need to complete additional steps as described in the following sections.

#### Access management

If you have {{site.data.reuse.icp}} teams set up for [access management](../../security/managing-access/#assigning-access-to-users), you must associate the teams again with your {{site.data.reuse.long_name}} instance after successfully completing the upgrade.

To use your upgraded {{site.data.reuse.short_name}} instance with existing {{site.data.reuse.icp}} teams, re-apply the security resources to any teams you have defined as follows:

1. Check the teams you use:\\
   1. {{site.data.reuse.icp_ui_login}}
   2. Enter an {{site.data.reuse.icp}} administrator user name and password.
   3. From the navigation menu, click **Manage > Identity & Access > Teams**. Look for the teams you use with your {{site.data.reuse.short_name}} instance.
2. Ensure you have [installed](../post-installation/#installing-the-cli) the latest version of the {{site.data.reuse.short_name}} CLI.
3. Run the following command for each team that references your instance of {{site.data.reuse.short_name}}:\\
  `cloudctl es iam-add-release-to-team --namespace <namespace> --helm-release <helm-release> --team <team-name>`

<!--Without this rerun of the command, customers will find that creating service IDs in the UI will fail unless you're running as cluster administrator.-->

#### Browser certificates

   If you trusted certificates in your browser for using the {{site.data.reuse.short_name}} UI, you might not be able to access the UI after upgrading.

   To resolve this issue, you must delete previous certificates and trust new ones. Check the browser help for instructions, the process for deleting and accepting certificates varies depending on the type of browser you have.



<!--
## Using the UI

1. Ensure you have [{{site.data.reuse.icp}} version 3.1.1 or later installed](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/installing.html).
2. Optional: When upgrading {{site.data.reuse.long_name}} (not {{site.data.reuse.ce_short}}), [download](../downloading/) the package for the version you want to upgrade to, and make it available to your {{site.data.reuse.icp}} instance.
3. {{site.data.reuse.icp_ui_login}}
4. Click **Workloads > Helm Releases** from the navigation menu.
5. Locate the release name of your installation in the **Name** column, and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Upgrade** in the corresponding row.
6. Select the chart version to upgrade to from the **Version** drop-down list.
7. Ensure you set **Using previous configured values** to **Reuse Values**.
8. Click **Upgrade**.\\
   The upgrade process begins and restarts your pods. During the process, the UI shows pods as unavailable and restarting. When the upgrade is complete, refresh your browser, and continue to use the {{site.data.reuse.short_name}} UI.
-->
