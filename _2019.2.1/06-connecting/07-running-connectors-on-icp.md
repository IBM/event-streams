---
title: "Running connectors on IBM Cloud Private"
# permalink: /connecting/icp
excerpt: "Set up your Kafka Connect workers to run on IBM Cloud Private."
categories: connecting
slug: icp
toc: true
---

If you have IBM MQ or another service running on {{site.data.reuse.icp}}, you can use Kafka Connect and one or more connectors to flow data between your instance of {{site.data.reuse.long_name}} and the service on {{site.data.reuse.icp}}. In this scenario it makes sense to run Kafka Connect in {{site.data.reuse.icp}} as well.

## Downloading connectors

The connector catalog contains a list of connectors that have been verified with {{site.data.reuse.short_name}}. Go to the [connector catalog](../../connectors/){:target="_blank"} and download the JAR file(s) for any connectors you want to use.

The JAR files for the IBM MQ source and sink connectors can be downloaded from the {{site.data.reuse.long_name}} UI. Log in to your {{site.data.reuse.long_name}} UI, click the **Toolbox** tab and look for the tile called "Add connectors to your Kafka Connect environment".

## Building a Kafka Connect Docker image

The {{site.data.reuse.short_name}} UI provides a toolbox page to help you get started with Kafka Connect. This provides a Dockerfile that builds a custom Kafka Connect with the Connectors you include.

If you do not already have the Dockerfile, follow the steps to download the Kafka Connect ZIP and build a Docker image.

1. In the {{site.data.reuse.short_name}} UI, click the **Toolbox** tab. Scroll to the **Connectors** section.
2. Go to the **Set up a Kafka Connect environment** tile, and click **Set up**.
3. If you have not already done so follow the instructions to create three topics for Kafka Connect to use.
4. You need to provide an API key for Kafka Connect that has permission to Produce, Consume and create Topics. Paste in your API key, or click the button to generate one.\\
   **NOTE:** You must have a cluster admin role to generate an API key.
5. Click Download Kafka Connect ZIP to download the zip.
6. Extract the contents of the Kafka Connect `.zip` file to a local directory.
7. Copy the connector JAR files you downloaded earlier into the `connectors` folder in the extracted `.zip` folder\\
   `cp <path_to_your_connector>.jar <extracted_zip>/connectors`
8. Build the container: `docker build -t kafkaconnect:0.0.1 .`

## Uploading the Kafka Connect container

To make the Kafka Connect container available on {{site.data.reuse.icp}} it needs to be pushed to your {{site.data.reuse.icp}} container registry.

1. Set up your Kubernetes command-line tool `kubectl` to access your {{site.data.reuse.icp}} instance, for example, by running `cloudctl login`.
2. Create a namespace to deploy the Kafka Connect workers to: `kubectl create namespace <namespace>`
3. Log in to the Docker private image registry:\\
   ```
   cloudctl login -a https://<cluster_CA_domain>:8443
   docker login <cluster_CA_domain>:8500
   ```
   For more information, see the [{{site.data.reuse.icp}} documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_images/using_docker_cli.html).
4. Retag and push the Docker image as follows:\\
   ```
   docker tag kafkaconnect:0.0.1 <cluster_CA_domain>:8500/<namespace>/kafkaconnect:0.0.1
   docker push <cluster_CA_domain>:8500/<namespace>/kafkaconnect:0.0.1
   ```
5. Check this has worked by logging into your {{site.data.reuse.icp}} UI and clicking on Container Images in the menu.

**Note:** The namespace you provide is the one you will run the Kafka Connect workers in.

## Creating a Secret resource for the Kafka Connect configuration

To enable updates to the Kafka Connect configuration the running container will need access to a Kubernetes resource containing the contents of connect-distributed.properties. The file is included in the extracted ZIP for Kafka Connect from the {{site.data.reuse.short_name}} UI. This file includes API keys so create a Secret:

```
kubectl -n <namespace> create secret generic connect-distributed-config --from-file=<extracted_zip>/config/connect-distributed.properties
```

## Creating a ConfigMap resource for the Kafka Connect log4j configuration

To enable updates to the Kafka Connect logging configuration create a ConfigMap with the contents of connect-log4j.properties. The file is included in the extracted ZIP for Kafka Connect from the {{site.data.reuse.short_name}} UI:

```
kubectl -n <namespace> create configmap connect-log4j-config --from-file=<extracted_zip>/config/connect-log4j.properties
```

## Creating the Kafka Connect deployment

To create the Kafka Connect deployment first create a yaml file called `kafka-connect.yaml` with the following contents: (Replace `<namespace>` with your {{site.data.reuse.icp}} namespace)
```
# Deployment
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: kafkaconnect-deploy
    labels:
      app: kafkaconnect
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: kafkaconnect
    template:
      metadata:
        namespace: <namespace>
        labels:
          app: kafkaconnect
      spec:
        securityContext:
          runAsNonRoot: true
          runAsUser: 5000
        containers:
          - name: kafkaconnect-container
            image: kafkaconnect:0.0.1
            readinessProbe:
              httpGet:
                path: /
                port: 8083
            livenessProbe:
              httpGet:
                path: /
                port: 8083
            ports:
            - containerPort: 8083
            volumeMounts:
            - name: connect-config
              mountPath: /opt/kafka/config/connect-distributed.properties
              subPath: connect-distributed.properties
            - name: connect-log4j
              mountPath: /opt/kafka/config/connect-log4j.properties
              subPath: connect-log4j.properties
        volumes:
        - name: connect-config
          secret:
            secretName: connect-distributed-config
        - name: connect-log4j
          configMap:
            name: connect-log4j-config

  ---
  # Service
  apiVersion: v1
  kind: Service
  metadata:
    name: kafkaconnect-service
    labels:
      app: kafkaconnect-service
  spec:
    type: NodePort
    ports:
      - name: kafkaconnect
        protocol: TCP
        port: 8083
    selector:
        app: kafkaconnect
```

This defines the deployment that will run Kafka Connect and the service used to access it.

Create the deployment and service using: `kubectl -n <namespace> apply -f kafka-connect.yaml`

Use `kubectl -n <namespace> get service kafkaconnect-service` to view your running services. The port mapping shows `8083` being mapped to an external port. Use the external port to verify the IBM MQ Connectors you included have been installed:

`curl http://<serviceIP>:<servicePort>/connector-plugins`

## Running a connector

To start a Connector instance, you need to create a JSON file with the connector configuration. Most connectors will have an example in their documentation. For the IBM MQ connectors this file can be generated in the {{site.data.reuse.short_name}} UI or CLI. See [connecting to IBM MQ](../mq/) for more details.

Once you have a JSON file use the `/connectors` endpoint to start the connector:

```
curl -X POST http://<serviceIP>:<servicePort>/connectors -H "Content-Type: application/json" -d @mq-source.json
```

For more information about the other REST API endpoints (such as pausing, restarting, and deleting connectors) see the [Kafka Connect REST API documentation](https://kafka.apache.org/documentation/#connect_rest){:target="_blank"}.
