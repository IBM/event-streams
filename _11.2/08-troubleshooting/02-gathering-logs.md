---
title: "Gathering logs"
excerpt: "To help IBM support troubleshoot any issues with your Event Streams installation, run the log gathering script."
categories: troubleshooting
slug: gathering-logs
toc: true
---

To help IBM Support troubleshoot any issues with your {{site.data.reuse.long_name}} installation, run the log gathering script as follows to capture the logs. The logs are stored in a folder in the current working directory.

## Prerequisites

To run the log gathering script, ensure you have the following installed on your system:

- If using OpenShift, the [{{site.data.reuse.openshift_short}} CLI (`oc`)](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html){:target="_blank"} version 4.10 or later.
- If using other Kubernetes platforms, the [Kubernetes command-line tool (`kubectl`)](https://kubernetes.io/docs/tasks/tools/){:target="_blank"} version 1.24 or later.
- The latest 1.1.1 version of [`openssl` command-line tool](https://www.openssl.org/source/){:target="_blank"}.

**Important:** The gather scripts are written in bash. To run the scripts on Windows, ensure that you are running the scripts from a bash prompt. For example, git bash is a suitable shell environment and is available as part of the Git for Windows distribution.

## Online environments

To gather logs from an online environment:

1. Clone the Git repository `ibm-event-automation` as follows:

   `git clone https://github.com/IBM/ibm-event-automation`

2. Log in to your cluster as a cluster administrator by setting your [`kubectl` context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/){:target="_blank"} or by using the [`oc` CLI](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands){:target="_blank"} (`oc login`) on {{site.data.reuse.openshift_short}}.
3. Change directory to the `/support` folder of the cloned repository.
4. Run the `./ibm-events-must-gather` script to capture the relevant logs:

   ```shell
   ./ibm-events-must-gather -n <instance-namespace> -m <gather-modules> -i <image-address>
   ```

   For example:

   ```shell
   ./ibm-events-must-gather -n samplenamespace -m eventstreams
   ```

   Where:
   - `<instance-namespace>` is the namespace where your {{site.data.reuse.short_name}} instance is installed, and where the script gathers log data from.
   - `<gather-modules>` is a comma separated list of [modules](#gather-modules), where valid values are `eventstreams`, `kafka`, `schema`, `failure`, `overview` and `system`.
   - `<image-address>` is the address of the image to use for gathering logs. If `<image-address>` is not specified, then the default image (`icr.io/cpopen/ibm-eventstreams-must-gather`) is set. You can set a different image if instructed by IBM Support.

The logs gathered are stored in an archive file called `ibm-events-must-gather-<timestamp>.tar.gz`, which is added to the current working directory.

## Air-gapped (offline) environments

To gather diagnostic logs in an air-gapped (also referred to as offline or disconnected) environment:

1. Pull the {{site.data.reuse.short_name}} `must-gather` image as follows:

   `docker pull icr.io/cpopen/ibm-eventstreams-must-gather`

2. Tag the image:

   `docker image -t icr.io/cpopen/ibm-eventstreams-must-gather <private-registry-image-address>:<tag>`

3. Push the tagged image to the internal registry of your air-gapped environments:

   `docker push <private-registry-image-address:tag>`

   **Note:** Automatic updates to the `must-gather` image are not supported in an air-gapped environment. Repeat the previous steps frequently to ensure you are gathering logs with the most recent image.
4. Clone the Git repository `ibm-event-automation` as follows:

   `git clone https://github.com/IBM/ibm-event-automation`

5. Log in to your cluster as a cluster administrator by setting your [`kubectl` context](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/){:target="_blank"} or by using the [`oc` CLI](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#cli-logging-in_cli-developer-commands){:target="_blank"} (`oc login`) on {{site.data.reuse.openshift_short}}.

6. Change directory to the `/support` folder of the cloned repository.

7. Run the `./ibm-events-must-gather` script to capture the relevant logs:

   ```shell
   ./ibm-events-must-gather -n <instance-namespace> -m <gather-modules> -i <image-address>
   ```

   For example:

   ```shell
   ./ibm-events-must-gather -n samplenamespace -m eventstreams -i private-registry-image-address:tag
   ```

   Where:
   - `<instance-namespace>` is the namespace where your {{site.data.reuse.short_name}} instance is installed, and where the script gathers log data from.
   - `<gather-modules>` is a comma separated list of [modules](#gather-modules), where valid values are `eventstreams`, `kafka`, `schema`, `failure`, `overview` and `system`.
   - `<image-address>` is the cluster accessible location where you have pushed the must gather image (see step 3).

The logs gathered are stored in an archive file called `ibm-events-must-gather-<timestamp>.tar.gz`, which is added to the current working directory.

## Gather modules

See the following table for information on the modules that are supported by the gather script:

| Module          | Description                                                                                                |  
| --------------- | ---------------------------------------------------------------------------------------------------------- |
|`eventstreams`   | Gathers logs relating to the {{site.data.reuse.short_name}} operator and instances                         |
|`kafka`          | Gathers internal information from the Kafka environment                                                    |
|`schema`         | Gathering internal information from the Schema Registry                                                    |
|`failure`        | Gathers logs relating to unhealthy Kubernetes objects on the cluster                                       |
|`overview`       | General information of the cluster environment                                                             |
|`system`         | Details information of the system, resource usage and network information                                  |
