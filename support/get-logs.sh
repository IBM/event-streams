#!/bin/bash
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2020  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

PROGRAM_NAME=$0
VERSION="2020.1.2"
DATE=`date +%d-%m-%y`
TIME=`date +%H-%M-%S`

usage() {
    printf "$PROGRAM_NAME v${VERSION}\n\n"
    printf "This script collects the log files from available pods and tars them up.\n"
    printf "It uses the component label names instead of the pod names as the pod names could be truncated.\n\n"
    printf "usage: $PROGRAM_NAME [-h] [-n|-ns|-namespace=NAMESPACE] [-r|-rel|-release=RELEASE]\n\n"
    printf "  -h                       display help\n"
    printf "  -n | -ns  | -namespace   specify the required NAMESPACE\n"
    printf "  -r | -rel | -release     specify the required RELEASE\n\n"
    printf "\nPre-conditions:\n"
    printf "  1) kubectl/oc must be installed\n"
    printf "  2) (preferred) helm & openssl installed\n"
    printf "  3) User must be logged into host as cluster-admin\n"
    printf "  4) User must know the namespace that Event Streams is deployed in, and the name of that release\n\n"
}

declare -a ES_COMPONENTS=(
    "security"
    "collector"
    "elastic"
    "indexmgr"
    "kafka"
    "proxy"
    "rest"
    "restproducer"
    "restproxy"
    "replicator"
    "schemaregistry"
    "ui"
    "zookeeper"
    "essential"
)

declare -a RESOURCES=(
    "nodes"
    "networkpolicies"
    "services"
    "persistentvolumes"
    "persistentvolumeclaims"
    "configmaps"
    "statefulsets"
    "deployments"
    "secrets"
    "storageclasses"
)

declare -a GLOBAL_RESOURCES=(
    "nodes"
    "persistentvolumes"
    "storageclasses"
)

declare -a EXTERNAL_ENDPOINTS=(
    "ibm-es-ui-svc"
    "ibm-es-rest-proxy-external-svc"
    "ibm-es-proxy-svc"
    "ibm-es-admin-api"
    "ibm-es-admin-ui"
    "ibm-es-admin-proxy"
)

declare -a KUBE_SYSTEM_COMPONENTS=(
    "auth-idp"
    "auth-pap"
    "auth-pdp"
)

declare -a KUBE_SYSTEM_APPS=(
    "helm"
    "kube-dns"
)

unset NAMESPACE
unset RELEASE

while [ "$#" -gt 0 ]; do
    arg=$1
    case $1 in
        -*'='*) shift; set - "${arg%%=*}" "${arg#*=}" "$@"; continue;;
        -n|-ns|-namespace) shift; NAMESPACE=$1;;
        -r|-rel|-release) shift; RELEASE=$1;;
        -h) usage;;
        *) break;;
    esac
    shift
done

if [ -z "$NAMESPACE" ] || [ -z "$RELEASE" ]; then
    tput setaf 1; 
    printf "Both the namespace and release name must be specified to run this script.\n"
    printf "Please re-run the script with these required arguements. \n\nExample:\n\n"
    printf "  ./get-logs.sh -n=myNamespace -r=myRelease\n\n"
    tput sgr0
    usage
    exit 1
fi

LOGDIR="es-diagnostics-${DATE}_${TIME}"
INVOCATION_DIR=$(pwd)
if [ -d ${INVOCATION_DIR}/${LOGDIR} ]; then
    tput setaf 3; 
    printf "The output directory \"${LOGDIR}\" already exists!\n"
    printf "Please rename or delete this directory and re-run.\n"; tput sgr0
    exit 1
fi

EXE=kubectl
printf "Checking for presence of kubectl or oc"
command -v $EXE > /dev/null
KUBECTL_PRESENCE=$(echo $?)
if [ "${KUBECTL_PRESENCE}" -ne 0 ]; then
    EXE=oc
    command -v $EXE > /dev/null
    OC_PRESENCE=$(echo $?)
    if [ "${OC_PRESENCE}" -ne 0 ]; then
        tput setaf 1; printf 'You must have kubectl or oc installed to run diagnostics\n'; tput sgr0
        exit 1
    fi
fi
tput setaf 2; printf '\t[DONE]\n'; tput sgr0

printf "Checking authorization"
$EXE auth can-i describe nodes > /dev/null
AUTHORIZED=$(echo $?)
if [ "${AUTHORIZED}" -ne 0 ]; then
    tput setaf 1; printf 'You must be logged in as cluster-admin to run diagnostics\n'; tput sgr0
    exit 1
