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

PROGRAM_NAME="${0}"
VERSION="2020.1.4"
DATE=`date +%d-%m-%y`
TIME=`date +%H-%M-%S`

####################################################################################################
# Script helper functions
####################################################################################################

usage() {
    printf "${PROGRAM_NAME} v${VERSION}\n\n"
    printf "This script collects the log files from available pods and tars them up.\n"
    printf "It uses the component label names instead of the pod names as the pod names could be truncated.\n\n"
    printf "usage: ${PROGRAM_NAME} [-h] [-n|-ns|-namespace=NAMESPACE] [-r|-rel|-release=RELEASE]\n\n"
    printf "  -h                       display help\n"
    printf "  -n | -ns  | -namespace   specify the required NAMESPACE\n"
    printf "  -r | -rel | -release     specify the required RELEASE\n\n"
    printf "  -s | -since              specify how many hours back the logs should go (default 120)n"
    printf "\nPre-conditions:\n"
    printf "  1) kubectl/oc must be installed\n"
    printf "  2) (preferred) helm & openssl installed\n"
    printf "  3) User must be logged into host as cluster-admin\n"
    printf "  4) User must know the namespace that Event Streams is deployed in, and the name of that release\n\n"
}

# prints the incoming to the terminal and writes it to the output.log
printAndLog () {
    tee -a "${LOGDIR}/output.log"
}

# only print valid printable characters
cleanOutput () {
    tr -cd '\11\12\15\40-\176'
}

# print the supplied text in red by setting the forground colour to red then unsetting it
printRed () {
    tput setaf 1
    printf "${@}"
    tput sgr0
}

# print the supplied text in green
printGreen () {
    tput setaf 2
    printf "${@}"
    tput sgr0
}

# print the supplied text in yellow
printYellow () {
    tput setaf 3
    printf "${@}"
    tput sgr0
}

# print the supplied text in red and write it to the log, note `printRed blah | printAndLog` will give formatting problems in the log
printRedAndLog () {
    tput setaf 1
    printf "${@}" | printAndLog
    tput sgr0
}

# print the supplied text in green and write it to the log
printGreenAndLog () {
    tput setaf 2
    printf "${@}" | printAndLog
    tput sgr0
}

# print the supplied text in yellow and write it to the log
printYellowAndLog () {
    tput setaf 3
    printf "${@}" | printAndLog
    tput sgr0
}

# print the standard green done message
printDone () {
    printGreen "\t[DONE]\n"
}

# print the standard green done message and write it to the log
printDoneAndLog () {
    printGreenAndLog "\t[DONE]\n"
}

####################################################################################################
# Configuration
####################################################################################################

declare -a ES_HELM_COMPONENT_LABELS=(
    "component=collector"
    "component=elastic"
    "component=essential"
    "component=indexmgr"
    "component=kafka"
    "component=proxy"
    "component=replicator"
    "component=rest"
    "component=restproducer"
    "component=restproxy"
    "component=schemaregistry"
    "component=security"
    "component=ui"
    "component=zookeeper"
)

declare -a RESOURCES=(
    "networkpolicies"
    "services"
    "persistentvolumeclaims"
    "configmaps"
    "statefulsets"
    "deployments"
    "secrets"
    "routes"
)

declare -a GLOBAL_RESOURCES=(
    "nodes"
    "persistentvolumes"
    "storageclasses"
)


