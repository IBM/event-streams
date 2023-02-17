---
title: "Verifying container image signatures"
excerpt: "Verify your CISO image signatures."
categories: security
slug: verifying-signature
toc: true
---

Digital signatures provide a way for consumers of content to ensure that what they download is both authentic (it originated from the expected source) and has integrity (it is what we expect it to be). All images for the {{site.data.reuse.long_name}} certified container in the IBM Entitled Registry are signed following the approach from Red Hat.

You can use the signature to verify that the images came from IBM when they are pulled onto the system.

## Before you begin

- Ensure that the following command-line tools are installed on your computer. On Linux systems, these images can typically be installed by using the package manager.

   - [The OpenShift Container Platform CLI](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html){:target="_blank"}
   - [The IBM Cloud Pak CLI (`cloudctl`)](https://github.com/IBM/cloud-pak-cli){:target="_blank"}
   - [GNU Privacy Guard (GnuPG) version 2](https://gnupg.org/){:target="_blank"}
   - [Skopeo](https://github.com/containers/skopeo){:target="_blank"}

- On the computer where the command-line tools are installed, copy the following version-specific text block exactly as shown into a text editor, and save it in a file named `acecc-public.gpg`. The following text block represents the {{site.data.reuse.long_name}}-certified container public key in the GNU Privacy Guard format.

  **Note:** Applicable to {{site.data.reuse.short_name}} 11.1.2 and later versions.

  ```
  -----BEGIN PGP PUBLIC KEY BLOCK-----

  mQENBGBrpIABCADxLPV/YhEj6blOKRfnKmvE3XJ+klHksVOHgVq58nYYVuQNcC+d
  BFEK0digo31ZsIk2z8im05jP6Ky/q2SB8aKeHu1F5dyHgkA51iIKEOkXHdi+g+Mo
  WfmVKX5sL78dBF/zb4StyjipQJEEKUYlGieOQlVOvCkq6ywB+du9IiFB2HtSytYG
  pkWAwIAoNGZfWJDi7fUCxSGeMhFq+boWBmMeh6UutWL+y2ZmQIMHBtezIQfsAh13
  heLzkzO5V8SRH7uH16FVSbg0WtDXx6oebMWqn3uArxmlwLKb8uVrlIeSKYULRogn
  1VrzE4QjQBMtR9+E76NCj3Rh+8k/+fOYzb+rABEBAAG0GjI2NVF1aW5uaXBpYWNt
  YXkxOHNpZ24xcGZ4iQE5BBMBCAAjBQJga6SAAhsvBwsJCAcDAgEGFQgCCQoLBBYC
  AwECHgECF4AACgkQAZ+SMbnIU6k1wAgAkmDJEq4DHZqeX68YtKiwxNLrkt2BnGPW
  /PL7/CveBvRhRyM43neDOY59l+CgsYWaHIVzXyfMJs8HkO0ccozYbh75uTMEFrHu
  IiHyuE+BD+dGKe+nBwdJcM4coAVFYaCLMRas8qz4Pkxyxk0nV1aY1jnaXzxaD1vQ
  agQqGhF9I+i+JSl8eRiYj3lLLcoNkRBK3g5b6Q5vgBFBrhvvnSdxzsLOK2Wa+tu6
  SW9QZfYaUGvMSbHGcLwfBloojAUOrX6wTwxb3W77/aVPg5+QMy7P6GwHBhWgMquV
  AL+KY8BfBeFy5osKzDl1S/cTGT/Tk/z18NHZaR3D9hT4klax8B+vYA==
  =pDAx
  -----END PGP PUBLIC KEY BLOCK-----
  ```

## Obtaining the container images

Obtain the list of {{site.data.reuse.short_name}}-certified container images to verify as described in the following sections.

### Prepare your bastion host
Ensure you meet the following prerequisites before downloading the CASE archive and obtaining the images:
  - A computer with internet access on which you can run the required commands. This computer must also have access to the cluster, and is referred to as a **bastion host**.
  - A cluster that is already set up and running a supported version of the {{site.data.reuse.openshift}}. For more information, see the [support matrix](https://ibm.github.io/event-streams/support/#support-matrix) for supported versions.
  - A private Docker registry that can be accessed by the cluster and the bastion host, and which will be used to store all images on your restricted network.

If the cluster has a bastion host which has access to the public internet, then the following steps can be performed from the bastion host.

**Note**: In the absence of a bastion host, prepare a portable device that has access to the public internet to download the CASE archive and images, and also has access to the target registry where the images will be mirrored.

### Download the CASE archive
Download the Container Application Software for Enterprises (CASE) archive. This archive, which is typically provided for installing within a restricted network, includes metadata and files that you will require later.

Complete the following steps to download the CASE archive:

  1. {{site.data.reuse.openshift_cli_login}}
  1. Create a local directory to save the CASE archive.
  ```
  $ mkdir /tmp/cases
  ```
  2. Run the following command to download, validate, and extract the CASE archive.
  ```
  $ cloudctl case save --case <path-to-case-archive> --outputdir /tmp/cases
  ```
  Where `<path-to-case-archive>` is the location of the CASE archive. If you are running the command from the current location, set the path to the current directory (`.`).
  The following output is displayed:
  ```
  Downloading and extracting the CASE ...
  - Success
  Retrieving CASE version ...
  - Success
  Validating the CASE ...
  - Success
  Creating inventory ...
  - Success
  Finding inventory items
  - Success
  Resolving inventory items ...
  Parsing inventory items
  - Success
  ```
  3. Verify that the CASE archive and images `.csv` files have been generated for the {{site.data.reuse.short_name}} and the {{site.data.reuse.icpfs}}. For example, ensure you have the following files for the {{site.data.reuse.short_name}} along with files generated for the {{site.data.reuse.icpfs}} CASE.

      ```
      $ ls /tmp/cases/
      total 328
      drwxr-xr-x  2 user  staff      64  5 Jun 10:57 charts
      -rw-r--r--  1 user  staff      32  5 Jun 10:57 ibm-eventstreams-1.1.2-charts.csv
      -rw-r--r--  1 user  staff    4842  5 Jun 13:34 ibm-eventstreams-1.1.2-images.csv
      -rw-r--r--  1 user  staff  155586  5 Jun 10:57 ibm-eventstreams-1.1.2.tgz
      ```

### Obtain the files

1\. After meeting the required prerequisites and downloading the CASE archive, obtain the following files:

- The downloaded CASE archives, which contain metadata for the container images required to deploy each {{site.data.reuse.short_name}} capability. Each CASE archive also contains the required scripts to mirror images to a private registry, and to configure the target cluster to use the private registry as a mirror.
- Generated comma-separated value (CSV) files listing the images. Obtain an IBM Entitled Registry entitlement key from the [IBM Container software library](https://myibm.ibm.com/products-services/containerlibrary){:target="_blank"}. The CSV files, combined with your entitlement key, are used for downloading or mirroring the images manually.

   To verify the image signatures for a {{site.data.reuse.short_name}}-certified container, use the file that is named in the format `ibm-eventstreams-<v.r.m>-images.csv`, where `v.r.m` represents the {{site.data.reuse.short_name}} CASE version.

2\. Use a shell script to parse through the CSV file and print out the list of "manifest list images" with their digests or tags. You can use the listed names when pulling and verifying image signatures. In the `tail` command, `/tmp/cases` represents the directory where you downloaded the CASE archive.

 - List images by digest:
      ```
      tail -q -n +2 /tmp/cases/ibm-eventstreams-*-images.csv | while IFS="," read registry image_name tag digest mtype os arch variant insecure digest_source image_type groups; do
      if [[ "$mtype" == "LIST" ]]; then
          echo "$registry/$image_name@$digest"
      fi
      done
      ```

 - List images by tag:
      ```
      tail -q -n +2 /tmp/cases/ibm-eventstreams-*-images.csv | while IFS="," read registry image_name tag digest mtype os arch variant insecure digest_source image_type groups; do
      if [[ "$mtype" == "LIST" ]]; then
          echo "$registry/$image_name:$tag"
      fi
      done
      ```

  **Note**: You can also copy the output to a file for ease of reference while verifying the image signatures.

## Verifying the signature

To verify the image signatures, complete the following steps:

1. Import the {{site.data.reuse.short_name}}-certified container public key on the computer where you saved the public key to a file as described in the [Before you begin](#before-you-begin) section.
    ```
    sudo gpg2 --import acecc-public.gpg
    ```

   **Note**: This step needs to be done only once on each computer that you use for signature verification.

2. Calculate the fingerprint.
    ```
    fingerprint=$(sudo gpg2 --fingerprint --with-colons 265Quinnipiacmay18sign1pfx | grep fpr | tr -d 'fpr:')
    ```

    This command stores the key's fingerprint in an environment variable called `fingerprint`, which is needed for the command to verify the signature.

    **Note:** When you exit your shell session, the variable will be deleted. The next time you log in to your computer, you can set the environment variable again by rerunning the command in this step.

3. Log in to `skopeo` to access the entitled registry. Use `cp` as the username and your entitlement key as the password.
For example:
    ```
    skopeo login cp.icr.io --username cp --password myEntitlementKey
    ```
4. Create a directory (for example, `images`) for the image. Then use `skopeo` to pull the image into local storage, where `imageName` represents the image name.
    ```
    mkdir images
    skopeo copy docker://<imageName> dir:./images
    ```
    For example:
    ```
    mkdir images
    skopeo copy docker://icr.io/cpopen/ibm-eventstreams-catalog:3.0.0-00000000-000000 dir:./images
    ```
    This command downloads the `image` as a set of files and places them in the `images` directory, or in a directory that you specified. A manifest file named `images/manifest.json`, and a set of signature files named `images/signature-1`, `images/signature-2`, and `images/signature-3` are added to the directory. You will use these files to verify the signature in the next step.
5. Verify the signature for each required image, where `imageName` is the name of the image and `signature-N` relates to a format for the name.
    ```
    sudo skopeo standalone-verify ./images/manifest.json <imageName> ${fingerprint} ./images/<signature-N>
    ```
    For example:
    ```
    sudo skopeo standalone-verify ./images/manifest.json icr.io/cpopen/ibm-eventstreams-catalog:3.0.0-00000000-000000 ${fingerprint} ./images/signature-1
    ```
    You will receive a confirmation similar to the following:
    ```
    Signature verified, digest sha256:0000000000000000000000000000000000000000000000000000000000000000
    ```
