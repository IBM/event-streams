---
title: "Managing access"
excerpt: "Managing access for users and applications."
categories: security
slug: managing-access
toc: true
---

You can secure your {{site.data.reuse.long_name}} resources in a fine-grained manner by managing the access each user and application has to each resource.

## What resource types can I secure?

Within {{site.data.reuse.long_name}}, you can secure access to the following resource types, where the names in parentheses are the resource type names used in policy definitions:
* Cluster (cluster): you can control which users and applications can connect to the cluster.
* Topics (topic): you can control the ability of users and applications to create, delete, read, and write to a topic.
* Consumer groups (group): you can control an application's ability to join a consumer group.
* Transactional IDs (txnid): you can control the ability to use the transaction capability in Kafka.

## What roles can I assign?

Roles define the levels of access a user or application has to resources. The following table describes the roles you can assign in {{site.data.reuse.icp}}.

| Role | Permitted actions | Example actions |
|:-----------------|:-----------------|:-----------------|
| Viewer | Viewers have permissions to perform read-only actions within {{site.data.reuse.long_name}} such as viewing resources. | Allow an application to connect to a cluster by assigning read access to the cluster resource. |
| Editor | Editors have permissions beyond the Viewer role, including writing to {{site.data.reuse.long_name}} resources such as topics. | Allow an application to produce to topics by assigning editor access to topic resources. |
| Operator | Operators have permissions beyond the Editor role, including creating and editing {{site.data.reuse.long_name}} resources. | Allow access to create resources by assigning operator access to the {{site.data.reuse.long_name}} instance. |
| Auditor | No actions are currently assigned to this role. | |
| Administrator | Administrators have permissions beyond the Operator role to complete privileged actions. | Allow full access to all resources by assigning administrator access to the {{site.data.reuse.long_name}} instance. |

## Mapping service actions to roles

Access control in Apache Kafka is defined in terms of operations and resources. In {{site.data.reuse.long_name}}, the operations are grouped into a smaller set of service actions, and the service actions are then assigned to roles.

The mapping between Kafka operations and service actions is described in the following table. If you understand the Kafka authorization model, this tells you how {{site.data.reuse.long_name}} maps operations into service actions.

| Resource type    | Kafka operation  | Service action   |
|:-----------------|:-----------------|:-----------------|
| Cluster          | Describe         | -                |
|                  | Describe Configs | -                |
|                  | Idempotent Write | -                |
|                  | Create           | cluster.manage   |
|                  | Alter            | RESERVED         |
|                  | Alter Configs    | cluster.manage   |
|                  | Cluster Action   | RESERVED         |
| Topic            | Describe         | -                |
|                  | Describe Configs | topic.read       |
|                  | Read             | topic.read       |
|                  | Write            | topic.write      |
|                  | Create           | topic.manage     |
|                  | Delete           | topic.manage     |
|                  | Alter            | topic.manage     |
|                  | Alter Configs    | topic.manage     |
| Group            | Describe         | -                |
|                  | Read             | group.read       |
|                  | Delete           | group.manage     |
| Transactional ID | Describe         | -                |
|                  | Write            | txnid.write      |

In addition, {{site.data.reuse.long_name}} adds another service action called `cluster.read`. This service action is used to control connection access to the cluster.

**Note:** Where the service action for an operation is shown in the previous table as a dash `-`, the operation is permitted to all roles.

The mapping between service actions and {{site.data.reuse.long_name}} roles is described in the following table.

| Resource type    | Administrator    | Operator         | Editor           | Viewer           |
|:-----------------|:-----------------|:-----------------|:-----------------|:-----------------|
| Cluster          | cluster.read     | cluster.read     | cluster.read     | cluster.read     |
|                  | cluster.manage   | cluster.manage   |                  |                  |
| Topic            | topic.read       | topic.read       | topic.read       | topic.read       |
|                  | topic.write      | topic.write      | topic.write      |                  |
|                  | topic.manage     | topic.manage     |                  |                  |
| Group            | group.read       | group.read       | group.read       | group.read       |
|                  | group.manage     | group.manage     |                  |                  |
| Transactional ID | txnid.write      | txnid.write      | txnid.write      |                  |