declare -a EXTERNAL_ENDPOINTS_SERVICES=(
    "ibm-es-ui-svc"
    "ibm-es-rest-proxy-external-svc"
    "ibm-es-proxy-svc"
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

declare -a CERT_SECRETS=(
    "ibm-es-proxy-secret"
)

declare -a CERTIFICATES_KEYS=(
    "https\.cert"
    "podtls\.cert"
    "podtls\.cacert"
    "tls\.cert"
    "tls\.cluster"
    "tls\.cacert"
)

####################################################################################################
# Check user input and system capabilities required to run
####################################################################################################

unset NAMESPACE
unset RELEASE
unset SINCE
SINCE=120

# Read in the required parameters. the releases name and namespace
while [ "${#}" -gt 0 ]; do
    arg="${1}"
    case "${1}" in
        -*"="*) shift; set - "${arg%%=*}" "${arg#*=}" "${@}"; continue;;
        -n|-ns|-namespace) shift; NAMESPACE="${1}";;
        -r|-rel|-release) shift; RELEASE="${1}";;
        -s|-since) shift; SINCE="${1}";;
        -h) usage;;
        *) break;;
    esac
    shift
done

# Assert that the required fields were supplied
if [ -z "${NAMESPACE}" ] || [ -z "${RELEASE}" ]; then
    printRed "Both the namespace and release name must be specified to run this script.\n"
    printRed "Please re-run the script with these required arguements. \n\nExample:\n\n"
    printRed "  ./get-logs.sh -n=myNamespace -r=myRelease\n\n"
    usage
    exit 1
fi

ES_HELM_RELEASE_LABEL="release=${RELEASE}"

# Check to see if the log output directory can be created
LOGDIR="es-diagnostics-${DATE}_${TIME}"
INVOCATION_DIR=$(pwd)
if [ -d "${INVOCATION_DIR}/${LOGDIR}" ]; then
    printYellow "The output directory \"${LOGDIR}\" already exists!\n"
    printYellow "Please rename or delete this directory and re-run.\n"
    exit 1
fi

# Check to see if kubectl or oc is available, prefers kubectl over oc
EXE=kubectl
printf "Checking for presence of kubectl or oc"
command -v "${EXE}" > /dev/null
KUBECTL_PRESENCE=$(echo ${?})
if [ "${KUBECTL_PRESENCE}" -ne 0 ]; then
    EXE=oc
    command -v "${EXE}" > /dev/null
    OC_PRESENCE=$(echo ${?})
    if [ "${OC_PRESENCE}" -ne 0 ]; then
        printRed 'You must have kubectl or oc installed to run diagnostics\n'
        exit 1
    fi
fi
printDone

# Check that the user running the script is a cluster-admin
printf "Checking authorization"
${EXE} auth can-i describe nodes > /dev/null
AUTHORIZED=$(echo ${?})
if [ "${AUTHORIZED}" -ne 0 ]; then
    printRed 'You must be logged in as cluster-admin to run diagnostics\n'
    exit 1
fi
printDone

# make the output directory so we can start storing information using printAndLog
mkdir "${LOGDIR}"

####################################################################################################
# Check user input and system capabilities that are optional
####################################################################################################

# Check to see if the user has openssl available
printf "Checking for presence of openssl" | printAndLog
command -v openssl > /dev/null
OPENSSL_PRESENCE=$(echo ${?})
if [ "${OPENSSL_PRESENCE}" -ne 0 ]; then
    printYellowAndLog '\n  openssl is desirable for diagnostics but absent on this system - continuing...\t[SKIP]\n'
else
    printDoneAndLog
fi

####################################################################################################
# Final steps before starting
####################################################################################################

# Print out a disclaimer about multiple runs potentially being required
printYellow "\n\n******************************  WARNING  ******************************\n"
printYellow "Due to the transient nature of the cluster - it may be necessary to run\n"
printYellow "this script a second time if the final message 'COMPLETE' is not shown.\n"
printYellow "***********************************************************************\n\n"

# Perpare and begin diasnostics collection
RELEASE_LABEL="${ES_HELM_RELEASE_LABEL}"
COMPONENT_LABELS=("${ES_HELM_COMPONENT_LABELS[@]}")
printf "Diagnostics collection v${VERSION} started at ${DATE}_${TIME} for release: ${RELEASE} in namespace: ${NAMESPACE}\n" | printAndLog

####################################################################################################
# Gathering helper functions
####################################################################################################

