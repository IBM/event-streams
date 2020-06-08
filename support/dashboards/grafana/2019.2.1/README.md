**Installing Event Streams Grafana Dashboards**
==========

The following Grafana dashboards can be used to monitor Event Streams instances.

**Dashboards**
---

- **IBM Event Streams Overview:** This dashboard monitors provides an overview of the Event Streams pods status and provides various metrics that determine the health of the Kafka brokers.
- **IBM Performance Event Streams Overview:** This dashboard monitors the CPU usage and memory usage per pod of various Event Streams pods such as Kafka, Access Controller and Collector.

**To Install**
---

Follow the following steps to install the Event Streams Grafana Dashboards:

1. Download the dashboards you would like to install from the repo.
2. Navigate to the IBM Cloud Private console homepage.
3. Click the sandwich icon on the top left of the screen to bring up the drop down menu.
4. Click the `Platform` tile in the dropdown menu to bring up another dropdown menu.
5. Click the `Monitoring` tile from the inner dropdown menu to navigate you to the Grafana homepage.
6. On the Grafana homepage, click on the `Home` icon on the top left of the screen to bring down a view of all the pre-installed dashboards.
7. Click on the `Import Dashboards` and either paste the JSON of the dashboard you want to install or import the dashboard's JSON file that was installed in step 1.
8. Navigate to the Grafana homepage again and click on the `Home` icon again then find the Dashboard you have installed to view it.