## Assigning access to users

If you have not set up [{{site.data.reuse.icp}} teams](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/user_management/teams.html){:target="_blank"}, the admin user has the ClusterAdministrator role. This role has unlimited access to all resources.

If you are using {{site.data.reuse.icp}} teams, you must associate the team with the {{site.data.reuse.long_name}} instance to apply the team members' roles to the resources within the instance. You can do this using the `cloudctl es iam-add-release-to-team` command.

This command creates policies that grant access to resources based on the roles in the team. It is possible to refine user access to specific resources further and limit actions they can take against resources by using the {{site.data.reuse.icp}} APIs. If you require such granular settings for security, [contact us](../../support).

**Note:** It can take up to 10 minutes after assigning access before users can perform tasks associated with their permissions.

### Common scenarios for users

The following table summarizes common {{site.data.reuse.long_name}} scenarios and the roles you need to assign.

| Permission | Role required |
|:-----------|:--------------|
| Allow full access to all resources | `Administrator` |
| Create and delete topics | `Operator` or higher |
| Generate the starter application to produce messages | `Editor` or higher |
| View the messages on a topic | `Viewer` or higher |

## Assigning access to applications

Each application that connects to {{site.data.reuse.long_name}} provides credentials associated with an {{site.data.reuse.icp}} service ID. You assign access to a service ID by creating service policies. You can use the {{site.data.reuse.icp}} cluster management console to achieve this.

1. {{site.data.reuse.icp_ui_login}}
2. Enter an {{site.data.reuse.icp}} administrator user name and password.
3. From the navigation menu, click **Manage > Identity & Access**.
4. From the sub-navigation menu, click **Service IDs**.
5. Select the ServiceID you are interested in or create one.\\
   **Warning:** Do not use the internal {{site.data.reuse.short_name}} service ID `eventstreams-<release name>-service-id`. This service ID is reserved to be used within the Events Streams cluster.

Each service policy defines the level of access that the service ID has to each resource or set of resources. A policy consists of the following information:
* The role assigned to the policy. For example, `Viewer`, `Editor`, or `Operator`.
* The type of service the policy applies to. For example, {{site.data.reuse.long_name}}.
* The instance of the service to be secured.
* The type of resource to be secured. The valid values are <code>cluster</code>, <code>topic</code>, <code>group</code>, or <code>txnid</code>. Specifying a type is optional. If you do not specify a type, the policy then applies to all resources in the service instance.
* The identifier of the resource to be secured. Specify for resources of type <code>topic</code>, <code>group</code> and <code>txnid</code>. If you do not specify the resource, the policy then applies to all resources of the type specified in the service instance.

You can create a single policy that does not specify either the resource type or the resource identifier. This kind of policy applies its role to all resources in the {{site.data.reuse.long_name}} instance. If you want more precise access control, you can create a separate policy for each specific resource that the service ID will use.

**Note:** It can take up to 10 minutes after assigning access before applications can perform tasks associated with their permissions.

### Common scenarios for applications

If you choose to use a single policy to grant access to all resources in the {{site.data.reuse.long_name}} instance, the following table summarizes the roles required for common scenarios.

| Permission | Policies required |
|:-----------|:--------------|
| Connect to the cluster  | 1. Role: `Viewer` or higher |
| Consume from a topic | 1. Role: `Viewer` or higher |
| Produce to a topic | 1. Role: `Editor` or higher |
| Use all features of the Kafka Streams API | 1. Role: `Operator` or higher |

Alternatively, you can assign specific service policies for the individual resources. The following table summarizes common {{site.data.reuse.long_name}} scenarios and the service policies you need to assign.

