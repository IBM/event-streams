---
title: "Migrating to Apicurio Registry"
excerpt: "Migrating from the deprecated schema registry to Apicurio Registry."
categories: installing
slug: migrating-to-apicurio
toc: true
---

## Overview

The {{site.data.reuse.short_name}} schema registry for managing [schemas](../../schemas/overview/) is deprecated in version 10.1.0 and later. It is replaced by the [Apicurio Registry](https://www.apicur.io/registry/docs/apicurio-registry/index.html){:target="_blank"}, an open-source schema registry.

This means that the registry for schemas is set by using the Apicurio Registry configuration option `spec.apicurioRegistry` in the `EventStreams` custom resource (instead of the deprecated `spec.schemaRegistry` setting).

To migrate from the deprecated schema registry to the Apicurio Registry, you will need to move your schemas to the new registry and reconfigure any applications that use those schemas to connect to the new registry, as described in the following sections.

**Note:** You only need to migrate if you have an existing {{site.data.reuse.short_name}} installation where you are using the schema registry with existing schemas.

## Migrating

To migrate your schemas to the Apicurio Registry, use the following steps:

1. Ensure that you have [upgraded](../../installing/upgrading/) your {{site.data.reuse.short_name}} version to 10.2.0.
2. Update the `EventStreams` custom resource to use the new Apicurio Registry configuration, ensuring not to delete the `spec.schemaRegistry` field. Deleting this field  will disrupt any clients currently using the schema registry and may result in schema data loss.

   The following is an example snippet showing how to add Apicurio in the custom resource:

   ```
   # ...
   spec:
     # ...
     apicurioRegistry: {}
   ```

   **Note:** This will trigger a warning to appear in the status conditions of the `EventStreams` custom resource, informing a user they have both registries deployed. Ignore this for now, as we are currently migrating them and once finished with this migration the warning will be removed.

3. Wait until the operator has updated the {{site.data.reuse.short_name}} instance to include the newly deployed Apicurio Registry. You can check if Apicurio has been included by running the following command:

   `oc get eventstreams <instance_name> -ojsonpath={.status.routes.ac-reg-external}`

   Where `<instance_name>` is the name of your {{site.data.reuse.short_name}} instance. This will return a route name when the instance has been updated.

   When the Apicurio Registry is up we can start migrating the schemas.

4. Migrate the schemas to the Apicurio Registry. Ensure you have logged into the CLI. If prompted to choose a schema registry on login, pick the deprecated registry:

   ```
   cloudctl es init -n <namespace>

   Select a schema registry service:
   1. Apicurio Registry
   2. Event Streams Schema Registry (deprecated)
   Enter a number>
   ```

   Enter number 2, picking the deprecated schema registry.

5. Export your schemas from the deprecated registry as follows:

   `cloudctl es schemas-export --file my-schemas.zip`

   A message similar to this should appear:
   ```
   Schemas to export: X
   Exported Y versions from schema my-schema-1
   Exported Z versions from schema my-schema-2
   ...
   Exported schemas successfully written to /tmp/my-schemas.zip
   OK
   ```
   **Note:** This should normally take less than a minute but may take longer for schema registries with many large schemas.

6. Switch over to the Apicurio Registry by running the `init` command again, this time selecting `Apicurio Registry`:

   ```
   cloudctl es init -n <namespace>

   Select a schema registry service:
   1. Apicurio Registry
   2. Event Streams Schema Registry (deprecated)
   Enter a number>
   ```
   Enter number `1` to select the Apicurio Registry.

7. Import your schemas into the new Apicurio Registry by running:

   `cloudctl es schemas-import my-schemas.zip`

   **Note:** Subsequent runs of this command will not add pre-existing schemas again.

8. Validate that all schemas are migrated into the Apicurio Registry by running:

   `cloudctl es schemas`

   Check that all previously used schemas are present and listed.

9. Switch clients over to use the schemas in the Apicurio Registry by changing their configuration to use the new Apicurio Registry route.
   d
   If using the {{site.data.reuse.short_name}} Java serdes, update the `com.ibm.eventstreams.serdes.SchemaRegistryConfig.PROPERTY_API_URL` property value as follows:
   ```
   props.put(SchemaRegistryConfig.PROPERTY_API_URL, "https://<route_address>");
   ```
   Where `<route_address>` is the output of `oc get eventstreams <instance_name> -ojsonpath={.status.routes.ac-reg-external}`

10. When all schemas and clients have been migrated over to use the Apicurio Registry, you can safely remove the `spec.schemaRegistry` key and any configuration you applied to it. Run the following command:\\
   `oc edit eventstreams <instance_name>`\\
   Where `<instance_name>` is the name of your {{site.data.reuse.short_name}} instance.\\
   Alternatively, the same edit can be made through the {{site.data.reuse.openshift_short}} web console.


## Cleaning up persistence

Apicurio Registry persists its data in {{site.data.reuse.short_name}} Kafka topics, and not in persistent storage.

If you used persistence for the previous schema registry, and you have validated that all required schema registry data has been successfully migrated to the Apicurio Registry as described in the previous section, then you can delete the `PersistentVolumeClaim` (PVC) and `PersistentVolume` (PV) used by the previous registry. These are not automatically deleted to ensure that if the schema registry is accidentally removed, data loss does not occur.

To delete the previous PVCs and PVs that are no longer required:

1. Identify the previous schema registry PVC by running the following command, replacing `<instance_name>` with the name of your {{site.data.reuse.short_name}} installation:

   `oc get pvc -l app.kubernetes.io/instance=<instance_name>,app.kubernetes.io/name=schema-registry`

   This command displays an output similar to the following example:
   ```
   NAME                            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
   <instance_name>-ibm-es-schema   Bound    pvc-7bb4d042-7fb3-4334-9c64-12d9c4806e4a   100Mi      RWO            rook-ceph-block   100d
   ```
   Make a note of the value in the `VOLUME` field, this is the persistent volume that the claim is bound to.

2. Delete the PVC by running the following command:

   `oc delete pvc <instance_name>-ibm-es-schema`

   Where `<instance_name>` is the name of your {{site.data.reuse.short_name}} installation.

3. Deletion of the PVC will also delete the underlying PV for many types of storage. However, some storage types might leave the PV in place without deleting it. In such cases, manually delete the related PV.

   - Check if the PV has been deleted:
   `oc get pv <volume_name>`\\
   Where `<volume_name>` is the previously noted value from the `VOLUME` field, defining the volume name that the claim was bound to.

   - If this command returns no PV, then all relevant PVs have already been deleted automatically. If it has not been deleted, the PV can be used for other applications, or it can be deleted by running the follwing command:\\
   `oc delete pv <volume_name>`