fi
tput setaf 2; printf '\t[DONE]\n'; tput sgr0

tput setaf 3
printf "\n\n******************************  WARNING  ******************************\n"
printf "Due to the transient nature of the cluster - it may be necessary to run\n"
printf "this script a second time if the final message 'COMPLETE' is not shown.\n"
printf "***********************************************************************\n\n"
tput sgr0

mkdir $LOGDIR
printf "Diagnostics collection v${VERSION} started at ${DATE}_${TIME} for release: $RELEASE in namespace: ${NAMESPACE}\n" | tee -a $LOGDIR/output.log

HELM_PRESENCE=$(command -v helm > /dev/null; echo $?)
if [ "${HELM_PRESENCE}" -ne 0 ]; then
    tput setaf 3; printf '\n  Helm is desirable for diagnostics but absent on this system - continuing...\t[SKIP]\n' | tee -a $LOGDIR/output.log; tput sgr0 
else
    printf "Checking Helm client capability\n" | tee -a $LOGDIR/output.log
    HELM_OK=$(helm history ${RELEASE} --tls > /dev/null; echo $?)
    if [ "${HELM_OK}" -ne 0 ]; then
        tput setaf 1; printf 'Helm client is not able to comminicate with the cluster - continuing...\t[ERR]\n' | tee -a $LOGDIR/output.log; tput sgr0 
    else
        printf "  Gathering Helm history" | tee -a $LOGDIR/output.log
        HELM_DIR=${LOGDIR}/helm
        mkdir -p $HELM_DIR
        helm history ${RELEASE} --tls > $HELM_DIR/helm_history.log
        tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0

        printf "  Gathering Helm values" | tee -a $LOGDIR/output.log
        helm get values ${RELEASE} --tls > $HELM_DIR/helm_values.log
        linecert=$(eval grep -n -w "cert:" $HELM_DIR/helm_values.log | cut -f1 -d:)
        linekey=$(eval grep -n -w "key:" $HELM_DIR/helm_values.log | cut -f1 -d:)
        [ ! -z "$linecert" ] && (sed -i '' -e "${linecert}s/.*/  cert: REDACTED/" $HELM_DIR/helm_values.log || echo "sed command failed, continue gathering diagnostics")
        [ ! -z "$linekey" ] && (sed -i '' -e "${linekey}s/.*/  key: REDACTED/" $HELM_DIR/helm_values.log || echo "sed command failed, continue gathering diagnostics")
        tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
    fi
fi

printf "Gathering overview information" | tee -a $LOGDIR/output.log
$EXE get namespaces > $LOGDIR/namespaces.log
$EXE get nodes --show-labels -o wide > $LOGDIR/nodes.log
$EXE get pods -n $NAMESPACE -o wide -L zone > $LOGDIR/es-pods.log
$EXE get pods -n kube-system  > $LOGDIR/kube-system-pods.log
$EXE get pods -n $NAMESPACE -o json > $LOGDIR/es-pods-json.json
tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0

