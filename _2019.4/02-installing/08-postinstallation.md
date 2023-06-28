---
title: "Post-installation tasks"
excerpt: "Post-installation tasks after successfully installing IBM Event Streams."
categories: installing
slug: post-installation
layout: redirects
toc: true
---

Consider the following tasks after installing {{site.data.reuse.long_name}}.

## Verifying your installation

To verify that your {{site.data.reuse.short_name}} installation deployed successfully, check the status of your release as follows.

1. {{site.data.reuse.icp_ui_login321}}
3. From the navigation menu, click **Workloads > Helm Releases**.
4. Locate your installation in the **NAME** column, and ensure the **STATUS** column for that row states **Deployed**.
5. Optional: Click the name of your installation to check further details of your {{site.data.reuse.short_name}} installation. For example, you can check the ConfigMaps used, or check the logs for your pods.
6. [Log in](../../getting-started/logging-in) to your {{site.data.reuse.long_name}} UI to get started.

## Installing the command-line interface (CLI)

The {{site.data.reuse.short_name}} CLI is a plugin for the {{site.data.reuse.icp}} CLI. Use the CLI to manage your {{site.data.reuse.short_name}} instance from the command line, such as creating, deleting, and updating topics.

To install the {{site.data.reuse.short_name}} CLI:
1. Ensure you have the [{{site.data.reuse.icp}} CLI installed](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/install_cli.html){:target="_blank"}.
2. [Log in](../../getting-started/logging-in/) to the {{site.data.reuse.short_name}} as an administrator.
3. Click **Toolbox** in the primary navigation.
4. Go to the **{{site.data.reuse.long_name}} command-line interface** section and click **Find out more**.
5. Download the {{site.data.reuse.short_name}} CLI plug-in for your system by using the appropriate link.
6. Install the plugin using the following command:\\
   `cloudctl plugin install <full_path>/es-plugin`

To start the {{site.data.reuse.short_name}} CLI and check all available command options in the CLI, use the `cloudctl es` command. To get help on each command, use the `--help` option.

To use the {{site.data.reuse.short_name}} CLI against a deployed {{site.data.reuse.icp}} cluster, run the following commands, replacing `<master_ip_address>` with your master node IP address, `<master_port_number>` with the master node port number, and `<my_cluster>` with your cluster name:
```
cloudctl login -a https://<master_ip_address>:<master_port_number> -c <my_cluster>
cloudctl es init
```

## Firewall and load balancer settings

Consider the following guidance about firewall and load balancer settings for your deployment.

### Using {{site.data.reuse.openshift_short}}

