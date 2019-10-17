---
title: "Helm commands fail when running as Team Administrator"
excerpt: "helm-cli-team-administrator"
categories: troubleshooting
slug: helm-cli-team-administrator
toc: true
---

## Symptoms

Running a Helm command as a Team Administrator fails with the following error message:

```
Error: pods is forbidden: User "https://127.0.0.1:9443/oidc/endpoint/OP#<username>" cannot list resource "pods" in API group "" in the namespace "kube-system"
```

Where `<username>` is the name of the user that logged in with the command `cloudctl login`.


## Causes

Running any Helm command requires the user to have authorization to the `kube-system` namespace. The Team Administrator does not have access to the `kube-system` namespace.

## Resolving the problem

The Helm Tiller service can also be configured to use a NodePort to bypass the default proxied connection and allowing users to use Helm CLI without requiring access to the `kube-system` namespace.

The default port is `31514`. To retrieve the port value if not using the default number, log in as the Cluster Administrator by using the `cloudctl login` command, and run the following command:

```
kubectl get services -n kube-system tiller-deploy -o jsonpath='{.spec.ports[0].nodePort}'
```

The port number for the `<tiller-nodeport>` is displayed. Provide the port number to the Team Administrator.

The Team Administrator can then use the port number to run Helm commands in one of the following ways:

- Export the `HELM_HOST` variable, for example:
   ```
   export HELM_HOST=<cluster-ip>:<tiller-nodeport>
   ```

   The Team Administrators can then run Helm commands.

- Use the `--host` option when running Helm commands, and include the `<cluster-ip>:<tiller-nodeport>` value, for example:
   ```
   helm install --tls --host <cluster-ip>:<tiller-nodeport> install/delete/list ...
   ```

For more information about the workaround, see the {{site.data.reuse.icp}} [documentation](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.1/user_management/nodePort.html){:target="_blank"}.
