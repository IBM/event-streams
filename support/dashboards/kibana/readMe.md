**Installing Event Streams Kibana Dashboards**
==========

The following Kibana dashboards can be used to help monitor problems with the underlying infrastructure and Kafka. Various dashboards are included which will help to diagnose what may have gone wrong with your Event Streams.

**Dashboards**
---

- **Authentication and Authorization Dashboard:** This dashboard monitors Access Controller and Kafka to determine whether it can communicate with IBM Cloud Private.
- **File System Dashboard:** This dashboard monitors the logs in Kafka and Zookeeper for various file system related exceptions.
- **Kubernetes Infrastructure Dashboard:** This dashboard monitors  various Kubernetes containers for problems that may suggest an unhealthy infrastructure and Kafka to see how many times the Broker is unavailable.
- **Network Dashboard:** This dashboard monitors Kafka and Zookeeper for various network related exceptions. It will also check the Kafka logs to see if it can communicate with Zookeeper. The dashboard also monitors for Event Streams related errors in the Kubernetes DNS pod.

**To Install**
---

Follow the following steps to install the Event Streams Kibana Dashboards:

1. Download `Event Streams Kibana Dashboard.json` from the repo.
2. Navigate to the IBM Cloud Private console homepage.
3. Click the sandwich icon on the top left of the screen to bring up the drop down menu.
4. Click the `Platform` tile in the dropdown menu to bring up another dropdown menu.
5. Click the `Logging` tile from the inner dropdown menu to navigate you to the Kibana homepage.
6. Click the `Management` tab on the left hand side menu.
7. Click on the `Saved Objects`.
8. Click the `Import` icon and navigate the `Event Streams Kibana Dashboard.json` that you have downloaded.
9. Click on the `Dashboard` tab on the left hand side menu and you should see the downloaded dashboards.
