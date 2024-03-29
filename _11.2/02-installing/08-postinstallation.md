---
title: "Post-installation tasks"
excerpt: "Post-installation tasks after successfully installing IBM Event Streams."
categories: installing
slug: post-installation
layout: redirects
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

1. {{site.data.reuse.cncf_cli_login}}
2. Run the `kubectl get` command as follows:

   `kubectl get eventstreams`

For example, the installation of the instance called `development` is complete when the `STATUS` returned by the `kubectl get` command displays `Ready`.

An example output:
```
$ kubectl get eventstreams
>
NAME             STATUS
development      Ready
```

**Note:** It might take several minutes for all the resources to be created and the `EventStreams` instance to become ready.

### Check the status of the EventStreams instance through the {{site.data.reuse.openshift_short}} web console

1. {{site.data.reuse.openshift_ui_login}}
2. {{site.data.reuse.task_openshift_navigate_installed_operators}}
3. {{site.data.reuse.task_openshift_select_operator}}
4. {{site.data.reuse.task_openshift_select_instance}}
5. The **Phase** field will display the current state of the EventStreams custom resource. When the {{site.data.reuse.short_name}} instance is ready, the phase will display `Ready`, meaning the deployment has completed

## Installing the {{site.data.reuse.short_name}} command-line interface

The {{site.data.reuse.short_name}} CLI is a plugin for the `cloudctl` CLI. Use the {{site.data.reuse.short_name}} CLI to manage your {{site.data.reuse.short_name}} instance from the command line.
Examples of management activities include:

- Creating, deleting, and updating Kafka topics.
- Creating, deleting, and updating Kafka users.
- Creating, deleting, and updating Kafka message schemas.
- Managing geo-replication.
- Displaying the cluster configuration and credentials.

{{site.data.reuse.openshift_only_note}}

To install the {{site.data.reuse.short_name}} CLI:

1. Ensure you have the IBM Cloud Pak CLI (`cloudctl`) installed either by [retrieving the binary from your cluster](https://www.ibm.com/support/knowledgecenter/en/SSHKN6/cloudctl/3.x.x/install_cli.html){:target="_blank"} or [downloading the binary from a release on the GitHub project](https://github.com/IBM/cloud-pak-cli/releases){:target="_blank"}.\\
   **Note:** Ensure you download the correct binary for your architecture and operating system.
2. [Log in](../../getting-started/logging-in/) to your {{site.data.reuse.short_name}} instance as an administrator.
3. Click **Toolbox** in the primary navigation.
4. Go to the **{{site.data.reuse.long_name}} command-line interface** section and click **Find out more**.
5. Download the {{site.data.reuse.short_name}} CLI plug-in for your system by using the appropriate link.
6. Install the plugin using the following command:
   ```shell
   cloudctl plugin install <path-to-plugin>
   ```

To start the {{site.data.reuse.short_name}} CLI and check all available command options in the CLI, use the `cloudctl es` command.
For an exhaustive list of commands, you can run:
```shell
cloudctl es --help
```

To get help for a specific command, run:
```shell
cloudctl es <command> --help
```

To run commands after installing, log in and initialize the CLI as described in [logging in](../../getting-started/logging-in/).

## Firewall and load balancer settings

In your firewall settings, ensure you enable communication for the endpoints that {{site.data.reuse.short_name}} services use.

If you have load balancing set up to manage traffic for your cluster, ensure that it is set up to handle the {{site.data.reuse.short_name}} endpoints.

On the {{site.data.reuse.openshift_short}}, {{site.data.reuse.short_name}} uses routes.
If you are using OpenShift, ensure your [router](https://docs.openshift.com/container-platform/4.12/networking/routes/route-configuration.html){:target="_blank"} is set up as required.

On other Kubernetes platforms, {{site.data.reuse.short_name}} uses ingress for [external access](../configuring/#configuring-access). You can configure ingress to provide load balancing through an ingress controller. Ensure your [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/){:target="_blank"} is set up as required for your Kubernetes platform.

## Connecting clients

For instructions about connecting a client to your {{site.data.reuse.short_name}} instance, see [connecting clients](../../getting-started/connecting).

## Setting up access

Secure your installation by [managing the access](../../security/managing-access/) your users and applications have to your {{site.data.reuse.short_name}} resources.

For example, if you are using {{site.data.reuse.icpfs}}, associate your {{site.data.reuse.fs}} teams with your {{site.data.reuse.short_name}} instance to grant access to resources based on roles.

## Scaling your Kafka Environment

Depending on the size of the environment that you are installing, consider scaling and sizing options. You might also need to change scale and size settings for your services over time. For example, you might need to add additional Kafka brokers over time.

See [how to scale your Kafka environment](../../administering/scaling).

## Considerations for GDPR readiness

Consider [the requirements for GDPR](../../security/gdpr-considerations/), including [encrypting your data](../../security/encrypting-data/) for protecting it from loss or unauthorized access.
