---
title: "Downloading"
permalink: /installing/downloading/
excerpt: "Download the IBM Event Streams image and make it available to be installed."

toc: false
---

To install {{site.data.reuse.long_name}} (not the {{site.data.reuse.ce_short}}) in your {{site.data.reuse.icp}} instance, you must first download it. Download the {{site.data.reuse.long_name}} installation image file from the IBM Passport Advantage site and make it available to your {{site.data.reuse.icp}} instance.

1. Go to [IBM Passport Advantage](https://www-01.ibm.com/software/passportadvantage/pao_customer.html), and search for {{site.data.reuse.long_name}}. Download the images related to the part numbers.
2. Ensure you [configure your Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_images/configuring_docker_cli.html) to access your cluster.
3. Log in to your cluster from the {{site.data.reuse.icp}} CLI and log in to the Docker private image registry:
   ```
   cloudctl login -a https://<cluster_CA_domain>:8443 --skip-ssl-validation
   docker login <cluster_CA_domain>:8500
   ```
   **Note:** The default value for the `cluster_CA_domain` parameter is `mycluster.icp`. If necessary add an entry to your system's host file to allow it to be resolved. For more information, see [the {{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/installing/install_entitled_workloads.html).
4. Install the {{site.data.reuse.short_name}} Helm chart by using the compressed image you downloaded from IBM Passport Advantage.\\
   `cloudctl catalog load-archive --archive <PPA-image-name.tar.gz>`\\
   When the image installation completes successfully, the catalog is updated with the {{site.data.reuse.long_name}} local chart, and the internal docker repository is populated with the Docker images used by {{site.data.reuse.long_name}}.
5. [Install {{site.data.reuse.long_name}}](../installing).
