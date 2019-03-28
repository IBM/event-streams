---
title: "Logging in"
excerpt: "Log in to your IBM Event Streams installation."
categories: getting-started
slug: logging-in
toc: true
---

Log in to your {{site.data.reuse.long_name}} installation. To determine the {{site.data.reuse.long_name}} UI URL:

1. {{site.data.reuse.icp_ui_login}}
2. From the navigation menu, click **Workloads > Helm Releases**.\\
   ![Menu > Workloads > Helm releases](../../../images/icp_menu_helmreleases.png "Screen capture showing how to select Workloads > Helm releases from navigation menu"){:height="30%" width="30%"}
3. Locate the release name of your {{site.data.reuse.long_name}} installation in the **NAME** column.
4. Expand the **Launch** link in the row and click **admin-ui-https**.\\
   ![Launch > admin-ui-https](../../../images/expanded_launch.png "Screen capture showing how to select Launch > admin-ui-https for the row"){:height="50%" width="50%"}\\
   The {{site.data.reuse.long_name}} log in page is displayed.\\
   **Note:** You can also determine the {{site.data.reuse.long_name}} UI URL by using the CLI. Click the release name and scroll to the **Notes** section at the bottom of the page and follow the instructions. You can then use the URL to log in.
5. Use your {{site.data.reuse.icp}} administrator user name and password to access the UI. Use the same username and password as you use to log in to {{site.data.reuse.icp}}.

From the **Getting started** page, you can start exploring {{site.data.reuse.short_name}} through a simulated topic, or through learning about the concepts of the underlying technology. You can also [generate a starter application](../generating-starter-app) that lets you learn more about writing applications.

For more useful applications, tools, and connectors, go to the **Toolbox** tab.

## Logging out

Logging out of {{site.data.reuse.short_name}} does not log you out of your session entirely. To log out, you must first log out of your {{site.data.reuse.icp}} session, and then log out of your {{site.data.reuse.short_name}} session.

To log out of {{site.data.reuse.short_name}}:

1. {{site.data.reuse.icp_ui_login}}
2. Click the user icon in the upper-right corner of the window, and click **Log out**.
3. Return to your {{site.data.reuse.short_name}} UI and click the user icon in the upper-right corner of the window, and click **Log out**.
