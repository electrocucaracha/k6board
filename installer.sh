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

KRD_ACTIONS=("install_k8s" "install_helm")
KRD_ACTIONS_DECLARE=$(declare -p KRD_ACTIONS)
export KRD_ACTIONS_DECLARE
export KRD_DEBUG=true
curl -fsSL https://raw.githubusercontent.com/electrocucaracha/krd/master/aio.sh | bash

helm install stable/influxdb --name metrics-db -f influxdb_values.yml
helm install stable/grafana --name metrics-dashboard -f grafana_values.yml
kubectl apply -f k6.yml
