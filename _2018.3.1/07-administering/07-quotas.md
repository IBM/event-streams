---
title: "Setting client quotas"
excerpt: "Setting quotas"
categories: administering
slug: quotas
toc: true
---

Kafka quotas enforce limits on produce and fetch requests to control the broker resources used by clients.

Using quotas, administrators can throttle client access to the brokers by imposing network bandwidth or data limits, or both.

![Event Streams 2018.3.1 and later icon](../../../images/2018.3.1.svg "In Event Streams 2018.3.1 and later.") Kafka quotas are supported in {{site.data.reuse.long_name}} 2018.3.1 and later.

## About Kafka quotas

In a collection of clients, quotas protect from any single client producing or consuming significantly larger amounts of data than the other clients in the collection. This prevents issues with broker resources not being available to other clients, DoS attacks on the cluster, or badly behaved clients impacting other users of the cluster.

After a client that has a quota defined reaches the maximum amount of data it can send or receive, their throughput is stopped until the end of the current quota window. The client automatically resumes receiving or sending data when the quota window of 1 second ends.

By default, clients have unlimited quotas.

For further information about quotas, see the [Kafka documentation](https://kafka.apache.org/documentation/#design_quotas).

## Setting quotas

You can set quotas by using the {{site.data.reuse.short_name}} CLI as follows:

1. {{site.data.reuse.icp_cli_login}}
2. Run the following command to initialize the {{site.data.reuse.short_name}} CLI:\\
   `cloudctl es init`
3. Use the `entity-config` command option to set quotas as follows.

Decide what you want to limit by using a **quota type**, and set it with the `--config <quota_type>`option, where `<quota_type>` can be one of the following:
- `producer_byte_rate` - This quota limits the number of bytes that a producer application is allowed to send per second.
- `consumer_byte_rate` - This quota limits the number of bytes that a consumer application is allowed to receive per second.
- `request_percentage` - This quota limits all clients based on [thread utilisation](https://kafka.apache.org/documentation/#design_quotascpu).

Decide whether you want to apply the quota to **users or client IDs**.

To apply to users, use the `--user <user>` option. {{site.data.reuse.short_name}} supports 2 types of users: actual user principal names, or application service IDs.
- A quota defined for a user principal name is only applied to that specific user name. To specify a principal name, you must prefix the value for the `--user` parameter with `u-`, for example, `--user "u-testuser1"`.
- A quota defined for a service ID is applied to all applications that are using API keys that have been bound to the specific service ID. To specify a service ID, you must prefix the value for the `--user` parameter with `s-`, for example, `--user "s-consumer_service_id"`.

To apply to client IDs, use the `--client <client id>` option. Client IDs are defined in the application using the `client.id` property. A client ID identifies an application making a request.

You can apply the quota setting to all users or client IDs by using the `--user-default` or `--client-default` parameters, respectively. Quotas set for specific users or client IDs override default values set by these parameters.

By using these quota type and user or client ID parameters, you can set quotas using the following combinations:

   `cloudctl es entity-config --user <user> --config <quota_type>=<value>`

   `cloudctl es entity-config --user-default --config <quota_type>=<value>`

   `cloudctl es entity-config --client <client id> --config <quota_type>=<value>`

   `cloudctl es entity-config --client-default --config <quota_type>=<value>`

### Examples

For example, the following setting specifies that user `u-testuser1` can only send 2048 bytes of data per second:\\
`cloudctl es entity-config --user "u-testuser1" --config producer_byte_rate=2048`

For example, the following setting specifies that all application client IDs can only receive 2048 bytes of data per second:\\
`cloudctl es entity-config --client-default --config consumer_byte_rate=2048`

The `cloudctl es entity-config` command is dynamic, so any quota setting is applied immediately without the need to restart clients.

**Note:** If you run any of the commands with the `--default` parameter, the specified quota is reset to the system default value for that user or client ID (which is unlimited).
For example:\\
    `cloudctl es entity-config --user "s-consumer_service_id" --default --config producer_byte_rate`
