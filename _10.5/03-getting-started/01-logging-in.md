---
title: "Logging in"
excerpt: "Log in to your IBM Event Streams installation."
categories: getting-started
slug: logging-in
toc: true
---

{{site.data.reuse.short_name}} uses OpenShift routes. Find out how to retrieve the URLs for your {{site.data.reuse.long_name}} UI and CLI. You can then use the appropriate URL to log in to your {{site.data.reuse.short_name}} instance.

You can use the {{site.data.reuse.openshift_short}} UI (web console) or CLI to retrieve the login URLs.

## Using {{site.data.reuse.openshift_short}} UI

- Use the OpenShift web console to retrieve the URL for your {{site.data.reuse.short_name}} UI as follows:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Operators** in the navigation on the left, and click **Installed Operators**.\\
   ![Operators > Installed Operators](../../../images/rhocp_menu_installedoperators.png "Screen capture showing how to select Operators > Installed Operators from navigation menu"){:height="50%" width="50%"}
3. Locate the operator that manages your {{site.data.reuse.short_name}} instance in the namespace. It is called **{{site.data.reuse.long_name}}** in the **NAME** column.
4. Click the **{{site.data.reuse.long_name}}** link in the row and click the **{{site.data.reuse.short_name}}** tab. This lists the **{{site.data.reuse.short_name}}** operands related to this operator.
5. Find your instance in the **Name** column and click the link for the instance. \\
   ![{{site.data.reuse.long_name}} > {{site.data.reuse.short_name}} > Instance](../../../images/find_your_instance.png "Screen capture showing how to select your instance by {{site.data.reuse.long_name}} > {{site.data.reuse.short_name}} > Instance"){:height="100%" width="100%"}
6. A link to the {{site.data.reuse.long_name}} UI is displayed under the label **Admin UI**. Click the link to open the {{site.data.reuse.long_name}} UI login page in your browser tab.
7. Log in to your {{site.data.reuse.long_name}} UI from a supported [web browser](../../installing/prerequisites/#ibm-event-streams-ui). Use your credentials provided to you by your cluster administrator.
   A cluster administrator can manage access rights by following the instructions in [managing access](../../security/managing-access/#assigning-access-to-users).
   Enter your username and password to access the {{site.data.reuse.short_name}} UI.

- Use the OpenShift web console to retrieve the URL for your {{site.data.reuse.short_name}} CLI as follows:

1. {{site.data.reuse.openshift_ui_login}}
2. Expand **Networking** in the navigation on the left, and click **Routes**.\\
   ![Networking > Routes](../../../images/rhocp_menu_routes.png "Screen capture showing how to select Networking > Routes from navigation menu"){:height="50%" width="50%"}
3. Expand the **Project** at the top of the page and select **ibm-common-services**.

   The following is an example output, and you use the value from the **Location** column for the **cp-console** entry to log in to your CLI in a terminal window:\\
   ![Project](../../../images/find_cp_console_route.png "Screen capture showing how to select the CLI route")
4. Enter the address on your login command in a terminal. For example:
   ```
   cloudctl login -a https://cp-console.apps.my-cluster.my-domain.com
   ```
5. Use your credentials provided to you by your cluster administrator.
   A cluster administrator can manage access rights by following the instructions in [managing access](../../security/managing-access/#assigning-access-to-users).
   Enter your username and password to access the {{site.data.reuse.short_name}} CLI.
6. Initialize the {{site.data.reuse.short_name}} plugin by running the following command:
   ```
   cloudctl es init -n <namespace>
   ```

## Using the {{site.data.reuse.openshift_short}} CLI

- To retrieve the URL for your {{site.data.reuse.short_name}} UI, use the following commands:

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command:

   ```
   oc get routes -n <namespace> -l app.kubernetes.io/name=admin-ui
   ```


   The following is an example output, and you use the value from the **HOST/PORT** column to log in to your UI in a web browser:

   ```
   NAME                        HOST/PORT                                                           PATH   SERVICES                    PORT   TERMINATION   WILDCARD
   my-eventstreams-ibm-es-ui   my-eventstreams-ibm-es-ui-myproject.apps.my-cluster.my-domain.com          my-eventstreams-ibm-es-ui   3000   reencrypt     None
   ```
3. Enter the address in a web browser. Add `https://` in front of the **HOST/PORT** value. For example:
   ```
   https://my-eventstreams-ibm-es-ui-myproject.apps.my-cluster.my-domain.com
   ```
4. Log in to your {{site.data.reuse.long_name}} UI from a supported [web browser](../../installing/prerequisites/#ibm-event-streams-ui). Use your credentials provided to you by your cluster administrator. A cluster administrator can manage access rights by following the instructions in [managing access](../../security/managing-access/#assigning-access-to-users). Enter your username and password to access the {{site.data.reuse.short_name}} UI.

- To retrieve the URL for your {{site.data.reuse.short_name}} CLI, use the following commands:

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command:

   ```
   oc get routes -n ibm-common-services -l app.kubernetes.io/name=management-ingress
   ```


   The following is an example output, and you use the value from the **HOST/PORT** column for the **cp-console** entry to log in to your CLI in a terminal:

   ```
   NAME         HOST/PORT                                  PATH   SERVICES                   PORT    TERMINATION            WILDCARD
   cp-console   cp-console.apps.my-cluster.my-domain.com          icp-management-ingress     https   reencrypt/Redirect     None
   cp-proxy     cp-proxy.apps.my-cluster.my-domain.com            nginx-ingress-controller   https   passthrough/Redirect   None
   ```
3. Enter the address on your login command in a terminal. Add `https://` in front of the **HOST/PORT** value. For example:
   ```
   cloudctl login -a https://cp-console.apps.my-cluster.my-domain.com
   ```
4. Use your credentials provided to you by your cluster administrator.
   A cluster administrator can manage access rights by following the instructions in [managing access](../../security/managing-access/#assigning-access-to-users).
   Enter your username and password to access the {{site.data.reuse.short_name}} CLI.
5. Initialize the {{site.data.reuse.short_name}} plugin by running the following command:
   ```
   cloudctl es init -n <namespace>
   ```

## Logging out
Logging out of {{site.data.reuse.short_name}} does not log you out of your session entirely. To log out, you must first log out of your {{site.data.reuse.icpfs}} session, and then log out of your {{site.data.reuse.short_name}} session.

To log out of {{site.data.reuse.short_name}}:

1. {{site.data.reuse.icpfs_ui_login}}
2. Click the user icon in the upper-right corner of the window, and click **Log out**.
3. Return to your {{site.data.reuse.short_name}} UI and click the user icon in the upper-right corner of the window, and click **Log out**.
