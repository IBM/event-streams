---
title: "Rollback fails"
excerpt: "Rollback fails with error, and users are unable to login to the UI."
categories: troubleshooting
slug: rollback-fails
toc: true
---

## Symptoms

Rolling back from {{site.data.reuse.short_name}} version 2019.1.1 to 2018.3.1 (Helm chart version 1.2.0 to 1.1.0) results in an `Invalid request (..) field is immutable` error.

The rollback status shows as failed, for example:

```
$ helm history event-streams
REVISION        UPDATED                         STATUS          CHART                           DESCRIPTION
1               Tue Dec 10 16:28:19 2018        SUPERSEDED      ibm-eventstreams-prod-1.1.0     Install complete
2               Fri Mar 29 14:15:24 2019        SUPERSEDED      ibm-eventstreams-prod-1.2.0     Upgrade complete
3               Fri Mar 29 15:23:46 2019        FAILED          ibm-eventstreams-prod-1.1.0     Rollback "event-streams" failed: Job.batch "event-streams...
```

Attempting to log in to the {{site.data.reuse.short_name}} UI on the new port results in the following error:

```
CWOAU0062E: The OAuth service provider could not redirect the request because the redirect URI was not valid. Contact your system administrator to resolve the problem.
```
## Causes

The `oauth` job was not removed before performing the [rollback steps](../../installing/rolling-back/).

## Resolving the problem

Run the following command:

`kubectl -n kube-system get job <release-name>-ibm-es-ui-oauth2-client-reg -o json | jq 'del(.spec.selector)' | jq 'del(.spec.template.metadata.labels)' | kubectl replace --force -f -`

Where `<release-name>` is the name that identifies your {{site.data.reuse.short_name}} installation.

If you are still experiencing issues with your installation, you might need to [uninstall](../../installing/uninstalling) {{site.data.reuse.short_name}}, and [clean up](../cleanup-uninstall/) after uninstallation before installing again.
