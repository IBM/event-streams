---
title: "Geo-replication fails to start with 'Could not connect to origin cluster' error"
excerpt: "When geo-replicating a topic to a destination cluster with 2 or more geo-replication worker nodes, the topic replication fails to start."
categories: troubleshooting
slug: georeplication-connect-error
toc: true
---

## Symptoms
When geo-replicating a topic to a destination cluster with 2 or more geo-replication worker nodes, the topic replication fails to start. The {{site.data.reuse.short_name}} UI reports the following error:

```
Could not connect to origin cluster.
```

In addition, the logs for the replicator worker nodes contain the following error message:

```
org.apache.kafka.connect.errors.ConnectException: SSL handshake failed
```

## Causes
The truststore on the geo-replication worker node that hosts the replicator task does not contain the certificate for the origin cluster.

## Resolving the problem
You can either manually add the certificate to the truststore in each of the geo-replicator worker nodes, or you can scale the number of geo-replicator worker nodes down to 1 if suitable for your setup.

### Manually adding certificates

To manually add the certificate to the truststore in each of the geo-replicator worker nodes:

1. Go to your origin cluster. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to start the {{site.data.reuse.long_name}} CLI: `cloudctl es init`
3. Retrieve destination cluster IDs by using the following command:\\
   `cloudctl es geo-clusters`\\
   A list of destination cluster IDs are displayed. Find the name of the destination cluster you are attempting to geo-replicate topics to.
4. Retrieve information about the destination cluster by running the following command and copying the required destination cluster ID from the previous step:\\
   `cloudctl es geo-cluster --destination <destination-cluster-id>`\\
   The failed geo-replicator name is in the list of geo-replicators returned.
5. log in to the destination cluster, and use `kubectl exec` to run the `keytool` command to import the certificate into the truststore in each geo-replication worker node:\\
   ```
   kubectl exec -it -n <namespace> -c replicator \
   <releaseName>-ibm-es-replicator-deploy-<replicator-pod-id> \
   -- bash -c \
   "keytool -importcert \
   -keystore /opt/replicator/security/cacerts \
   -alias <geo-replicator_name> \
   -file /etc/consumer-credentials/cert_<geo-replicator_name> \
   -storepass changeit \
   -trustcacerts -noprompt"
   ```
   The command either succeeds with a `"Certificate was added"` message or fails with a `"Certificate not imported, alias <geo-replicator_name> already exists"` message. In both cases, the truststore for that pod is ready to be used.
6. Repeat the command for each replicator worker node to ensure the certificate is imported into the truststore on all replicator pods.
7. Log in to the origin cluster, and restart the failed geo-replicator using the following `cloudctl` command:\\
   `cloudctl es geo-replicator-restart -d <geo-replication-cluster-id> -n  <geo-replicator_name>`

### Scaling the number of nodes

To scale the number of geo-replicator worker nodes to 1:

1. Go to your destination cluster. {{site.data.reuse.icp_cli_login321}}
2. Run the following `kubectl` command:\\
   `kubectl scale --replicas 1 deployment <releaseName>-ibm-es-replicator-deploy`
