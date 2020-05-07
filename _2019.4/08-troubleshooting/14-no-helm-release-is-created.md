---
title: "Chart deployment starts but no helm release is created"
excerpt: "Chart deployment starts but the helm release and group of expected pods are not created."
categories: troubleshooting
slug: no-helm-release-is-created
toc: true
---

## Symptoms

When the {{site.data.reuse.long_name}} chart is deployed, the process appears to start successfully but the helm release and set of expected pods are not created. You can confirm the helm release has not been created by running the following command:

```
helm list
```

In this case you will not see an entry for the `Helm release name` you provided when you started the deployment process.

In addition, you will see that only a single pod is initially created and then subsequently removed after a couple of minutes. You can check which pods are running using the following command:

```
kubectl get pods
```

Immediately after starting the deployment process, you will see a single pod created named `<releaseName>-ibm-es-secret-copy-job-<uid>`. If you 'describe' the pod, you will receive the error message `Failed to pull image`, and a further message stating either `Authentication is required` or `unauthorized: BAD_CREDENTIAL`. After a couple of minutes this pod is deleted and no pods will be reported by the `kubectl` command.

If you query the defined jobs as follows, you will see one named `<releaseName>-ibm-es-secret-copy-job`:

```
kubectl get jobs
```

Finally if you 'describe' the job as follows, you will see that it reports a failed pod status:

```
kubectl describe job <releaseName>-ibm-es-secret-copy-job
```

For example, the job description will include the following:

```
Pods Statuses:            0 Running / 0 Succeeded / 1 Failed
```

## Causes

This situation occurs if there a problem with the image pull secret being used to authorize access to the Docker image repository you specified when the chart was deployed. When you 'describe' the secret copy pod, if you see the error message `Authentication is required`, this indicates that the secret you specified does not exist. If you see the error message `unauthorized: BAD_CREDENTIAL`, this indicates that the secret was found but one of the fields present within it is not correct.

To confirm which secrets are deployed, run the following command:

```
kubectl get secrets
```

## Resolving the problem

To delete a secret thats not correctly defined, use the following command:

```
kubectl delete secret <secretName>
```

To create a new secret for use in chart deployment, run the following command:

```
kubectl create secret docker-registry <secretName> --docker-server=<serverAddress:serverPort> --docker-username=<dockerUser> --docker-password=<dockerPassword> --docker-email=<yourEmailAddress>
```

For example:

```
kubectl create secret docker-registry regcred --docker-server=mycluster.icp:8500 --docker-username=admin --docker-password=admin --docker-email=John.Smith@ibm.com
```

After you have confirmed that the required secret is correctly defined, re-run the chart deployment process.
