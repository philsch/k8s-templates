#!/bin/bash

CALICO_VERSION=3.25.0

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml

echo "done"
echo "you can watch the calico pod state via: watch get pods -n calico-system"