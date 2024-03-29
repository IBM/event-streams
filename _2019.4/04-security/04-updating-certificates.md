---
title: "Updating certificates"
excerpt: "Learn about how to update the certificates in an existing Event Streams cluster."
categories: security
slug: updating-certificates
layout: redirects
toc: true
---

{{site.data.reuse.short_name}} uses the following certificates for security:
- External: sets the certificate to use for accessing {{site.data.reuse.short_name}} resources such as Kafka or the REST API (set by `global.security.externalCertificateLabel`, see table later).

   You can set the external certificates when [installing](../../installing/configuring/#secure-connection-settings) {{site.data.reuse.short_name}}.

   You can also change the certificates later for existing {{site.data.reuse.short_name}} installations. This might be required for security reasons when certificates expire or need to be replaced for compliance updates, for example.

<!-- - UI: sets the certificate the UI uses for access authentication (set by `global.security.uiCertificateLabel`, see table later). -->
- Internal: sets the certificate used for the [internal TLS](../../installing/planning/#securing-communication-between-pods) encryption between pods (set by `global.security.internalCertificateLabel`, see table later).

   [Upgrading](../../installing/upgrading/) your {{site.data.reuse.short_name}} version to 2019.4.1 also updates your internal certificates automatically. You can manually change your internal certificates later. Internal certificates can only be self-generated certificates, they cannot be provided.


## Changing certificates for existing installations

To update certificates for an existing {{site.data.reuse.short_name}} installation, use the following `helm upgrade` command:

`helm upgrade --reuse-values --set <certificate label>=<a unique string> <release_name> <charts.tgz> --tls`

where

- `<certificate label>` is one of the following:

| Certificate label                    | Certificate to update  |
|--------------------------------------|-------------------|
| global.security.externalCertificateLabel             |  External TLS certificates<br>For example, Kafka bootstrap ports, REST producer, REST API, and so on. |
| global.security.internalCertificateLabel             | Internal TLS certificates<br>Used for the [internal TLS](../../installing/planning/#securing-communication-between-pods) encryption between pods. |

<!-- | global.security.uiCertificateLabel   | UI TLS certificates | -->

- `<a unique string>` is a different value from the last one provided at the time of installation or the previous update. The certificate labels are strings and can contain any values that are permitted in [Kubernetes labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/){:target="_blank"} (for example, no spaces are permitted).
- `<release_name>` is the name that identifies your {{site.data.reuse.short_name}} installation.
- `<charts.tgz>` is the chart file used to install {{site.data.reuse.short_name}}, which needs to be [available](../../administering/helm-upgrade-command/) when running Helm upgrade commands.

For example:

`helm upgrade --reuse-values --set global.security.externalCertificateLabel=upgradedlabel1 eventstreams1 ibm-eventstreams-prod-1.4.0.tgz --tls`

<!-- You can update multiple certificates in a single upgrade by specifying values for more than one of the labels. For example, you can update both the external and internal certificate labels at the same time by running the following command to update both `global.security.externalCertificateLabel` and the `global.security.uiCertificateLabel` values to trigger the update for all the pods.

`helm upgrade --reuse-values --set global.security.externalCertificateLabel=upgradedlabel1 --set global.security.uiCertificateLabel=upgradedlabel2 eventstreams1 ibm-eventstreams-prod-1.4.0.tgz --tls`
-->

### Specifying certificate type

You can also specify the type of certificate you want to use with the `tls.type` option:
- `selfsigned`
- `provided`
- `secret`

The default is `selfsigned`, which means the certificates are automatically generated by {{site.data.reuse.short_name}} (self-generated). If you have not changed the certificate type and want to continue to use `selfsigned`, you do not have to specify the `tls.type` when running the `helm upgrade` command. If you want to use a different type, specify the `tls.type` when running the command, for example, `tls.type=provided`.

If you want to update the certificates with ones you provide, you set the certificate labels as described earlier, and also set the following:

- `tls.type`: Type of certificate, specify `provided` or `secret` if providing your own (default is `selfsigned` which automatically generates the certificates when installing {{site.data.reuse.short_name}}).
- `tls.secretName`: If you set `tls.type` to `secret`, enter the name of the secret that contains the certificates to use.
- `tls.key`: If you set `tls.type` to `provided`, this is the base64-encoded TLS key or private key. If set to `secret`, this is the key name in the secret (default key name is “key”).
- `tls.cert`: If you set `tls.type` to `provided`, this is the base64-encoded public certificate. If set to `secret`, this is the key name in the secret (default key name is “cert”).
- `tls.cacert`: If you set `tls.type` to `provided`, this is the base64-encoded Certificate Authority Root Certificate. If set to `secret`, this is the key name in the secret (default key name is “cacert”).

For example, when using type `provided`, use the following command:

`helm upgrade --reuse-values --set tls.type=provided --set tls.key=<key> --set tls.cert=<public-certificate> --set tls.cacert=<CA-root-certificate> <certificate label>=<a unique string> <release_name> <charts.tgz> --tls`

**Note:** The internal TLS certificates can only be self-generated.


## Updating clients after certificate change

In some cases, updating the external TLS certificates can prevent existing clients from accessing the cluster. See the following scenarios to see if you need to update your clients after a certificate change.

To update your client settings after a certificate change, see how to [secure the connection](../../getting-started/client/#securing-the-connection).

### If you upgraded your {{site.data.reuse.short_name}} version

If you have clients using certificates from a previous {{site.data.reuse.short_name}} installation, see the following for guidance about when you need to update client certificates:

- If you have been using self-generated certificates and upgrade your {{site.data.reuse.short_name}} version from 2019.2.1 or earlier to 2019.4.1, but do not update your external certificates, then your clients will continue to work with {{site.data.reuse.short_name}}.

   If you change your external certificates after upgrading to 2019.4.1, then you need to provide the new certificates to your clients when you first change them.

   Any subsequent self-generated certificate change will not affect the clients, and they will continue to work with {{site.data.reuse.short_name}}.
- If you have been using certificates you provided, and you change the certificates after an upgrade, then the clients will continue to work as long as the changed certificates are signed by the same Certificate Authority.
- If you change the certificate type, for example, from self-generated to provided, you will need to update your clients.

### If you installed 2019.4.1 as a new deployment

If you have clients using certificates from a {{site.data.reuse.short_name}} 2019.4.1 installation that was a new deployment (not an upgrade from a previous version), see the following for guidance about when you need to update client certificates:

- If you installed {{site.data.reuse.short_name}} 2019.4.1 as a new deployment with self-signed certificates, your clients will continue to work if you change the certificates and continue to use self-signed certificates.
- If you installed {{site.data.reuse.short_name}} 2019.4.1 as a new deployment with provided certificates, your clients will continue to work if you change the certificates as long as the changed certificates are signed by the same Certificate Authority.
- If you change the certificate type, for example, from self-generated to provided, you will need to update your clients.
