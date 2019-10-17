---
title: "Gathering logs"
excerpt: "To help IBM support troubleshoot any issues with your Event Streams installation, run the log gathering script."
categories: troubleshooting
slug: gathering-logs
toc: false
---

To help IBM support troubleshoot any issues with your Event Streams installation, run the log gathering script as follows. The script collects the log files from available pods and creates a compressed file. It uses the component label names instead of the pod names as the pod names could be truncated.

1. Download the `get-logs.sh` script from [GitHub](https://github.com/IBM/event-streams/tree/master/support){:target="_blank"}.
2. Ensure you have installed the Kubernetes command line tool and the {{site.data.reuse.icp}} CLI as noted in the [installation prerequisites](../../installing/prerequisites/).
3. {{site.data.reuse.icp_cli_login321}}
4. Run the script as follows:\\
    `./get-logs.sh -n <namespace> -r <release-name>`

    If you do not specify a namespace, the script retrieves logs from the default namespace as requested in the `cloudctl` login. If you do not specify a release name, the script gathers logs for all releases.
