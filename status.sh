#!/usr/bin/env bash
#
# Copyright 2019 Marc Khouzam <marc.khouzam@gmail.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

set -e

usage="helm fullstatus RELEASE_NAME [flags]"
usage() {
    echo "Usage: $usage"
    exit 1
}

help() {
    echo "Helm plugin to show the status of kubernetes resources that are part of the specified helm release, similarly to how Helm v2 used to do."
    echo
    echo "Usage: $usage"
    echo
    echo "Flags: Same flags as the 'helm status' command"
    exit 0
}

RELEASE=""
for i in $@; do
    echo "loop $i"
    if [ "$i" = "-h" ] || [ "$i" = "--help" ]; then
        help
    elif [[ "${i}" == "-n" ]]; then
        nextIsNameSpace="true"
        echo "in -n ${i}" 
    elif [[ "${i}" != -* && "$nextIsNameSpace" != "true" ]]; then
        RELEASE=$i
        echo "in reles ${i}"
    elif [[ "$nextIsNameSpace" == "true" ]]; then
        NAMESPACE=$i
        nextIsNameSpace="false"
        echo "in namespace ${i}"
    fi
done

echo "hrlm_ns $HELM_NAMESPACE"
echo "conte $HELM_KUBECONTEXT"
echo "RELEASE: $RELEASE"

[ -z "${RELEASE}" ] && usage

CONTEXT=""
[ -n "${HELM_KUBECONTEXT}" ] && CONTEXT="--context $HELM_KUBECONTEXT"

$HELM_BIN status $@
echo;echo

echo "$HELM_BIN get manifest $RELEASE | kubectl get $CONTEXT --namespace $NAMESPACE -f -"
$HELM_BIN get manifest $RELEASE | \
        kubectl get $CONTEXT --namespace $HELM_NAMESPAC -f -