get_container_logs () {
    NS=$1
    POD=$2
    printf "Gathering diagnostics for pod: ${POD}\n" | tee -a $LOGDIR/output.log
    POD=$(tr -cd '\11\12\15\40-\176' <<< $POD )
    POD_DIR=$LOGDIR/$POD
    mkdir -p $POD_DIR
    $EXE describe pod $POD -n $NS > $POD_DIR/pod-describe.log
    CONTAINERS=$($EXE get po $POD -n $NS -o jsonpath="{.spec.containers[*].name}")
    JOB_NAME=$($EXE get pod $POD -n $NS -o jsonpath="{.metadata.ownerReferences[?(@.kind == 'Job')].name}" | tr -cd '\11\12\15\40-\176')
    if [ $JOB_NAME ]; then
        printf "  Gathering Job logs" | tee -a $LOGDIR/output.log
        $EXE logs $POD -n $NS > $POD_DIR/$JOB_NAME.log
        tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0 
    else
        for CONTAINER in ${CONTAINERS[@]}; do
            printf "  Gathering diagnostics for container: ${CONTAINER}\n" | tee -a $LOGDIR/output.log
            CONTAINER=$(tr -cd '\11\12\15\40-\176' <<< $CONTAINER)
            PHASE=$($EXE get po $POD -n $NS -o jsonpath="{.status.phase}" | tr -cd '\11\12\15\40-\176')
            if [ "${PHASE}" == "Running" ]; then
                if [ ! -s $POD_DIR/etc_hosts.log ]; then
                    printf "    Retrieving hosts file" | tee -a $LOGDIR/output.log
                    $EXE exec $POD -n $NS -c $CONTAINER -it -- sh -c "cat /etc/hosts" > $POD_DIR/etc_hosts.log
                    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
                fi
                if [ ! -s $POD_DIR/resolv_conf.log ]; then
                    printf "    Retrieving resolv.conf file" | tee -a $LOGDIR/output.log
                    $EXE exec $POD -n $NS -c $CONTAINER -it -- sh -c "cat /etc/resolv.conf" > $POD_DIR/resolv_conf.log
                    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
                fi
            fi
            printf "    Gathering container logs" | tee -a $LOGDIR/output.log
            $EXE logs $POD -n $NS -c $CONTAINER > $POD_DIR/container_log-$CONTAINER.log
            tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
            RESTART_COUNT=$($EXE get po $POD -n $NS -o jsonpath="{.status.containerStatuses[?(@.name == \"$CONTAINER\")].restartCount}" | tr -cd '\11\12\15\40-\176')
            if [ $RESTART_COUNT -ne 0 ]; then
                printf "    Gathering previous container logs" | tee -a $LOGDIR/output.log
                $EXE logs $POD -n $NS -c $CONTAINER --previous > $POD_DIR/previous_container_log-$CONTAINER.log
                tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
            fi
        done
    fi
}

# Gather container logs/descriptions/manifests for ES components
TEMPLATE_COMMAND='$EXE get pods -n $NAMESPACE -l release=$RELEASE --no-headers -o custom-columns=":metadata.name" -l component=__component__'
for COMPONENT in "${ES_COMPONENTS[@]}"; do
    COMMAND="${TEMPLATE_COMMAND//__component__/${COMPONENT}}"
    PODS=$(eval $COMMAND)
    for POD in $PODS; do
        get_container_logs $NAMESPACE $POD
    done 
done

# Gather descriptions and manifests for non-pod resources
for RESOURCE in "${RESOURCES[@]}"; do
    RESOURCE_DIR=${LOGDIR}/${RESOURCE}
    mkdir -p $RESOURCE_DIR
    if [[ " ${GLOBAL_RESOURCES[@]} " =~ " ${RESOURCE} " ]]; then
        $EXE get $RESOURCE -o wide > $RESOURCE_DIR/$RESOURCE-get.log
        ITEM_NAMES=$($EXE get $RESOURCE --no-headers -o custom-columns=":metadata.name")
    else
        $EXE get $RESOURCE -n $NAMESPACE -l release=$RELEASE -o wide > $RESOURCE_DIR/$RESOURCE-get.log
        ITEM_NAMES=$($EXE get $RESOURCE -n $NAMESPACE -l release=$RELEASE --no-headers -o custom-columns=":metadata.name")
    fi
    for ITEM_NAME in $ITEM_NAMES; do
        printf "Gathering diagnostics for $RESOURCE: $ITEM_NAME" | tee -a $LOGDIR/output.log
        ITEM_NAME=$(tr -cd '\11\12\15\40-\176' <<< $ITEM_NAME)
        $EXE describe $RESOURCE $ITEM_NAME -n $NAMESPACE > $RESOURCE_DIR/$ITEM_NAME-describe.log
        if [ "$RESOURCE" != "secrets" ]; then
            $EXE get $RESOURCE $ITEM_NAME -n $NAMESPACE -o json > $RESOURCE_DIR/$ITEM_NAME-json.json
        fi
        tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
    done
done

# Gather logs/descriptions/manifests for supporting elements

printf "Gathering ICP kube-public configmap(s)" | tee -a $LOGDIR/output.log
ICP_CONFIGMAP_NAMES=$($EXE get configmaps -n kube-public --no-headers -o custom-columns=":metadata.name")
for CONFIGMAP_NAME in $ICP_CONFIGMAP_NAMES; do
    CONFIGMAP_NAME=$(tr -cd '\11\12\15\40-\176' <<< $CONFIGMAP_NAME)
    $EXE describe configmap $CONFIGMAP_NAME -n kube-public > $LOGDIR/$CONFIGMAP_NAME-describe.log
done
tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0

