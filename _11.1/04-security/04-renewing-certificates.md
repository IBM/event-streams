---
title: "Renewing certificates"
excerpt: "Learn about how to renew the certificates and keys in an existing Event Streams cluster."
categories: security
slug: renewing-certificates
toc: true
---

{{site.data.reuse.short_name}} uses 4 secrets to store the certificate authority (CA) certificates and keys for the cluster.

 Secret Name | Description  |
--|--
\<instance-name\>-cluster-ca | The secret containing the cluster CA private key. This is used to generate the certificates presented at the Event Streams endpoints, and for internal Kafka to Zookeeper connections. |
\<instance-name\>-cluster-ca-cert | The secret containing the  cluster CA certificate. This is used to generate the certificates presented at the Event Streams endpoints, and for internal Kafka to Zookeeper connections. |
\<instance-name\>-clients-ca |  The secret containing the private key used to sign the Mutual TLS `KafkaUser` certificates. These are used by clients connecting to Kafka over a Mutual TLS authenticated listener. |
\<instance-name\>-clients-ca-cert | The secret containing the  CA certificate used to sign the Mutual TLS `KafkaUser` certificates. These are used by clients connecting to Kafka over a Mutual TLS authenticated listener. |

## Renewing auto-generated self-signed CA certificates for existing installations

By default, {{site.data.reuse.short_name}} uses self-signed CA certificates. These are automatically renewed when the default `renewalDays` (default is 30 days) and `validityDays` (default is 365 days) limits are met.

To set exactly when certificates are renewed, you can configure the `renewalDays` and `validityDays` values under the `spec.strimziOverrides.clusterCa` and `spec.strimziOverrides.clientsCa` properties. Validity periods are expressed as a number of days after certificate generation. For more information, see [Certificate renewal and validity periods](https://strimzi.io/docs/operators/0.32.0/configuring.html#con-certificate-renewal-str){:target="_blank"}.

You can define `maintenance windows` to ensure that the renewal of certificates are done at an appropriate time. For more information, see [Maintenance time windows for rolling update](https://strimzi.io/docs/operators/0.32.0/configuring.html#assembly-maintenance-time-windows-str){:target="_blank"}.

You can also use the `strimzi.io/force-renew` annotation to manually renew the certificates. This can be necessary if you need to renew the certificates for security reasons outside of the defined renewal periods and maintenance windows. For more information, see [Manually renewing CA certificates](https://strimzi.io/docs/operators/0.32.0/configuring.html#proc-renewing-ca-certs-manually-str){:target="_blank"}.

**Note:** The configuration settings for renewal periods and maintenance windows, and the annotation for manual renewal only apply to auto-generated self-signed certificates. If you provided your own CA certificates and keys, you must manually renew these certificates as described in the following sections.

## Renewing your own CA certificates for existing installations

If you provided your own CA certificates and keys, and need to renew only the CA  certificate, complete the following steps. The steps provided demonstrate renewing the cluster CA certificate, but the steps are identical for renewing the clients CA certificate, with the exception of the secret name.

1. Generate a new CA certificate by using the existing CA private key. The new certificate must have an identical CN name to the certificate it is replacing. Optionally, create a PKCS12 truststore with the new certificate if required.
2. Replace the value of the `ca.crt` in the `<instance-name>-cluster-ca-cert` secret with a base64-encoded string of the new certificate. Optionally, replace the `ca.p12` and `ca.password` values with the base64-encoded strings if required.
3. Increment the `ca-cert-generation` annotation value in the `<instance-name>-cluster-ca-cert` secret. If no annotation exists, add the annotation, and set the value to `1` with the following command:

   `oc annotate --namespace <namespace> secret <instance-name>-cluster-ca-cert ca-cert-generation=1`

   When the operator reconciles the next time, the pods roll to process the certificate renewal.

## Renewing your own CA certificates and private keys for existing installations

If you provided your own CA Certificates and keys, and need to renew both the CA  certificate and private key, complete the following steps. The steps provided demonstrate renewing the cluster CA certificate and key, but the steps are identical for renewing the clients CA certificate, with the exception of the secret name.

1. Pause the operator's reconcile loop by running the following command:

   `oc annotate Kafka <instance-name> strimzi.io/pause-reconciliation="true" --overwrite=true`

2. Generate a new certificate and key pair. Optionally, create a PKCS12 truststore with the new certificate, if required.
3. Replace the value of the `ca.key` in the `<instance-name>-cluster-ca` secret with a base64-encoded string of the new key.
4. Increment the `ca-key-generation` annotation value in the `<instance-name>-cluster-ca` secret. If no annotation exists, add the annotation, setting the value to `1` with the following command:

   `oc annotate --namespace <namespace> secret <instance-name>-cluster-ca ca-key-generation=1`

5. Find the expiration date and time of the previous CA certificate by using OpenSSL or other certificate tooling.
6. Edit the `<instance-name>-cluster-ca-cert` secret. Rename the `ca.crt` element to be `ca-<expiry of ca.crt>.crt`.

   This will take the format of `ca-YYYY-MM-DDTHH-MM-SSZ.crt` (for example, `ca-2022-05-24T10-20-30Z.crt`). Ensure the value of this element contains the base64-encoded string of the original CA certificate that you are renewing.

7. Add element `ca.crt` to the `<instance-name>-cluster-ca-cert` secret with a base64-encoded string of the new certificate. Optionally, replace the `ca.p12` and `ca.password` values with the base64-encoded strings, if required.
8. Increment the `ca-cert-generation` annotation value in the `<instance-name>-cluster-ca-cert` secret. If no annotation exists, add the annotation, and set the value to `1` with the following command:

   `oc annotate --namespace <namespace> secret <instance-name>-cluster-ca-cert ca-cert-generation=1`

9. Resume the operator's reconcile loop by running the following command:

   `oc annotate Kafka <instance-name> strimzi.io/pause-reconciliation="false" --overwrite=true`

   When the operator reconciles the next time, the pods roll to process the certificate renewal. The pods might roll multiple times during the renewal process.

## Updating clients after certificate change

If you renew the CA certificates, clients might need to update their truststore with the new certificate.

To update your client settings after a certificate change, see how to [secure the connection](../../getting-started/connecting/#securing-the-connection).
