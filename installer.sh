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
set -o errexit
set -o nounset

# Install dependencies
pkgs=""
for pkg in docker kind kubectl helm; do
    if ! command -v "$pkg"; then
        pkgs+=" $pkg"
    fi
done
if [ -n "$pkgs" ]; then
    curl -fsSL http://bit.ly/install_pkg | PKG=$pkgs bash
fi
newgrp docker <<EONG
cat << EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30086
        hostPort: 30086
EOF
EONG
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add influxdata https://influxdata.github.io/helm-charts
helm repo update

echo "Install infrastructure (Grafana and InfluxDB)"
helm install metrics-db influxdata/influxdb -f influxdb_values.yml
helm install metrics-dashboard stable/grafana -f grafana_values.yml

echo "Create Kubernetes resources"
kubectl apply -f k6.yml
