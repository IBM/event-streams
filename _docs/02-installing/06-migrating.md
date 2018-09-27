---
title: "Migrating to IBM Event Streams"
permalink: /installing/migrating/
excerpt: "Migrate from the Community Edition to IBM Event Streams."
last_modified_at: 2018-07-22T11:22:01-05:00
toc: false
---

You can migrate from the {{site.data.reuse.ce_long}} to {{site.data.reuse.long_name}}.

Migrating involves removing your previous {{site.data.reuse.ce_short}} installation and installing {{site.data.reuse.long_name}} in the same namespace and using the same release name. Using this procedure,
your settings and data are also migrated to the new installation if you had persistent volumes enabled previously.

1. {{site.data.reuse.icp_cli_login}}
2. Delete the {{site.data.reuse.ce_short}} installation, making a note of the namespace and release name:\\
   `helm delete --purge <release_name>`\\
This command does not delete the PersistentVolumeClaim (PVC) instances. Your PVCs are reused in your new {{site.data.reuse.long_name}} installation with the same release name.
3. [Install {{site.data.reuse.long_name}}](../installing) in the same namespace and using the same release name as used for your previous  {{site.data.reuse.ce_short}} installation. Ensure you select the `ibm-eventstreams-prod` chart, and apart from the namespace and release name, also ensure you retain the same configuration settings you used for your previous installation, such as persistent volume settings.

{{site.data.reuse.long_name}} is installed with the configuration settings and data migrated from the {{site.data.reuse.ce_short}} to your new {{site.data.reuse.long_name}} installation.