get_pod_logs () {
    NS="${1}"
    POD="${2}"
    PARAMS="${3}"
    POD_DIR="${LOGDIR}/${POD}"
    printf "Gathering diagnostics for pod: ${POD}\n" | printAndLog
    mkdir -p "${POD_DIR}"
    ${EXE} describe pod "${POD}" -n "${NS}" > "${POD_DIR}/pod-describe.log"
    CONTAINERS=$(${EXE} get pod ${POD} -n ${NS} -o jsonpath="{.spec.containers[*].name}" | cleanOutput )
    JOB_NAME=$(${EXE} get pod ${POD} -n ${NS} -o jsonpath="{.metadata.ownerReferences[?(@.kind == 'Job')].name}" | cleanOutput)
    if [ "${JOB_NAME}" ]; then
        printf "  Gathering Job logs" | printAndLog
        ${EXE} logs "${POD}" -n "${NS}" --since="${SINCE}h" ${PARAMS} > "${POD_DIR}/${JOB_NAME}.log"
        printDoneAndLog
    else
        for CONTAINER in ${CONTAINERS[@]}; do
            get_container_diagnostics "${NS}" "${POD}" "${CONTAINER}" "${POD_DIR}"
            get_container_logs "${NS}" "${POD}" "${CONTAINER}" "${POD_DIR}" "${PARAMS}"
        done
    fi
}

get_container_diagnostics () {
    NS="${1}"
    POD="${2}"
    CONTAINER="${3}"
    DIR="${4}"
    printf "  Gathering diagnostics for container: ${CONTAINER}\n" | printAndLog
    PHASE=$(${EXE} get pod ${POD} -n ${NS} -o jsonpath="{.status.phase}" | cleanOutput )
    if [ "${PHASE}" == "Running" ]; then
        if [ ! -s "${DIR}/etc_hosts.log" ]; then
            printf "    Retrieving hosts file" | printAndLog
            ${EXE} exec "${POD}" -n "${NS}" -c "${CONTAINER}" -it -- sh -c "cat /etc/hosts" > "${DIR}/etc_hosts.log"
            printDoneAndLog
        fi
        if [ ! -s ${DIR}/resolv_conf.log ]; then
            printf "    Retrieving resolv.conf file" | printAndLog
            ${EXE} exec "${POD}" -n "${NS}" -c "${CONTAINER}" -it -- sh -c "cat /etc/resolv.conf" > "${DIR}/resolv_conf.log"
            printDoneAndLog
        fi
    fi
}

get_container_logs () {
    NS="${1}"
    POD="${2}"
    CONTAINER="${3}"
    DIR="${4}"
    PARAMS="${5}"
    printf "    Gathering container logs" | printAndLog
    ${EXE} logs "${POD}" -n "${NS}" -c "${CONTAINER}" --since="${SINCE}h" ${PARAMS} > "${DIR}/container_log-${CONTAINER}.log"
    printDoneAndLog
    RESTART_COUNT=$(${EXE} get pod ${POD} -n ${NS} -o jsonpath="{.status.containerStatuses[?(@.name == \"${CONTAINER}\")].restartCount}" | cleanOutput)
    if [ "${RESTART_COUNT}" -ne 0 ]; then
        printf "    Gathering previous container logs" | printAndLog
        ${EXE} logs "${POD}" -n "${NS}" -c "${CONTAINER}" --previous --limit-bytes=10000000 ${PARAMS} > "${DIR}/previous_container_log-${CONTAINER}.log"
        printDoneAndLog
    fi
}