If installed on the {{site.data.reuse.openshift_short}}, {{site.data.reuse.short_name}} uses OpenShift routes. Ensure your OpenShift [router](https://docs.openshift.com/container-platform/3.11/dev_guide/expose_service/expose_internal_ip_load_balancer.html){:target="_blank"} is set up as required.

### Using {{site.data.reuse.icp}}

If you installed {{site.data.reuse.short_name}} on {{site.data.reuse.icp}}, see the following guidance.

In your firewall settings, ensure you enable communication for the node ports that {{site.data.reuse.short_name}} services use.

If you are using an external load balancer for your master or proxy nodes in a high availability environment, ensure that the external ports are forwarded to the appropriate master and proxy nodes.

To find the node ports to expose by using the UI:

1. {{site.data.reuse.icp_ui_login321}}
2. From the navigation menu, click **Workloads > Helm Releases**.\\
   ![Menu > Workloads > Helm releases](../../../images/icp_menu_helmreleases.png "Screen capture showing how to select Workloads > Helm releases from navigation menu"){:height="30%" width="30%"}
3. Locate the release name of your {{site.data.reuse.short_name}} installation in the **NAME** column, and click the name.
4. Scroll down to the **Service** table. The table lists information about your {{site.data.reuse.short_name}} services.
5. In the **Service** table, look for `NodePort` in the **TYPE** column.\\
   In each row that has `NodePort` as type, look in the **PORT(S)** column to find the port numbers you need to ensure are open to communication.\\
   The port numbers are paired as `<internal_number:external_number>`, where you need the second (external) numbers to be open (for example, `30314` in `32000:30314`).\\
   The following image provides an example of the table:\\
   ![Service table](../../../images/service_nodeports201941.png "Screen capture showing service table with the NodePort types highlighted.")

   For your firewall settings, ensure the external ports are open. For example, in the previous screen capture, it is the second number for the highlighted `NodePort` rows in the table: `32292`, `31212`, `30429`, `32618`, `30477`, `30015`, and `30594`.

   For your load balancer settings, you need to expose the following ports:
   - For the CLI, ensure you forward the external port to both the master and the proxy nodes. This is the second port listed in the `<release_name>-<namespace>-rest-proxy-external-svc` row. In the previous example, the ports are the second number in the **PORT(S)** column of the `es1-ibm-es-rest-proxy-external-svc ` row: `30477` and `30015`.
   - For the UI, ensure you forward the external port to both the master and the proxy nodes. This is the second port listed in the `<release_name>-<namespace>-ui-svc` row. In the previous example, the port is the second number in the **PORT(S)** column of the `es1-ibm-es-ui-svc` row: `30594`.
   - For Kafka, ensure you forward the external port to the proxy node. This is the second port listed in the `<release_name>-<namespace>-proxy-svc` row. In the previous example, the ports are the second numbers in the **PORT(S)** column of the `es1-ibm-es-proxy-svc` row: `32292`, `31212`, `30429`, and `32618`.

To find the node ports to expose by using the CLI:

1. {{site.data.reuse.icp_cli_login321}}
2. Run the following command to list information about your {{site.data.reuse.short_name}} services:\\
   `kubectl get services -n <namespace>`\\
   The following is an example of the output (this is the same result as shown in the previous UI screen capture example):
   ```
   NAME                                         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                           AGE
es1-ibm-es-access-controller-svc             ClusterIP   None           <none>        8443/TCP                                                          92m
es1-ibm-es-collector-svc                     ClusterIP   None           <none>        7888/TCP                                                          92m
es1-ibm-es-elastic-svc                       ClusterIP   None           <none>        9200/TCP,9300/TCP                                                 92m
es1-ibm-es-indexmgr-svc                      ClusterIP   None           <none>        9080/TCP,8080/TCP                                                 92m
es1-ibm-es-kafka-external-headless-svc       ClusterIP   None           <none>        9092/TCP,8093/TCP,8084/TCP,8085/TCP,8081/TCP,7070/TCP             92m
es1-ibm-es-kafka-headless-svc                ClusterIP   None           <none>        9092/TCP,8093/TCP,8084/TCP,8085/TCP,8081/TCP,7070/TCP             92m
es1-ibm-es-proxy-svc                         NodePort    10.0.173.129   <none>        30000:32292/TCP,30001:31212/TCP,30051:30429/TCP,30101:32618/TCP   92m
es1-ibm-es-replicator-svc                    ClusterIP   None           <none>        8083/TCP                                                          92m
es1-ibm-es-rest-producer-svc                 ClusterIP   10.0.2.210     <none>        8080/TCP                                                          92m
es1-ibm-es-rest-proxy-external-svc           NodePort    10.0.105.97    <none>        32000:30477/TCP,32001:30015/TCP                                   92m
es1-ibm-es-rest-proxy-internal-svc           ClusterIP   10.0.94.28     <none>        9443/TCP                                                          92m
es1-ibm-es-rest-svc                          ClusterIP   10.0.76.77     <none>        9443/TCP                                                          92m
es1-ibm-es-schemaregistry-svc                ClusterIP   10.0.13.231    <none>        3000/TCP                                                          92m
es1-ibm-es-ui-svc                            NodePort    10.0.34.109    <none>        3000:30594/TCP                                                    92m
es1-ibm-es-zookeeper-external-headless-svc   ClusterIP   None           <none>        2181/TCP,2888/TCP,3888/TCP                                        92m
es1-ibm-es-zookeeper-headless-svc            ClusterIP   None           <none>        2181/TCP,2888/TCP,3888/TCP                                        92m

   ```

## Connecting clients

You can set up external client access [during installation](../configuring/#configuring-external-access). After installation, clients can connect to the Kafka cluster by using the externally visible IP address for the Kubernetes cluster. The port number for the connection is allocated automatically and varies between installations. To look up this port number after the installation is complete:

1. {{site.data.reuse.icp_ui_login321}}
3. From the navigation menu, click **Workloads > Helm Releases**.
4. In the **NAME** column, locate and click the release name used during installation.
5. Scroll down through the sections and locate the **Service** section.
6. In the **NAME** column, locate and click the **`<releasename>-ibm-es-proxy-svc`** NodePort entry.
7. In the **Type** column, locate the list of **Node port** links.
8. Locate the top entry in the list named **`bootstrap <bootstrap port>/TCP`**.
8. If no external hostname was specified when {{site.data.reuse.short_name}} was installed, this is the IP address and port number that external clients should connect to.
9. If an external hostname was specified when {{site.data.reuse.short_name}} was installed, clients should connect to that external hostname using this bootstrap port number.

Before connecting a client, ensure the necessary certificates are configured within your client environment. Use the TLS and CA certificates if you provided them during installation, or export the self-signed public certificate from the browser.

To export the self-signed public certificate from the browser:

1. [Log in](../../getting-started/logging-in/) to the {{site.data.reuse.long_name}} UI.
2. Click **Connect to this cluster** on the right.
3. On the **Resources** tab, copy the address from the **Bootstrap server** section. This gives the bootstrap address for Kafka clients.
4. From the **Certificates** section, download the server certificate. If you are using a Java client, use the **Java truststore**. Otherwise, use the **PEM certificate**.

## Setting up access

Secure your installation by [managing the access](../../security/managing-access/) your users and applications have to your {{site.data.reuse.short_name}} resources.

For example, associate your {{site.data.reuse.icp}} teams with your {{site.data.reuse.short_name}} instance to grant access to resources based on roles.

## Scaling

Depending on the size of the environment that you are installing, consider scaling and sizing options. You might also need to change scale and size settings for your services over time. For example, you might need to add additional Kafka brokers over time.

See [how to scale your environment](../../administering/scaling)

## Considerations for GDPR readiness

Consider [the requirements for GDPR](../../security/gdpr-considerations/), including [encrypting your data](../../security/encrypting-data/) for protecting it from loss or unauthorized access.
