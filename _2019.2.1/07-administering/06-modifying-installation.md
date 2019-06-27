---
title: "Modifying installation settings"
excerpt: "Modify your existing Event Streams installation."
categories: administering
slug: modifying-installation
toc: true
---

You can modify the configuration settings for your existing {{site.data.reuse.short_name}} installation by using the UI or the command line. The configuration changes are applied by updating the {{site.data.reuse.short_name}} chart. For example, you might need to modify settings to [scale](../scaling/) your installation due to changing requirements.

## Using the UI

You can modify any of the [configuration settings](../../installing/configuring/#configuration-reference) you specified during installation, or define values for ones previously not set at the time of installation.

To modify configuration settings by using the UI:
1. {{site.data.reuse.icp_ui_login}}
2. From the navigation menu, click **Workloads > Helm Releases**.
3. Locate the release name of your existing {{site.data.reuse.short_name}} cluster in the **NAME** column, and click ![More options icon](../../images/more_options.png "Three vertical dots for the more options icon at end of each row."){:height="30px" width="15px"} **More options > Upgrade** in the corresponding row.
4. Select the installed chart version from the **Version** drop-down list.
5. Ensure you set **Using previous configured values** to **Reuse Values**.
6. Click **All parameters** in order to access all the release-related parameters.
7. Modify the values for the configuration settings you want to change.\\
   For example, to set the number of geo-replication workers to 4, go to the **Geo-replication settings** section and set the **Geo-replicator workers** field to 4.
8. Click **Upgrade**.

## Using the CLI

You can modify any of the parameters you specified during installation, or define values for ones previously not set at the time of installation. For a list of all parameters, see the chart README file.

To modify any of the parameter settings by using the CLI:
1. {{site.data.reuse.icp_cli_login}}
2. Use the following helm command to modify the value of a parameter:\\
   `helm upgrade --reuse-values --set <parameter>=<value> <release_name> <charts.tgz> --tls`\\
   {{site.data.reuse.helm_charts_note}}\\
   \\
   For example, to set the number of geo-replication workers to 4, use the following command:\\
   `helm upgrade --reuse-values --set replicator.replicas=4 destination ibm-eventstreams-prod-1.3.0.tgz --tls`
