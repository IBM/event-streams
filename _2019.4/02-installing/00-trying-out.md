---
title: "Trying out Event Streams"
excerpt: "Install a basic deployment to try out IBM Event Streams."
categories: installing
slug: trying-out
toc: true
---

To try out {{site.data.reuse.short_name}}, you can install a basic deployment of the {{site.data.reuse.ce_short}}.

{{site.data.reuse.ce_long}} is a free version intended for trial and demonstration purposes. It can be installed and used without charge.

**Note:** These instructions do not include setting up persistent storage, so your data and configuration settings are not retained in the event of a restart.

For more features and full IBM support, [install {{site.data.reuse.long_name}}](../installing).

![Event Streams 2019.4.2 icon](../../images/2019.4.2.svg "In Event Streams 2019.4.2.") **Restriction:** The {{site.data.reuse.ce_short}} is not available in {{site.data.reuse.short_name}} version 2019.4.2.


## On {{site.data.reuse.icp}}

{{site.data.reuse.ce_long}} is included in the {{site.data.reuse.icp}} catalog.

1. If you do not have {{site.data.reuse.icp}} installed already, you can download and [install IBM Cloud Private-CE](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/installing/install_containers.html){:target="_blank"}.
2. {{site.data.reuse.icp_ui_login321}}
3. Create a namespace where you will install your {{site.data.reuse.short_name}} instance:\\
   1. From the navigation menu, click **Manage > Namespaces**.
   3. Click **Create Namespace**.
   3. Enter a name for your namespace.
   4. Ensure you have the `ibm-restricted-psp` [PodSecurityPolicy](https://ibm.biz/cpkspec-psp){:target="_blank"} selected for the target namespace.
   5. Click **Create**.
4. Click **Catalog** in the top navigation menu.
4. Search for `ibm-eventstreams-dev` and select it from the result. This is the Helm chart for the {{site.data.reuse.ce_long}}. The README is displayed.
5. Click **Configure**.
6. {{site.data.reuse.enter_install_details}}\\
   You can leave all other settings at their default values.
7. Click **Install**.
8. [Verify your installation and log in](../post-installation/#verifying-your-installation) to start using {{site.data.reuse.short_name}}.

These steps install a basic instance of {{site.data.reuse.ce_long}} that you can try out. You can also [configure](../configuring) your installation to change the default settings as required, for example, to set up [persistent storage](../planning/#persistent-storage).

{{site.data.reuse.geo-rep_note}}

## On {{site.data.reuse.openshift_short}}

If you are using {{site.data.reuse.openshift_short}}, you can set up an integration with {{site.data.reuse.icp}}, and install the {{site.data.reuse.ce_long}} included in the catalog.

1. Ensure you have the right version of OpenShift installed and integrated with the right version of {{site.data.reuse.icp}}. For supported versions, see the support [table](../prerequisites/#container-environment).

   For example, [install](https://docs.openshift.com/container-platform/3.11/getting_started/install_openshift.html){:target="_blank"} OpenShift 3.11, and [integrate](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/supported_environments/openshift/overview.html){:target="_blank"} it with {{site.data.reuse.icp}} 3.2.1.

2. Create a [project](https://docs.openshift.com/container-platform/3.11/dev_guide/projects.html){:target="_blank"} in OpenShift. This will also create a namespace with the same name in {{site.data.reuse.icp}}. You then use this namespace to install your {{site.data.reuse.short_name}} instance. For example, to create a project by using the web console:\\
   1. [Log in to](https://docs.openshift.com/container-platform/3.11/dev_guide/authentication.html#dev-guide-authentication){:target="_blank"} the {{site.data.reuse.openshift_short}} web console by using the user name and password provided to you by your administrator.
   2. Click the **Create project** button, and type a unique name, display name, and description for the new project. This creates a project and a namespace.
3. Download and run the setup script as follows:\\
   **Important:** You must perform the following steps by using a terminal opened on the host where the {{site.data.reuse.icp}} master cluster is installed. If you are on a different host, you must first connect to the host machine by using SSH before logging in.
   1. {{site.data.reuse.icp_cli_login321}}
   2. Download the files from [GitHub](https://github.com/IBM/charts/tree/master/stable/ibm-eventstreams-dev/ibm_cloud_pak/pak_extensions/pre-install){:target="_blank"}.
   3. Change to the location where you downloaded the files, and run the setup script as follows:\\
       `./scc.sh <namespace>`\\
       Where `<namespace>` is the namespace (project) you created for your {{site.data.reuse.short_name}} installation earlier.
4. {{site.data.reuse.icp_ui_login321}}
5. Click **Catalog** in the top navigation menu.
6. Search for `ibm-eventstreams-dev` and select it from the result. This is the Helm chart for the {{site.data.reuse.ce_long}}. The README is displayed.
7. Click **Configure**.
8. {{site.data.reuse.enter_install_details}}
   You can leave all other settings at their default values.

9. Click **Install**.
10. [Verify your installation and log in](../post-installation/#verifying-your-installation) to start using {{site.data.reuse.short_name}}.

These steps install a basic instance of {{site.data.reuse.ce_long}} that you can try out. You can also [configure](../configuring) your installation to change the default settings as required, for example, to set up [persistent storage](../planning/#persistent-storage).

{{site.data.reuse.geo-rep_note}}
