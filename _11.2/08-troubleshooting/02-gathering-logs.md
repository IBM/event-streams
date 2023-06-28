---
title: "Gathering logs"
excerpt: "To help IBM support troubleshoot any issues with your Event Streams installation, run the log gathering script."
categories: troubleshooting
slug: gathering-logs
layout: redirects
toc: true
---

To help IBM Support troubleshoot any issues with your {{site.data.reuse.long_name}} installation, run the log gathering script as follows to capture the logs. The logs are stored in a folder in the current working directory.

## Prerequisites

To run the log gathering script, ensure you have the following installed on your system:
- `yq` command-line YAML processor
- `kubectl` Kubernetes command-line tool (or `oc` if using OpenShift)
- `openssl` command-line tool

## Online environments

To gather logs from an online environment:
1. Clone the Git repository `event-streams-operator-resources` as follows:

   `git clone https://github.com/ibm-messaging/event-streams-operator-resources`

2. Log in to your cluster as a cluster administrator by setting your [`kubectl` context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/){:target="_blank"} or by using the [`oc` CLI](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands){:target="_blank"} (`oc login`) on {{site.data.reuse.openshift_short}}.
3. Change directory to the `/support` folder of the cloned repository.
4. Run the following command:

   ```
   ./event-streams-must-gather -n <instance-namespace> -m <gather-modules> -i <image-address>
   ```
   Where:
   - `<instance-namespace>` is the namespace where your {{site.data.reuse.short_name}} instance is installed, and where the script gathers log data from. You must always specify the namespace.
   - `<gather-modules>` is a comma separated list of modules, where valid values are `eventstreams`, `failure`, `overview`, and `system`. The default value is `eventstreams`.
   - `<image-address>` is the address of the image to use for gathering logs. The default image is `icr.io/cpopen/ibm-eventstreams-must-gather`. You can set a different image if instructed by IBM Support.

The logs gathered are stored in an archive file called `event-streams-must-gather-<timestamp>.tar.gz` which is added to the current working directory.

## Air-gapped (offline) environments

To gather diagnostic logs in an air-gapped (also referred to as offline or disconnected) environment:

1. Pull the {{site.data.reuse.short_name}} `must-gather` image as follows:

   `docker pull icr.io/cpopen/ibm-eventstreams-must-gather`

2. Tag the image:

   `docker image -t icr.io/cpopen/ibm-eventstreams-must-gather <private-registry-image-address:tag>`

3. Push the tagged image to the internal registry of your air-gapped environments:

   `docker push <private-registry-image-address:tag>`

4. Clone the Git repository `event-streams-operator-resources` as follows:

   `git clone https://github.com/ibm-messaging/event-streams-operator-resources`

5. Log in to your cluster as a cluster administrator by setting your [`kubectl` context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/){:target="_blank"} or by using the [`oc` CLI](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands){:target="_blank"} (`oc login`) on {{site.data.reuse.openshift_short}}.

6. Change directory to the `/support` folder of the cloned repository.

7. Run the following command:
```
./event-streams-must-gather -n <instance-namespace> -m <gather-modules> -i <image-address>
```
Where:
- `<instance-namespace>` is the namespace where your {{site.data.reuse.short_name}} instance is installed, and where the script gathers log data from. You must always specify the namespace.
- `<gather-modules>` is a comma separated list of modules, where valid values are `eventstreams`, `failure`, `overview`, and `system`. The default value is `eventstreams`.
- `<image-address>` is the address of the image to use for gathering logs. For an offline environment, this will be the image you have added to your private registry. The default image is `icr.io/cpopen/ibm-eventstreams-must-gather`.

The logs gathered are stored in an archive file called `event-streams-must-gather-<timestamp>` which is added to the current working directory.