############
printf "Gather kube etcd diagnostics if applicable\n" | tee -a $LOGDIR/output.log; tput sgr0
KUBE_ETCD_POD_NAMES=$($EXE get pods -n kube-system --no-headers -o custom-columns=":metadata.name" | grep "k8s-etcd-" || true )
for KUBE_ETCD_POD_NAME in $KUBE_ETCD_POD_NAMES; do
    get_container_logs kube-system "${KUBE_ETCD_POD_NAME[@]}"
done

printf "Gather kube system dependency logs if applicable\n" | tee -a $LOGDIR/output.log; tput sgr0
for COMPONENT in "${KUBE_SYSTEM_COMPONENTS[@]}"; do
    KUBE_SYSTEM_POD_NAMES=$($EXE get pods -n kube-system -l component="${COMPONENT}" --no-headers -o custom-columns=":metadata.name")
    for POD in $KUBE_SYSTEM_POD_NAMES; do
        get_container_logs kube-system "${POD[@]}"
    done 
done
for APP in "${KUBE_SYSTEM_APPS[@]}"; do
    KUBE_SYSTEM_POD_NAMES=$($EXE get pods -n kube-system -l app="${APP}" --no-headers -o custom-columns=":metadata.name")
    for POD in $KUBE_SYSTEM_POD_NAMES; do
        get_container_logs kube-system "${POD[@]}"
    done 
done
############

printf "Gather kubectl top diagnostics" | tee -a $LOGDIR/output.log; tput sgr0
[ "$EXE" == "oc" ] && TOP_COMMAND="adm"
$EXE ${TOP_COMMAND} top pods -n kube-system -l app=icp-mongodb > $LOGDIR/mongodb-resource-usage.log
$EXE ${TOP_COMMAND} top nodes > $LOGDIR/nodes-resource-usage.log
tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0

# Legacy
printf "Gather legacy certgen diagnostics if applicable\n" | tee -a $LOGDIR/output.log; tput sgr0
LEGACY_CERT_GEN_POD_NAMES=$($EXE get pods -n kube-system -l component=essential -l release=$RELEASE --no-headers -o custom-columns=":metadata.name")
for LEGACY_CERT_GEN_POD_NAME in $LEGACY_CERT_GEN_POD_NAMES; do
    get_container_logs kube-system ${LEGACY_CERT_GEN_POD_NAME[@]}
done

# Legacy
printf "Gather legacy oauth diagnostics if applicable\n" | tee -a $LOGDIR/output.log; tput sgr0
LEGACY_OAUTH_POD_NAMES=$($EXE get pods -n kube-system -l component=ui -l release=$RELEASE --no-headers -o custom-columns=":metadata.name")
for LEGACY_OAUTH_POD_NAME in $LEGACY_OAUTH_POD_NAMES; do
    get_container_logs kube-system ${LEGACY_OAUTH_POD_NAME[@]}
done

printf "Checking for presence of openssl" | tee -a $LOGDIR/output.log; tput sgr0
command -v openssl > /dev/null
OPENSSL_PRESENCE=$(echo $?)
if [ "${OPENSSL_PRESENCE}" -ne 0 ]; then
    tput setaf 3; printf '\n  openssl is desirable for diagnostics but absent on this system - continuing...\t[SKIP]\n' | tee -a $LOGDIR/output.log; tput sgr0
else
    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
fi

printf "Gathering proxy certificates\n" | tee -a $LOGDIR/output.log
PROXY_SECRET_IDENT="ibm-es-proxy-secret"
PROXY_SECRET_NAME=$($EXE get secrets -n $NAMESPACE -l release=$RELEASE --no-headers -o custom-columns=":metadata.name" | grep $PROXY_SECRET_IDENT | head -n1 )

declare -a CERTIFICATES=(
    "https\.cert"
    "podtls\.cert"
    "podtls\.cacert"
    "tls\.cert"
    "tls\.cluster"
    "tls\.cacert"
)

