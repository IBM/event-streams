---
title: "Post-installation tasks"
excerpt: "Post-installation tasks after successfully installing IBM Event Streams."
categories: installing
slug: post-installation
toc: true
---

Consider the following tasks after installing {{site.data.reuse.long_name}}.

## Verifying an installation

To verify that your {{site.data.reuse.short_name}} installation deployed successfully, you can check the status of your instance through the {{site.data.reuse.openshift_short}} web console or command line.

### Check the status of the EventStreams instance through the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. {{site.data.reuse.task_openshift_select_instance}}
5. The **Phase** field will display the current state of the EventStreams custom resource. When the {{site.data.reuse.short_name}} instance is ready, the phase will display `Ready`, meaning the deployment has completed.

### Check the status of the {{site.data.reuse.short_name}} instance through the command line

After all the components of an {{site.data.reuse.short_name}} instance are active and ready, the `EventStreams` custom resource will have a `Ready` phase in the status.
To verify the status:

1. {{site.data.reuse.openshift_cli_login}}
2. Run the `oc get` command as follows: `oc get eventstreams`

For example, the installation of the instance called `development` is complete when the `STATUS` returned by the `oc get` command displays `Ready`:
`oc get eventstreams`
An example output:

```
$ oc get eventstreams
>
NAME             STATUS
development      Ready
```

**Note:** It might take several minutes for all the resources to be created and the `EventStreams` instance to become ready.

## Installing the {{site.data.reuse.short_name}} command-line interface

The {{site.data.reuse.short_name}} CLI is a plugin for the `cloudctl` CLI. Use the {{site.data.reuse.short_name}} CLI to manage your {{site.data.reuse.short_name}} instance from the command line.
Examples of management activities include:

- Creating, deleting, and updating Kafka topics.
- Creating, deleting, and updating Kafka users.
- Creating, deleting, and updating Kafka message schemas.
- Managing geo-replication.
- Displaying the cluster configuration and credentials.

To install the {{site.data.reuse.short_name}} CLI:

1. Ensure you have the IBM Cloud Pak CLI (`cloudctl`) installed either by [retrieving the binary from your cluster](https://www.ibm.com/support/knowledgecenter/en/SSHKN6/cloudctl/3.x.x/install_cli.html){:target="_blank"} or [downloading the binary from a release on the GitHub project](https://github.com/IBM/cloud-pak-cli/releases){:target="_blank"}.\\
   **Note:** Ensure you download the correct binary for your architecture and operating system.
2. [Log in](../../getting-started/logging-in/) to your {{site.data.reuse.short_name}} instance as an administrator.
3. Click **Toolbox** in the primary navigation.
4. Go to the **{{site.data.reuse.long_name}} command-line interface** section and click **Find out more**.
5. Download the {{site.data.reuse.short_name}} CLI plug-in for your system by using the appropriate link.
6. Install the plugin using the following command:\\
   `cloudctl plugin install <path-to-plugin>`

To start the {{site.data.reuse.short_name}} CLI and check all available command options in the CLI, use the `cloudctl es` command.
For an exhaustive list of commands, you can run:

`cloudctl es --help`

To get help for a specific command, run:

`cloudctl es <command> --help`

To use the {{site.data.reuse.short_name}} CLI against an {{site.data.reuse.openshift_short}} cluster, do the following:

{{site.data.reuse.cp_cli_login}}

To configure the CLI to connect to a specific {{site.data.reuse.short_name}} instance running a namespace:

`cloudctl es init -n <namespace>`


## Firewall and load balancer settings

Consider the following guidance about firewall and load balancer settings for your deployment.

### Using {{site.data.reuse.openshift_short}} routes

{{site.data.reuse.short_name}} uses OpenShift routes. Ensure your OpenShift [router](https://docs.openshift.com/container-platform/4.6/networking/routes/route-configuration.html){:target="_blank"} is set up as required.

## Connecting clients

For instructions about connecting a client to your {{site.data.reuse.short_name}} instance, see [connecting clients](../../getting-started/connecting).

## Setting up access

Secure your installation by [managing the access](../../security/managing-access/) your users and applications have to your {{site.data.reuse.short_name}} resources.

For example, associate your {{site.data.reuse.icpfs}} teams with your {{site.data.reuse.short_name}} instance to grant access to resources based on roles.

## Scaling

Depending on the size of the environment that you are installing, consider scaling and sizing options. You might also need to change scale and size settings for your services over time. For example, you might need to add additional Kafka brokers over time.

See [how to scale your environment](../../administering/scaling).

## Considerations for GDPR readiness

Consider [the requirements for GDPR](../../security/gdpr-considerations/), including [encrypting your data](../../security/encrypting-data/) for protecting it from loss or unauthorized access.
