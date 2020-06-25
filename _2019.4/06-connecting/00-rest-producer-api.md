---
title: "Event Streams producer API"
excerpt: "Use the Event Streams producer API to connect other systems to your Kafka cluster."
categories: connecting
slug: rest-api
toc: true
---

{{site.data.reuse.short_name}} provides a REST API to help connect your existing systems to your {{site.data.reuse.short_name}} Kafka cluster. Using the API, you can integrate {{site.data.reuse.short_name}} with any system that supports RESTful APIs.

The REST producer API is a scalable REST interface for producing messages to {{site.data.reuse.short_name}} over a secure HTTP endpoint. Send event data to {{site.data.reuse.short_name}}, utilize Kafka technology to handle data feeds, and take advantage of {{site.data.reuse.short_name}} features to manage your data.

Use the API to connect existing systems to {{site.data.reuse.short_name}}, such as IBM Z mainframe systems with IBM z/OS Connect, systems using IBM DataPower Gateway, and so on.

## About authorization

{{site.data.reuse.short_name}} uses API keys to authorize writing to topics. For more information about API keys and associated service IDs, see the information about [managing access](../../security/managing-access/).

The REST producer API requires the API key to be provided with each REST call to grant access to the requested topic. This can be done in one of the following ways:
1. **In an HTTP authorization header**: \\
   You can use this method when you have control over what HTTP headers are sent with each call to the REST producer API. For example, this is the case when the API calls are made by code you control.
2. **Embedded into an SSL client certificate** (also referred to as **SSL client authentication** or **SSL mutual authentication**):\\
   You can use this method when you cannot control what HTTP headers are sent with each REST call. For example, this is the case when you are using third-party software or systems such as CICS events over HTTP.

**Note:** You must have {{site.data.reuse.short_name}} version 2019.1.1 or later to use the REST API. In addition, you must have {{site.data.reuse.short_name}} version 2019.4.1 or later to use the REST API with SSL client authentication.

## Prerequisites