CERT_DIR=${LOGDIR}/proxy-certificates
mkdir -p $CERT_DIR
for CERTIFICATE in ${CERTIFICATES[@]}; do
    NAME=$(echo "$CERTIFICATE" | tr -d \\)
    CERTIFICATE=$(tr -cd '\11\12\15\40-\176' <<< $CERTIFICATE)
    printf "  Get encoded certificate: $NAME" | tee -a $LOGDIR/output.log
    $EXE get secret -n $NAMESPACE $PROXY_SECRET_NAME -o=jsonpath="{.data.${CERTIFICATE}}" > $CERT_DIR/$NAME
    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
    if [ -s $CERT_DIR/$NAME ]; then
        # Attempt decode
        printf "  Decode certificate: $NAME" | tee -a $LOGDIR/output.log
        base64 --decode $CERT_DIR/$NAME > $CERT_DIR/decoded-$NAME
        tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
        if [ "${OPENSSL_PRESENCE}" -eq 0 ]; then
            # Attempt openssl
            printf "  Inspect certificate: $NAME" | tee -a $LOGDIR/output.log
            openssl x509 -text -in $CERT_DIR/decoded-$NAME > $CERT_DIR/openssl-$NAME
            tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
        else
            tput setaf 3; printf 'openssl not available on this system - skipping certificate inspection... \t[SKIP]\n' | tee -a $LOGDIR/output.log; tput sgr0
        fi
    else
        rm -f $CERT_DIR/$NAME
    fi
done

if [ "${OPENSSL_PRESENCE}" -eq 0 ]; then
    # Get public presented certificates from external endpoints
    EXTERNAL_PRESENTED_CERTS_DIR=${LOGDIR}/presented-certificates-external
    mkdir -p $EXTERNAL_PRESENTED_CERTS_DIR
    printf "Gathering external host address" | tee -a $LOGDIR/output.log
    PROXY_CM_MAP=$($EXE get cm -n $NAMESPACE -l release=$RELEASE -l component=proxy --no-headers -o custom-columns=":metadata.name")
    PROXY_CM_MAP=$(tr -cd '\11\12\15\40-\176' <<< $PROXY_CM_MAP)
    HOST=$($EXE get cm -n $NAMESPACE $PROXY_CM_MAP -o jsonpath="{.data.externalHostOrIP}")
    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
    for ENDPOINT in "${EXTERNAL_ENDPOINTS[@]}"; do
        printf "Gathering connection details for endpoint: $ENDPOINT\n" | tee -a $LOGDIR/output.log
        SVC_NAMES=$($EXE get svc -n $NAMESPACE -l release=$RELEASE --no-headers -o custom-columns=":metadata.name" | grep "${ENDPOINT}" || true )
        for SVC_NAME in $SVC_NAMES; do
            SVC_NAME=$(tr -cd '\11\12\15\40-\176' <<< $SVC_NAME)
            NODEPORTS=$($EXE get svc -n $NAMESPACE $SVC_NAME -o jsonpath="{.spec.ports[*].nodePort}")
            for NODEPORT in $NODEPORTS; do
                printf "  Get presented certificate at endpoint: ${HOST}:${NODEPORT}" | tee -a $LOGDIR/output.log
                HOST=$(tr -cd '\11\12\15\40-\176' <<< $HOST)
                NODEPORT=$(tr -cd '\11\12\15\40-\176' <<< $NODEPORT)
                CONNECT_RC=$(echo -n | openssl s_client -connect ${HOST}:${NODEPORT} &> /dev/null; echo $?)
                if [ "${CONNECT_RC}" -eq 0 ]; then
                    echo -n | openssl s_client -connect ${HOST}:${NODEPORT} &> $EXTERNAL_PRESENTED_CERTS_DIR/${ENDPOINT}-${HOST}-${NODEPORT}.log
                    tput setaf 2; printf '\t[DONE]\n' | tee -a $LOGDIR/output.log; tput sgr0
                else
                    tput setaf 1; printf ' \t[ERR]\n' | tee -a $LOGDIR/output.log; tput sgr0
                fi
            done
        done
    done
else
    tput setaf 3; printf 'openssl not available on this system - skipping endpoint certificate discovery... \t[SKIP]\n' | tee -a $LOGDIR/output.log; tput sgr0
fi

printf "\n--- END OF GATHER ---\n" | tee -a $LOGDIR/output.log

# Sanitise and archive diagnostics
find $LOGDIR -type f -empty -delete
TARBALL=${LOGDIR}.tar.gz
tar czf $TARBALL $LOGDIR
if [ -s $TARBALL ]; then
    tput setaf 2; printf "\nCOMPLETE - Results are in ${LOGDIR}.tar.gz\n" | tee -a $LOGDIR/output.log; tput sgr0
    rm -rf $LOGDIR
else
    tput setaf 1; printf "\nThere was an issue creating \"${LOGDIR}.tar.gz\"\n" | tee -a $LOGDIR/output.log; tput sgr0
fi