analyse_cert () {
    DIR="${1}"
    NAME="${2}"
    if [ -s "${DIR}/${NAME}" ]; then
        # Attempt decode
        printf "  Decode certificate: ${NAME}" | printAndLog
        base64 --decode "${DIR}/${NAME}" > "${DIR}/decoded-${NAME}"
        printDoneAndLog
        if [ "${OPENSSL_PRESENCE}" -eq 0 ]; then
            # Attempt openssl
            printf "  Inspect certificate: ${NAME}" | printAndLog
            openssl x509 -text -in "${DIR}/decoded-${NAME}" > "${DIR}/openssl-${NAME}"
            printDoneAndLog
        else
            printYellowAndLog 'openssl not available on this system - skipping certificate inspection... \t[SKIP]\n'
        fi
    else
        echo "No Certicate at ${DIR}/${NAME}, removing"
        rm -f "${DIR}/${NAME}"
    fi
}

get_external_endpoint_cert () {
    ADDRESS="${1}"
    OUTPUT_FILE="${2}"
    if [ "${OPENSSL_PRESENCE}" -eq 0 ]; then
        printf "  Get presented certificate at endpoint: ${ADDRESS}" | printAndLog
        CONNECT_RC=$(echo -n | openssl s_client -connect ${ADDRESS} -servername ${ADDRESS} &> /dev/null; echo ${?})
        if [ "${CONNECT_RC}" -eq 0 ]; then
            echo -n | openssl s_client -connect "${ADDRESS}" -servername "${ADDRESS}" &> "${OUTPUT_FILE}"
            printDoneAndLog
        else
            printRedAndLog ' \t[ERR]\n'
        fi
    else
        printYellowAndLog 'openssl not available on this system - skipping endpoint certificate discovery... \t[SKIP]\n'
    fi
}

####################################################################################################
# Gather logs/descriptions/manifests for the namespace
####################################################################################################

# Gather information about the release as a whole - namespaces, nodes, pods etc.
printf "Gathering overview information" | printAndLog
${EXE} get pods -n "${NAMESPACE}" -o wide -L zone > "${LOGDIR}/es-pods.log"
${EXE} get pods -n "${NAMESPACE}" -o json > "${LOGDIR}/es-pods-json.json"
printDoneAndLog

####################################################################################################
# Gather logs/descriptions/manifests for the desired release
####################################################################################################