To be able to produce to a topic, ensure you have the following available:
- The URL of the {{site.data.reuse.short_name}} API endpoint, including the port number.
- The topic you want to produce to.
- The API key that gives permission to connect and produce to the selected topic.
- The {{site.data.reuse.short_name}} certificate.
- If using SSL client authentication, a client private key and certificate signed by {{site.data.reuse.short_name}}. See the information about [creating an SSL client certificate](#create-an-ssl-client-certificate) later for details about how to create and sign an SSL client key and certificate.

To retrieve the full URL for the {{site.data.reuse.short_name}} API endpoint, you can use the {{site.data.reuse.short_name}} CLI or UI.

Using the CLI:
1. Ensure you have the {{site.data.reuse.short_name}} CLI [installed](../../installing/post-installation/#installing-the-command-line-interface-cli).
2. {{site.data.reuse.icp_cli_login321}}
3. Run the following command to initialize the {{site.data.reuse.short_name}} CLI: `cloudctl es init`.\\
   If you have more than one {{site.data.reuse.short_name}} instance installed, select the one where the topic you want to produce to is.\\
   Details of your {{site.data.reuse.short_name}} installation are displayed.
4. Copy the full URL of the desired endpoint, including the port number. If using HTTP authorization, use the `Event Streams API endpoint` field. For SSL client authentication, use the `Event Streams SSL client auth endpoint` field.

Using the UI:
1. {{site.data.reuse.es_ui_login_nonadmin}}
2. Click **Connect to this cluster** on the right.
3. Go to the **Resources** tab.
4. Scroll down to the **API endpoint** section.
5. Click **Copy API endpoint**.

To create a topic and generate an API key with produce permissions, and to download the certificate:
1. If you have not previously created the topic, create it now:\\
   `cloudctl es topic-create --name <topic_name> --partitions 1 --replication-factor 3`
2. Create a service ID and generate an API key:\\
   `cloudctl es iam-service-id-create --name <serviceId_name> --role editor --topic <topic_name>`\\
   For more information about roles, permissions, and service IDs, see the information about [managing access](../../security/managing-access/).
3. Copy the API key returned by the previous command.
4. Download the server certificate for {{site.data.reuse.short_name}}:\\
   `cloudctl es certificates --format pem` \\
   By default, the certificate is written to a file called `es-cert.pem`.

### Key and message size limits

The REST producer API has a configured limit for the key size (default is `4096` bytes) and the message size (default is `65536` bytes). If the request sent has a larger key or message size than the limits set, the request will be rejected.

![Event Streams 2019.4.2 icon](../../../images/2019.4.2.svg "In Event Streams 2019.4.2.") **Important:** In {{site.data.reuse.short_name}} 2019.4.2, you can configure the key and message size limits at the time of [installation](../../installing/configuring/#-rest-producer-api-settings) or later as described in [modifying](../../administering/modifying-installation/) installation settings. You can set the limit values in the **REST producer API settings** section if using the UI, or use the `rest-producer.maxKeySize` and `rest-producer.maxMessageSize` parameters if using the CLI.

In {{site.data.reuse.short_name}} 2019.4.1 and earlier versions, you can update the limits as follows:

1. Ensure you have the {{site.data.reuse.short_name}} CLI [installed](../../installing/post-installation/#installing-the-command-line-interface-cli).
2. {{site.data.reuse.icp_cli_login321}}
3. List the {{site.data.reuse.short_name}} deployments: `kubectl get deployments`
4. Identify the REST producer deployment in the list.\\
   It will be similar to `<deployment_name>-ibm-es-rest-producer-deploy`.
5. Edit the REST producer deployment:\\
   `kubectl edit deployment <deployment_name>-ibm-es-rest-producer-deploy`
6. In the `.yaml` file Locate the `env` section for the REST producer container under `spec.template.spec.containers`.
7. Add the following environment variables as required:\\
   - `MAX_KEY_SIZE`: Sets the maximum key size in bytes (default is `4096`).
   - `MAX_MESSAGE_SIZE`: Sets the maximum message size in bytes (default is `65536`).

   **Important:** Do not set the `MAX_MESSAGE_SIZE` to a higher value than the maximum message size that can be received by the Kafka broker or the individual topic (`max.message.bytes`). By default, the maximum message size for Kafka brokers is `1000012` bytes. If the limit is set for an individual topic, then that setting overrides the broker setting. Any message larger than the maximum limit will be rejected by Kafka.

   **Note:** Sending large requests to the REST producer increases latency, as it will take the REST producer longer to process the requests.

8. Save your changes and wait for the REST producer pod to be updated.\\
   **Note:** If you upgrade your {{site.data.reuse.short_name}} version, you will have to apply these environment variables again.

## Producing messages using REST with HTTP authorization

Ensure you have gathered all the details required to use the producer API, as described in the [prerequisites](#prerequisites).

You can use the usual languages for making the API call. For example, to use cURL to produce messages to a topic with the producer API, run the `curl` command as follows:

`curl -v -X POST -H "Authorization: Bearer <api_key>" -H "Content-Type: text/plain" -H "Accept: application/json" -d 'test message' --cacert es-cert.pem "<api_endpoint>/topics/<topic_name>/records"`

Where:
- `<api_key>` is the API key you generated earlier.
- `<api_endpoint>` is the full URL copied from the `Event Streams API endpoint` field earlier (format `https://<host>:<port>`).
- `<topic_name>` is the name of the topic you want to produce messages to.

For full details of the API, see the [API reference](../../api/){:target="_blank"}.

## Producing messages using REST with SSL client authentication

In cases where you cannot manipulate the HTTP headers being sent with each REST call, using an SSL client certificate instead allows the API key to be provided when the REST client opens a TLS connection to {{site.data.reuse.short_name}}. In this scenario, {{site.data.reuse.short_name}} acts as the signing authority for the client certificate, not only signing the certificate signing request, but also embedding the encrypted API key into the resulting certificate. This way, {{site.data.reuse.short_name}} can verify that it trusts the client system, and it can authorize access to the requested topic through the embedded API key.

Before continuing with the instructions in the following sections, ensure you have gathered all the details required to use the producer API, as described in the [prerequisites](#prerequisites).

### Create an SSL client certificate

Creating and deploying an SSL client certificate is a one-off procedure that you must do before any messages can be sent from the client system.

**Note:** SSL security technology can be a complex topic and it is beyond the scope of this documentation to provide a full description of all its features and mechanisms. For an overview of SSL and TLS, see the [IBM MQ documentation](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.sec.doc/q009910_.htm){:target="_blank"}.

The following is a simplified set of instructions based on the widely-used [OpenSSL](https://www.openssl.org/){:target="_blank"} toolkit:
1.  Create a private key and an associated certificate signing request (CSR): \\
    `openssl req -new -newkey rsa:4096 -nodes -keyout es-client.key -out es-client.csr`

    This writes the private key to `es-client.key` and the CSR to `es-client.csr` in PEM format. You can provide any identifying information for the CSR subject, common name, or subject alternative names.

    **Note**: {{site.data.reuse.short_name}} does not perform host name verification when it receives the certificate.

    Java users can create CSRs using the `keytool -certreq ...` command as described in the [IBM SDK, Java Technology Edition documentation](https://www.ibm.com/support/knowledgecenter/en/SSYKE2_7.0.0/com.ibm.java.security.component.70.doc/security-component/keytoolDocs/certreq.html){:target="_blank"}. CICS users can use RACF by following the steps described in the [CICS Transaction Server documentation](https://www.ibm.com/support/knowledgecenter/en/SSGMCP_5.4.0/security/tcpip/dfht5_requestcert.html){:target="_blank"}.
2. Call the {{site.data.reuse.short_name}} CLI to sign the CSR and embed the API key. For example, you can do this by using the files created in the previous step and the API key created as mentioned in [prerequisites](#prerequisites) earlier:\\
    `cloudctl es sign-clientauth-csr --in es-client.csr --api-key <api-key> --out es-client.pem`

    This creates the client certificate in `es-client.pem` in PEM format. The `sign-clientauth-csr` CLI command expects and produces PEM files by default, but the DER format is also supported by using the `--in-format` and `--out-format` parameters.

### Verify your client certificate

You can test the validity of your client certificate and private key before configuring your client system by running the following `wget` command to produce a test mesage to the topic:

`wget -qSO- --content-on-error --certificate=<client-cert> --private-key=<client-key> --ca-cert=<es-cert> --header 'Content-Type: text/plain' --post-data='some test data' <client-auth-endpoint>/topics/<topic-name>/records`

Where:
- `<client-cert>` is the SSL client certificate file in PEM format.
- `<client-key>` is the private key file for the SSL client certificate in PEM format.
- `<es-cert>` is the {{site.data.reuse.short_name}} server certificate file in PEM format.
- `<client-auth-endpoint>` is the client authentication API endpoint.
- `<topic-name>` is the topic to be written to.

### Produce messages with an SSL client certificate

Consult the documentation for your system to understand how to specify the client certificate and private key for the outgoing REST calls to {{site.data.reuse.short_name}}. You also need to add the {{site.data.reuse.short_name}} server certificate to the list of trusted certificates used by your system (this is the certificate downloaded as part of the [prerequisites](#prerequisites)).

For example, the steps to configure a CICS URIMAP as an HTTP client is described in the  [CICS Transaction Server documentation](https://www.ibm.com/support/knowledgecenter/en/SSGMCP_5.4.0/applications/developing/web/dfhtl_urioutbound.html){:target="_blank"}. In this case, load the client certificate and private key, together with the {{site.data.reuse.short_name}} server certificate into your RACF key ring. When defining the URIMAP:
- `Host` is the client authentication API endpoint obtained as part of the [prerequisites](#prerequisites), without the leading `https://`
- `Path` is `/topics/<topic-name>/records`
- `Certificate` is the label given to the client certificate when it was loaded into the key ring.

If you are using Java keystores, the client certificate can be imported by using the `keytool -importcert ...` command as described in the [IBM SDK, Java Technology Edition documentation](https://www.ibm.com/support/knowledgecenter/en/SSYKE2_7.0.0/com.ibm.java.security.component.70.doc/security-component/keytoolDocs/importcert.html){:target="_blank"}.

Some systems require the client certificate and private key to be combined into one PKCS12 file (with extension `.p12` or `.pfx`). For example, the following command creates a PKCS12 file from the client certificate and private key files created earlier:\\
  `openssl pkcs12 -export -inkey es-client.key -nodes -in es-client.pem -name my-client-cert -out es-client.p12`

`my-client-cert` is an arbitrary name or alias given to the client certificate in the PKCS12 file. You will be asked to specify a password to protect the certificate in the file. You will need to provide this, as well as the alias, when configuring your system.

For full details of the API, see the [API reference](../../api/){:target="_blank"}.

<!--
To create a topic and API key with produce permissions by using the UI:
1. Log in to your {{site.data.reuse.short_name}} UI.
2. Click the **Topics** tab.
3. Select the topic you want to produce to. If you have not previously created the topic, create it now by clicking **Create topic**.
4. Click **Connect to this topic** on the right.
6. On the **Connect a client** tab, go to the **API key** section, and follow the instructions to generate an API key authorized to connect to the cluster and produce to the topic. Ensure you select **Produce only**. The name of the selected topic is filled in automatically.
-->
