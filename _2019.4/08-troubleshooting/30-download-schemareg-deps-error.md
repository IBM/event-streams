---
title: "Error when downloading Java dependencies for schema registry in 2019.4.2"
excerpt: "The link to download the Java dependencies for working with the schema registry is broken."
categories: troubleshooting
slug: schemaregistry-java-deps-download-error
layout: redirects
toc: true
---

## Symptoms

![{{site.data.reuse.short_name}} 2019.4.2 icon](../../../images/2019.4.2.svg "In {{site.data.reuse.short_name}} 2019.4.2.") In {{site.data.reuse.short_name}} 2019.4.2, when clicking on the link to download the schema registry Java dependencies .zip file, a network error is returned and no file is downloaded.

The link appears in the following scenario when you are [preparing Java applications](../../schemas/setting-java-apps/#preparing-the-setup) to be used with a schema:

1. You have selected a schema, clicked the **Connect to this version** button.
2. You have provided or generated an API key.
3. You have clicked **Generate connection details**.
4. You have downloaded the Java truststore file which contains the server certificate.
5. In section **2. Download the schema registry dependencies or configure Maven to install dependencies in your project**, you have clicked the **Use JARs** tab and clicked **Java dependencies** to download the {{site.data.reuse.short_name}} schema registry JAR files to use for your application.

   A **File not found** error is displayed, and no file download option is displayed.

## Cause

The link published in the {{site.data.reuse.short_name}} 2019.4.2 UI is incorrect.

## Resolving the problem

1. Right-click on the existing link and select the option to copy the link.
2. Open a new browser tab.
3. Paste the copied link into the address bar and change the file name `2019.4.2` to `2019.4.1` in the URL: `/dependencies-2019.4.1-java.zip`
4. Submit the URL by pressing enter.

You can now download the 2019.4.1 version of the dependencies, which are fully functional with 2019.4.2 as well.
