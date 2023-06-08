---
title: "Exposing services for external access"
excerpt: "Learn how to expose a service outside your cluster."
categories: connecting
slug: expose-service
toc: true
---

If you want to expose a service associated with {{site.data.reuse.short_name}} outside your Kubernetes cluster, create and apply a custom resource that defines the external listener as described in the following sections.

**Note:** This topic is about exposing services that are associated with your {{site.data.reuse.short_name}} deployment, such as Kafka Bridge and Kafka Connect. For configuring access to services representing {{site.data.reuse.short_name}} components, see [configuring access](../../installing/configuring/#configuring-access).

## Prerequisites

- Ensure the service to be exposed is available and ready (for example, you have [Kafka Bridge enabled](../../installing/configuring/#enabling-and-configuring-kafka-bridge)).
- Ensure the exposing resource is available. For example, the {{site.data.reuse.openshift_short}} uses routes by default, but when using ingress as the connection type, ensure an [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/){:target="_blank"} is deployed and running in your Kubernetes cluster to enable the ingress resource to work. The SSL passthrough must be enabled in the ingress controller and your ingresses. Refer to your ingress controller documentation for more information.

**Important:** Exposing a service to external access means any external client will be able to access the service. For example, writing to or reading from Kafka topics through Kafka Bridge, or accessing and changing connector configuration settings in the case of Kafka Connect. This creates a potential security risk due to the unsecured nature of these services. Ensure you consider the risks before exposing these services to external clients.

## Configuring external access

To configure the external access:

1. Extract the Service Name of the service to be exposed. For example, run the following command to list the services:

   `kubectl get service`

   This will provide a list of service names, for example, `Service Name=MyKafkaBridge`

2. Create the custom resource YAML file that defines how your service is exposed.

   - For example, if you have an {{site.data.reuse.openshift_short}} cluster, create a `Route` custom resource for the service to expose:

   ```
   kind: Route
   apiVersion: route.openshift.io/v1
   metadata:
       name: <route-name>
       namespace: <namespace>
   spec:
     host: <route-name>-<namespace>.apps.<cluster-name>.example.com
     to:
       kind: Service
       name: <service-name-to-expose>
       weight: 100
     port:
       targetPort: rest-api
     wildcardPolicy: None
   ```

   Where `<cluster-name>` is the name of the OpenShift cluster you are using. If you do not provide a hostname, it is automatically generated when the route custom resource is applied.

   **Note:** In case of Kafka Bridge, ensure you expose the Kafka Bridge service by running: `kubectl expose service <service-name-to-expose>`.

   - To expose a service by using ingress and NGINX as the [ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/){:target="_blank"}, create an `Ingress` custom resource for the service to expose:

   ```
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: <ingress-name>
   spec:
     ingressClassName: nginx
     rules:
       - host: <preferred-hostname>
         http:
           paths:
             - path: /
               pathType: Prefix
               backend:
                 service:
                   name: <service-name-to-expose>
                   port:
                     number: <port-number>
   ```
   For information about the schema for REST endpoints, see the table in [configuring access](../../installing/configuring/#rest-services-access).


3. Apply the custom resource by running the following command:

   `kubectl apply -f <filename>.yaml`
