---
title: "Gathering logs"
excerpt: "To help IBM support troubleshoot any issues with your Event Streams installation, run the log gathering script."
categories: troubleshooting
slug: gathering-logs
toc: true
---

To help IBM Support troubleshoot any issues with your {{site.data.reuse.long_name}} instance, use the `oc adm must-gather` command to capture the [must gather logs](https://docs.openshift.com/container-platform/4.11/support/gathering-cluster-data.html){:target="_blank"}. The logs are stored in a folder in the current working directory.

## Online environments

To gather diagnostic logs in an online environment:

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to capture the logs:

   `oc adm must-gather --image=icr.io/cpopen/ibm-eventstreams-must-gather -- gather -m eventstreams -n <namespace>`

To gather system level diagnostics in addition to the {{site.data.reuse.short_name}} information:

1. {{site.data.reuse.openshift_cli_login}}
2. Run the following command to capture the logs:

   `oc adm must-gather --image=icr.io/cpopen/ibm-eventstreams-must-gather -- gather -m system,eventstreams -n <namespace>`

These logs are stored in an archive file in a folder in the current working directory.
For example, the must-gather archive could be located on the path:
```
must-gather.local.6409880158745169979/icr-io-cpopen-ibm-eventstreams-must-gather-sha256-23a438c8f46037a72b5378b29decad00e871d11f19834ba75b149326847e7c05/cloudpak-must-gather-20200624100001.tgz
```

## Air-gapped (offline) environments

To gather diagnostic logs in an air-gapped (also referred to as offline or disconnected) environment:

1. Pull the {{site.data.reuse.short_name}} `must-gather` image as follows:

   `docker pull icr.io/cpopen/ibm-eventstreams-must-gather`

2. Tag the image:

   `docker image -t icr.io/cpopen/ibm-eventstreams-must-gather <private-registry-image-address:tag>`

3. Push the tagged image to the internal registry of your air-gapped environments:

   `docker push <private-registry-image-address:tag>`

4. {{site.data.reuse.openshift_cli_login}}
5. Run the following command to capture the logs:

   `oc adm must-gather --image=<image-location-on-internal-registry> -- gather -m system,eventstreams -n <namespace>`

   After completing successfully, the command will store the logs in an archive file in a folder in the current working directory.