# Gather container logs/descriptions/manifests for ES components
for COMPONENT_LABEL in ${COMPONENT_LABELS[@]}; do
    PODS=$(${EXE} get pods -n ${NAMESPACE} -l ${RELEASE_LABEL} -l ${COMPONENT_LABEL} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
    for POD in ${PODS[@]}; do
        echo "${NAMESPACE} ${POD}"
        get_pod_logs "${NAMESPACE}" "${POD}"
    done 
done

# Gather descriptions and manifests for non-pod resources
for RESOURCE in ${RESOURCES[@]}; do
    RESOURCE_DIR="${LOGDIR}/${RESOURCE}"
    mkdir -p "${RESOURCE_DIR}"

    ${EXE} get "${RESOURCE}" -n "${NAMESPACE}" -l "${RELEASE_LABEL}" -o wide > "${RESOURCE_DIR}/${RESOURCE}-get.log"
    ITEM_NAMES=$(${EXE} get ${RESOURCE} -n ${NAMESPACE} -l ${RELEASE_LABEL} --no-headers -o custom-columns=":metadata.name" | cleanOutput)

    for ITEM_NAME in ${ITEM_NAMES[@]}; do
        printf "Gathering diagnostics for ${RESOURCE}: ${ITEM_NAME}" | printAndLog
        ${EXE} describe "${RESOURCE}" "${ITEM_NAME}" -n "${NAMESPACE}" > "${RESOURCE_DIR}/${ITEM_NAME}-describe.log"
        if [ "${RESOURCE}" != "secrets" ]; then
            ${EXE} get "${RESOURCE}" "${ITEM_NAME}" -n "${NAMESPACE}" -o json > "${RESOURCE_DIR}/${ITEM_NAME}-json.json"
        fi
        printDoneAndLog
    done
done

# Gather descriptions and manifests for global resources
for RESOURCE in ${GLOBAL_RESOURCES[@]}; do
    RESOURCE_DIR="${LOGDIR}/${RESOURCE}"
    mkdir -p "${RESOURCE_DIR}"

    ${EXE} get "${RESOURCE}" -o wide > "${RESOURCE_DIR}/${RESOURCE}-get.log"
    ITEM_NAMES=$(${EXE} get ${RESOURCE} --no-headers -o custom-columns=":metadata.name" | cleanOutput)

    for ITEM_NAME in ${ITEM_NAMES[@]}; do
        printf "Gathering diagnostics for ${RESOURCE}: ${ITEM_NAME}" | printAndLog
        ${EXE} describe "${RESOURCE}" "${ITEM_NAME}" -n "${NAMESPACE}" > "${RESOURCE_DIR}/${ITEM_NAME}-describe.log"
        if [ "${RESOURCE}" != "secrets" ]; then
            ${EXE} get "${RESOURCE}" "${ITEM_NAME}" -n "${NAMESPACE}" -o json > "${RESOURCE_DIR}/${ITEM_NAME}-json.json"
        fi
        printDoneAndLog
    done
done

printf "Gathering certificates from secrets\n" | printAndLog
for SECRET in ${CERT_SECRETS[@]}; do
    SECRET_NAME="${RELEASE}-${SECRET}"
    CERT_DIR="${LOGDIR}/${SECRET_NAME}-certificates"
    mkdir -p "${CERT_DIR}"
    for CERTIFICATE_KEY in ${CERTIFICATES_KEYS[@]}; do
        NAME=$(echo ${CERTIFICATE_KEY} | tr -d '\\')
        printf "  Get encoded certificate: ${NAME}" | printAndLog
        ${EXE} get secret -n "${NAMESPACE}" "${SECRET_NAME}" -o=jsonpath="{.data.${CERTIFICATE_KEY}}" > "${CERT_DIR}/${NAME}"
        printDoneAndLog
        analyse_cert "${CERT_DIR}" "${NAME}"
    done
done

## NOTE: this make no sense in operator
printf "Gathering external host address" | printAndLog
PROXY_CM_MAP=$(${EXE} get cm -n ${NAMESPACE} -l ${RELEASE_LABEL} -l component=proxy --no-headers -o custom-columns=":metadata.name" | cleanOutput)
HOST=$(${EXE} get cm -n ${NAMESPACE} ${PROXY_CM_MAP} -o jsonpath="{.data.externalHostOrIP}" | cleanOutput)
printDoneAndLog

printf "Gathering certs from external services\n" | printAndLog
EXTERNAL_PRESENTED_CERTS_DIR="${LOGDIR}/presented-certificates-external"
mkdir -p "${EXTERNAL_PRESENTED_CERTS_DIR}"
for SERVICE in ${EXTERNAL_ENDPOINTS_SERVICES[@]}; do
    printf "Gathering connection details for endpoint: ${SERVICE}\n" | printAndLog
    SVC_TYPE=$(${EXE} get svc -n ${NAMESPACE} ${RELEASE}-${SERVICE} -o jsonpath="{.spec.type}" | cleanOutput)
    if [ "${SVC_TYPE}" == "NodePort" ]; then
        NODEPORTS=$(${EXE} get svc -n ${NAMESPACE} ${RELEASE}-${SERVICE} -o jsonpath="{.spec.ports[*].nodePort}" | cleanOutput)
        for NODEPORT in ${NODEPORTS[@]}; do
            get_external_endpoint_cert "${HOST}:${NODEPORT}" "${EXTERNAL_PRESENTED_CERTS_DIR}/${SERVICE}-${HOST}-${NODEPORT}.log"
        done
    fi
done

printf "Gathering certs from routes\n" | printAndLog
HAS_ROUTES=$(${EXE} api-resources | cleanOutput | grep route.openshift.io &> /dev/null; echo ${?})
if [ "${HAS_ROUTES}" -eq 0 ]; then
    ROUTES=$(${EXE} get routes -n ${NAMESPACE} -l ${RELEASE_LABEL} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
    for ROUTE in ${ROUTES[@]}; do
    printf "Gathering connection details for route ${ROUTE}\n" | printAndLog
    TLS_ENABLED=$(${EXE} get route -n ${NAMESPACE} ${ROUTE} -o jsonpath="{.spec.tls}" | cleanOutput)
    ADDRESS=$(${EXE} get route -n ${NAMESPACE} ${ROUTE} -o jsonpath="{.spec.host}" | cleanOutput)
    if [ "${TLS_ENABLED}" != "<none>" ]; then
        get_external_endpoint_cert "${ADDRESS}:443" "${EXTERNAL_PRESENTED_CERTS_DIR}/${ROUTE}.log"
    fi
    done
    printDoneAndLog
else
    printDoneAndLog
fi

# ####################################################################################################
# # Gather logs/descriptions/manifests for supporting elements. Helm, ICP, CS etc.
# ####################################################################################################

${EXE} get namespaces > "${LOGDIR}/namespaces.log"
${EXE} get nodes --show-labels -o wide > "${LOGDIR}/nodes.log"
${EXE} get pods -n kube-system  > "${LOGDIR}/kube-system-pods.log"

# If Helm is present collect the helm history and values for the release. If it is not continue to the next step
HELM_PRESENCE=$(command -v helm > /dev/null; echo ${?})
if [ "${HELM_PRESENCE}" -ne 0 ]; then
    printYellowAndLog '\n  Helm is desirable for diagnostics but absent on this system - continuing...\t[SKIP]\n'
else
    printf "Checking Helm client capability\n" | printAndLog
    HELM_OK=$(helm history ${RELEASE} --tls > /dev/null; echo ${?})
    if [ "${HELM_OK}" -ne 0 ]; then
        printRedAndLog 'Helm client is not able to comminicate with the cluster - continuing...\t[ERR]\n'
    else
        printf "  Gathering Helm history" | printAndLog
        HELM_DIR="${LOGDIR}/helm"
        mkdir -p "${HELM_DIR}"
        helm history "${RELEASE}" --tls > "${HELM_DIR}/helm_history.log"
        printDoneAndLog

        printf "  Gathering Helm values" | printAndLog
        helm get values "${RELEASE}" --tls > "${HELM_DIR}/helm_values.log"
        CERT_VALUE_LINE=$(eval grep -n -w "cert:" ${HELM_DIR}/helm_values.log | cut -f1 -d:)
        KEY_VALUE_LINE=$(eval grep -n -w "key:" ${HELM_DIR}/helm_values.log | cut -f1 -d:)
        [ ! -z "${CERT_VALUE_LINE}" ] && (sed -i '' -e "${CERT_VALUE_LINE}s/.*/  cert: REDACTED/" "${HELM_DIR}/helm_values.log" || true )
        [ ! -z "${KEY_VALUE_LINE}" ] && (sed -i '' -e "${KEY_VALUE_LINE}s/.*/  key: REDACTED/" "${HELM_DIR}/helm_values.log" || true )
        printDoneAndLog
    fi
fi

printf "Gathering kube-public configmap(s)" | printAndLog
CONFIGMAP_NAMES=$(${EXE} get configmaps -n kube-public --no-headers -o custom-columns=":metadata.name" | cleanOutput)
for CONFIGMAP in ${CONFIGMAP_NAMES[@]}; do
    ${EXE} describe configmap "${CONFIGMAP}" -n kube-public > "${LOGDIR}/${CONFIGMAP}-describe.log"
done
printDoneAndLog

printf "Gather etcd diagnostics if applicable\n" | printAndLog
ETCD_POD_NAMES=$(${EXE} get pods -n openshift-etcd --no-headers -o custom-columns=":metadata.name" | cleanOutput)
for ETCD_POD_NAME in ${ETCD_POD_NAMES[@]}; do
    get_pod_logs openshift-etcd "${ETCD_POD_NAME}" "--timestamps"
done

printf "Gather openshift-dns logs if applicable\n" | printAndLog
DNS_PODS=$(${EXE} get pods -n openshift-dns --no-headers -o custom-columns=":metadata.name" | cleanOutput)
for POD in ${DNS_PODS[@]}; do
    get_pod_logs openshift-dns "${POD}" "--timestamps"
done

# NOTE: bellow need to be moved to legacy and new versions added when adding operator pieces
printf "Gather kube system dependency logs if applicable\n" | printAndLog
for COMPONENT in ${KUBE_SYSTEM_COMPONENTS[@]}; do
    KUBE_SYSTEM_POD_NAMES=$(${EXE} get pods -n kube-system -l component=${COMPONENT} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
    for POD in ${KUBE_SYSTEM_POD_NAMES[@]}; do
        get_pod_logs kube-system "${POD}" "--timestamps"
    done 
done
for APP in ${KUBE_SYSTEM_APPS[@]}; do
    KUBE_SYSTEM_POD_NAMES=$(${EXE} get pods -n kube-system -l app=${APP} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
    for POD in ${KUBE_SYSTEM_POD_NAMES[@]}; do
        get_pod_logs kube-system "${POD}" "--timestamps"
    done 
done

printf "Gather kubectl top diagnostics" | printAndLog
[ "${EXE}" == "oc" ] && TOP_COMMAND_DELTA="adm"
${EXE} ${TOP_COMMAND_DELTA} top pods -n kube-system -l app=icp-mongodb > "${LOGDIR}/mongodb-resource-usage.log"
${EXE} ${TOP_COMMAND_DELTA} top nodes > "${LOGDIR}/nodes-resource-usage.log"
printDoneAndLog

####################################################################################################
# Legacy gathering. Move legacy gathering under here
####################################################################################################

printf "Gather kube etcd diagnostics if applicable\n" | printAndLog
KUBE_ETCD_POD_NAMES=$(${EXE} get pods -n kube-system --no-headers -o custom-columns=":metadata.name" | cleanOutput | grep "k8s-etcd-" || true )
for POD_NAME in ${KUBE_ETCD_POD_NAMES[@]}; do
    get_pod_logs kube-system "${POD_NAME}" "--timestamps"
done

printf "Gather legacy certgen diagnostics if applicable\n" | printAndLog
LEGACY_CERT_GEN_POD_NAMES=$(${EXE} get pods -n kube-system -l component=essential -l ${RELEASE_LABEL} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
for POD_NAME in ${LEGACY_CERT_GEN_POD_NAMES[@]}; do
    get_pod_logs kube-system "${POD_NAME}"
done

printf "Gather legacy oauth diagnostics if applicable\n" | printAndLog
LEGACY_OAUTH_POD_NAMES=$(${EXE} get pods -n kube-system -l component=ui -l ${RELEASE_LABEL} --no-headers -o custom-columns=":metadata.name" | cleanOutput)
for POD_NAME in ${LEGACY_OAUTH_POD_NAMES[@]}; do
    get_pod_logs kube-system "${POD_NAME}"
done

####################################################################################################
# Gathering finished package and finish
####################################################################################################

printf "\n--- END OF GATHER ---\n" | printAndLog

# Sanitise and archive diagnostics
find "${LOGDIR}" -type f -empty -delete
TARBALL="${LOGDIR}.tar.gz"
tar czf "${TARBALL}" "${LOGDIR}"
if [ -s "${TARBALL}" ]; then
    printGreenAndLog "\nCOMPLETE - Results are in ${LOGDIR}.tar.gz\n"
    rm -rf "${LOGDIR}"
else
    printRedAndLog "\nThere was an issue creating \"${LOGDIR}.tar.gz\"\n"
fi
