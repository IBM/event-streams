---
title: "504 timeout error when viewing consumer groups in the Event Streams UI"
excerpt: "When viewing consumer groups in the Event Streams UI a 504 timeout error is shown and the groups are not displayed"
categories: troubleshooting
slug: 504-ui-consumer-groups
toc: true
---

## Symptoms
When viewing consumer groups in the Event Streams UI, the page displays a loading indicator while it fetches the groups. However, the groups are not displayed and a 504 timeout error is shown instead.

## Causes
As the number of consumer groups increases it will reach a limit where the service that retrieves the groups for the UI is unable to respond before the UI considers the request to have timed out.

## Resolving the problem

Contact [IBM Support]({{ 'support' | relative_url }}) to request a fix, and include issue number [ES-135](https://github.com/IBM/event-streams/issues/135){:target="_blank"} in your correspondence.

<!--
When the issue is resolved, update this section to include:
"Resolved in Event Streams x.y.z"
-->