| Permission | Policies required |
|:-----------|:----------------|
| Connect to the cluster | 1. Resource type: `cluster` <br/>Role: `Viewer` or higher |
| Produce to a topic | 1. Resource type: `cluster` <br/>Role: `Viewer` or higher <br/> 2. Resource type: `topic` <br/> Resource identifier: <var class="keyword varname">name_of_topic</var> <br/>Role: `Editor` or higher |
| Produce to a topic using a transactional ID | 1. Resource type: `cluster` <br/>Role: `Viewer` or higher <br/> 2. Resource type: `topic` <br/> Resource identifier: <var class="keyword varname">name_of_topic</var> <br/>Role: `Editor` or higher <br/> 3. Resource type: `txnid` <br/> Resource identifier: <var class="keyword varname">transactional_id</var> <br/>Role: `Editor` or higher |
| Consume from a topic (no consumer group) | 1. Resource type: `cluster` <br/>Role: `Viewer` or higher <br/> 2. Resource type: `topic` <br/> Resource identifier: <var class="keyword varname">name_of_topic</var> <br/>Role: `Viewer` or higher |
| Consume from a topic in a consumer group | 1. Resource type: `cluster` <br/>Role: `Viewer` or higher <br/> 2. Resource type: `topic` <br/> Resource identifier: <var class="keyword varname">name_of_topic</var> <br/>Role: `Viewer` or higher <br/> 3. Resource type: `group` <br/> Resource identifier: <var class="keyword varname">name_of_consumer_group</var> <br/>Role: `Viewer` or higher |


## Revoking access for an application

You can revoke access to {{site.data.reuse.long_name}} by deleting the {{site.data.reuse.icp}} service ID or API key that the application is using. You can use the {{site.data.reuse.icp}} cluster management console to achieve this.

1. {{site.data.reuse.icp_ui_login}}
2. Enter an {{site.data.reuse.icp}} administrator user name and password.
3. From the navigation menu, click **Manage > Identity & Access**.
4. From the sub-navigation menu, click **Service IDs**.
5. Find the Service ID being used by the application in the Service IDs list.
6. Remove either the service ID or the API key that the application is using. Removing the service ID also removes all API keys that are owned by the service ID.\\
   **Warning:** Do not remove the internal {{site.data.reuse.short_name}} service ID `eventstreams-<release name>-service-id`. Removing this service ID corrupts your deployment, which can only be resolved by reinstalling {{site.data.reuse.short_name}}.

  - Remove the service ID by clicking ![Menu overflow icon](../../images/menu_overflow.png "Three horizontal dots for the menu overflow options icon at end of each row.") **Menu overflow > Remove** in the row of the service ID. Click **Remove Service ID** on the confirmation dialog.
  - Remove the API key by clicking the service ID. On the service ID page, click **API keys**. Locate the API key being used by the application in the API keys list. CLick ![Menu overflow icon](../../images/menu_overflow.png "Three horizontal dots for the menu overflow options icon at end of each row.") **Menu overflow > Remove** in the row of the API key. Click **Remove API key** on the confirmation dialog.

**Note:** Revoking a service ID or API key in use by any Kafka client might not disable access for the application immediately. The API key is stored in a token cache in Kafka which has a 23 hour expiration period. When the token cache expires, it is refreshed from {{site.data.reuse.icp}} and any revoked service IDs or API keys are reflected in the new token cache, causing application access be be disabled.

To immediately disable application access, you can force a refresh of the Kafka token cache by restarting each Kafka broker. To do this without causing downtime, you can patch the stateful set by using the following command:

`kubectl -n <namespace> patch sts <release_name>-ibm-es-kafka-sts -p '{"spec":{"template":{"metadata":{"annotations":{"restarted":"123"}}}}}'`

This does not make changes to the broker configuration, but it still causes the Kafka brokers to restart one at a time, meaning no downtime is experienced.
