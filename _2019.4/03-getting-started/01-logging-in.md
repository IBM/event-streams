---
title: "Logging in"
excerpt: "Log in to your IBM Event Streams installation."
categories: getting-started
slug: logging-in
toc: true
---

Log in to your {{site.data.reuse.long_name}} UI from a supported [web browser](../../installing/prerequisites/#ibm-event-streams-user-interface). Determining the URL depends on your platform.


## Using {{site.data.reuse.openshift_short}}

If installed on the {{site.data.reuse.openshift_short}}, {{site.data.reuse.short_name}} uses OpenShift routes. To retrieve the URL for your {{site.data.reuse.short_name}} UI, use the following command:

1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command:

   `kubectl get routes -n <namespace> -l component=ui`

   The following is an example output, and you use the value from the **HOST/PORT** column to log in to your UI in a web browser:

   ```
   NAME                              HOST/PORT                                                         PATH  SERVICES                       PORT             TERMINATION        WILDCARD
my-eventstreams-ibm-es-ui-route   my-eventstreams-ibm-es-ui-route-es.apps.my-cluster.my-domain.com        my-eventstreams-ibm-es-ui-svc  admin-ui-https   passthrough/None   None
```

Add `https://` in front of the **HOST/PORT** value when entering it in the web browser, in this example:

`https://my-eventstreams-ibm-es-ui-route-es.apps.my-cluster.my-domain.com`

## Using {{site.data.reuse.icp}}

If you installed {{site.data.reuse.short_name}} on {{site.data.reuse.icp}}, see the following guidance.

1. {{site.data.reuse.icp_ui_login321}}
2. From the navigation menu, click **Workloads > Helm Releases**.\\
   ![Menu > Workloads > Helm releases](../../../images/icp_menu_helmreleases.png "Screen capture showing how to select Workloads > Helm releases from navigation menu"){:height="30%" width="30%"}
3. Locate the release name of your {{site.data.reuse.long_name}} installation in the **NAME** column.
4. Expand the **Launch** link in the row and click **admin-ui-https**.\\
   ![Launch > admin-ui-https](../../../images/expanded_launch.png "Screen capture showing how to select Launch > admin-ui-https for the row"){:height="50%" width="50%"}\\
   The {{site.data.reuse.long_name}} log in page is displayed.\\
   **Note:** You can also determine the {{site.data.reuse.long_name}} UI URL by using the CLI. Click the release name and scroll to the **Notes** section at the bottom of the page and follow the instructions. You can then use the URL to log in.
5. Use your {{site.data.reuse.icp}} administrator user name and password to access the UI. Use the same username and password as you use to log in to {{site.data.reuse.icp}}.


## Logging out

Logging out of {{site.data.reuse.short_name}} does not log you out of your session entirely. To log out, you must first log out of your {{site.data.reuse.icp}} session, and then log out of your {{site.data.reuse.short_name}} session.

To log out of {{site.data.reuse.short_name}}:

1. {{site.data.reuse.icp_ui_login321}}
2. Click the user icon in the upper-right corner of the window, and click **Log out**.
3. Return to your {{site.data.reuse.short_name}} UI and click the user icon in the upper-right corner of the window, and click **Log out**.
