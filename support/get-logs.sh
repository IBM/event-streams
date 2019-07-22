#!/bin/bash -x
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2018, 2019  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#


# This script collects the log files from available pods and tars them up.
# It uses the component label names instead of the pod names as the pod names could be truncated.
#
# Pre-conditions
# 1) kubectl must be installed
# 2) User must be logged into host e.g. cloudctl login -a https:<hostname>:8443 --skip-ssl-validation -u admin -p admin
#
# Usage
# . get-logs.sh
#  optional arguments:
#     -n|-ns|-namespace=#, where # is the required namespace. If not entered it retrieves logs from the default namespace as requested in the cloudctl login
#     -r|-rel|-release=#, where # is the required release name. If not entered it returns logs for all releases.
#  example:
#     . get-logs.sh -n=es -r=testrelease

DATE=`date +%d-%m-%y`

unset NAMESPACE
unset RELEASE

access_controller_component_name="security"
collector_componenet_name="collector"
elastic_component_name="elastic"
indexmgr_component_name="indexmgr"
kafka_component_name="kafka"
proxy_component_name="proxy"
rest_component_name="rest"
rest_producer_component_name="rest-producer"
rest_proxy_component_name="rest-proxy"
schema_registry_component_name="schemaregistry"
ui_component_name="ui"
zookeeper_component_name="zookeeper"

# Handle input arguments
while [ "$#" -gt 0 ]; do
    arg=$1
    case $1 in
        # convert "-opt=the value" to -opt "the value".
        -*'='*) shift; set - "${arg%%=*}" "${arg#*=}" "$@"; continue;;
        -n|-ns|-namespace) shift; NAMESPACE=$1;;
        -r|-rel|-release) shift; RELEASE=$1;;
        *) break;;
    esac
    shift
done

command='kubectl get pods __namespace__ -l component=__component____release__ --no-headers -o custom-columns=":metadata.name"'
netpolcommand='kubectl get netpol __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'
servicecommand='kubectl get svc __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'

# Substitute in namespace if given
if [ -n "${NAMESPACE}" ]; then
    command="${command//__namespace__/-n ${NAMESPACE}}"
    netpolcommand="${netpolcommand//__namespace__/-n ${NAMESPACE}}"
    servicecommand="${servicecommand//__namespace__/-n ${NAMESPACE}}"
else
    command="${command//__namespace__/}"
    netpolcommand="${netpolcommand//__namespace__/}"
    servicecommand="${servicecommand//__namespace__/}"
fi

# Substitute in release if given
if [ -n "${RELEASE}" ]; then
    command="${command//__release__/,release=${RELEASE}}"
    netpolcommand="${netpolcommand//__release__/-l release=${RELEASE}}"
    servicecommand="${servicecommand//__release__/-l release=${RELEASE}}"
else
    command="${command//__release__/}"
    netpolcommand="${netpolcommand//__release__/}"
    servicecommand="${servicecommand//__release__/}"
fi


logdir="tmpLogs"
netpollogdir="netpolLogs"
servicelogdir="serviceLogs"
rm -rf $logdir
mkdir -p $logdir
mkdir -p $logdir/$netpollogdir
mkdir -p $logdir/$servicelogdir

# Extract host information
echo -n -e "Extracting host information"
kubectl get namespaces > $logdir/namespaces.log
kubectl get nodes > $logdir/nodes.log
kubectl get deployment > $logdir/deployment.log
kubectl get pods > $logdir/pods.log
kubectl -n kube-system get pods > $logdir/kube-system.log
kubectl get pods -o yaml > $logdir/yaml.log
kubectl get pv > $logdir/pv.log
kubectl get pvc > $logdir/pvc.log
echo -e "\033[0;32m [DONE]\033[0m"

# ACCESS-CONTROLLER pods
accesscontrollercommand="${command//__component__/${access_controller_component_name}}"
pods=$(eval $accesscontrollercommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${accesscontrollercommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# COLLECTOR pods
collectorcommand="${command//__component__/${collector_componenet_name}}"
pods=$(eval $collectorcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${collectorcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# ELASTIC pods
elasticcommand="${command//__component__/${elastic_component_name}}"
pods=$(eval $elasticcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${elasticcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# INDEX-MANAGER pod
indexmgrcommand="${command//__component__/${indexmgr_component_name}}"
pods=$(eval $indexmgrcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${indexmgrcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# KAFKA pods
kafkacommand="${command//__component__/${kafka_component_name}}"
pods=$(eval $kafkacommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${kafkacommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# PROXY pods
proxycommand="${command//__component__/${proxy_component_name}}"
pods=$(eval $proxycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${proxycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST pod
restcommand="${command//__component__/${rest_component_name}}"
pods=$(eval $restcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST PRODUCER pod
restproducercommand="${command//__component__/${rest_producer_component_name}}"
pods=$(eval $restproducercommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restproducercommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST PROXY pod
restproxycommand="${command//__component__/${rest_proxy_component_name}}"
pods=$(eval $restproxycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restproxycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# SCHEMA REGISTRY pod
schemaregistrycommand="${command//__component__/${schema_registry_component_name}}"
pods=$(eval $schemaregistrycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${schemaregistrycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# UI pod
uicommand="${command//__component__/${ui_component_name}}"
pods=$(eval $uicommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${uicommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# ZOOKEEPER pods
zkcommand="${command//__component__/${zookeeper_component_name}}"
pods=$(eval $zkcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${zkcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# OAUTH LOGS
if [ -n "${NAMESPACE}" ]; then
    command="${command//-n ${NAMESPACE}/-n kube-system}"
else
    command="${command} -n kube-system"
fi

oauthcommand="${command//__component__/${ui_component_name}}"
pods=$(eval $oauthcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl -nkube-system describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl -nkube-system logs $pod > $logdir/$pod/oauth.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# NETWORK POLICIES
netpols=$(eval $netpolcommand)
for netpol in $netpols; do
    echo -n -e $netpol
    kubectl describe netpol $netpol > $logdir/$netpollogdir/$netpol-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# SERVICES
services=$(eval $servicecommand)
for service in $services; do
echo -n -e $service
    kubectl describe svc $service > $logdir/$servicelogdir/$service-describe.log
    kubectl describe svc $service
    echo -e "\033[0;32m [DONE]\033[0m"
done

# Tar the results
tar czf logs-$DATE.tar.gz $logdir
rm -rf $logdir
echo "COMPLETE - Results are in logs-$DATE.tar.gz"
