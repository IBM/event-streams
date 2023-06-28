---
title: "Full cleanup after uninstallation"
excerpt: "Learn how to fully clean up after uninstallation."
categories: troubleshooting
slug: cleanup-uninstall
layout: redirects
toc: true
---

The uninstallation process might leave behind artifacts that you have to clear manually.

## Security resources

A service ID is created as part of installing {{site.data.reuse.short_name}}, which defines the identity for securing communication between internal components. To delete this service ID after uninstalling {{site.data.reuse.short_name}}, run the following command:

`cloudctl iam service-id-delete eventstreams-<release>-service-id -f`


## Kubernetes resources

Use the following command to find the list of {{site.data.reuse.long_name}} objects associated with the release’s namespace:

`kubectl get <type> -n <namespace> | grep ibm-es`

Where type is each of

- pods
- clusterroles
- clusterrolebindings
- roles
- rolebindings
- configmaps
- serviceaccounts
- statefulsets
- deployments
- jobs
- pods
- pvc (see **Note** later)
- secrets

There are also a number of {{site.data.reuse.short_name}} objects created in the kube-system namespace. To list these objects run the following command:

`kubectl get pod -a -n kube-system | grep ibm-es`

**Note:** These commands might return objects that should not be deleted. For example, do not delete secrets or system clusterroles if the kubectl output is not piped to grep.

**Note:** If persistent volume claims (PVCs) are deleted (the objects returned when specifying “pvc” in the commands above), the data associated with the PVCs is also deleted. This includes any persistent Kafka data on disk. Consider whether this is the desired result before deleting any PVCs.

To find which objects need to be manually cleared look for the following string in the output of the previously mentioned commands:

`<release>-ibm-es`

 You can either navigate through the {{site.data.reuse.icp}} cluster management console to **Workloads >** or **Configuration >** to find the objects and delete them, or use the following command:

 `kubectl delete <type> <name> -n <namespace>`

For example, to delete a leftover `rolebinding` called `eventstreams-ibm-eventstreams-secret-copy-crb-ns`, run the following command:

`kubectl delete rolebinding eventstreams-ibm-eventstreams-secret-copy-crb-ns -n es`

Be cautious of deleting persistent volume claims (PVCs) as the data on the disk that is associated with that persistent volume will also be deleted. This includes {{site.data.reuse.short_name}} message data.
