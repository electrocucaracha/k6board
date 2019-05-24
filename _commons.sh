#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c)
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o xtrace
set -o nounset

# install_k8s() - Install Kubernetes using kubespray tool
function install_k8s {
    echo "Deploying kubernetes"
    local kubespray_folder=/opt/kubespray
    local version=2.10.0

    # shellcheck disable=SC1091
    source /etc/os-release || source /usr/lib/os-release
    case ${ID,,} in
        rhel|centos|fedora)
            sudo yum install -y git
        ;;
    esac
    sudo git clone --depth 1 https://github.com/kubernetes-sigs/kubespray $kubespray_folder -b v$version
    sudo chown -R "$USER" $kubespray_folder
    sudo -E pip install -r $kubespray_folder/requirements.txt

    rm -f ./inventory/group_vars/all.yml 2> /dev/null
    echo "kubeadm_enabled: true" | tee ./inventory/group_vars/all.yml
    if [[ ${HTTP_PROXY+x} = "x" ]]; then
        echo "http_proxy: \"$HTTP_PROXY\"" | tee --append ./inventory/group_vars/all.yml
    fi
    if [[ ${HTTPS_PROXY+x} = "x" ]]; then
        echo "https_proxy: \"$HTTPS_PROXY\"" | tee --append ./inventory/group_vars/all.yml
    fi
    if [[ ${NO_PROXY+x} = "x" ]]; then
        echo "no_proxy: \"$NO_PROXY\"" | tee --append ./inventory/group_vars/all.yml
    fi

    # TODO: https://github.com/kubernetes-sigs/kubespray/pull/4780
    export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False
    ansible-playbook -vvv -i ./inventory/hosts.ini $kubespray_folder/cluster.yml --become | tee setup-kubernetes.log

    # Creation of temporal volumes
    for vol in vol1 vol2 vol3; do
        sudo mkdir /mnt/disks/$vol
        sudo mount -t tmpfs -o size=5G $vol /mnt/disks/$vol
    done

    # Configure environment
    mkdir -p "$HOME/.kube"
    sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
    sudo chown vagrant "$HOME/.kube/config"
}

# install_dashboard() - Function that installs Helms, InfluxDB and Grafana Dashboard
function install_dashboard {
    local helm_version=v2.13.1
    local helm_tarball=helm-${helm_version}-linux-amd64.tar.gz

    if ! command -v helm; then
        wget http://storage.googleapis.com/kubernetes-helm/$helm_tarball
        tar -zxvf $helm_tarball -C /tmp
        rm $helm_tarball
        sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
    fi

    helm init
    helm repo update

    helm install stable/influxdb --name metrics-db -f influxdb_values.yml
    helm install stable/grafana --name metrics-dashboard -f grafana_values.yml
}
