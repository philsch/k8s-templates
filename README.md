k8s bootstrapping and templates
================================

🚧 This repo is updated while I'm working on my test cluster.

Collection of scripts and templates to bootstrap k8s. Tested on Ubuntu 22.04.

## Bootstrap

### Control Plane

1. Prepare machine `00-prepare.sh`
2. Create single node control plane `01-init-single-control-plane.sh`
3. Add an overlay network `02-cni-calico.sh`

### Worker node

1. Prepare machine `00-prepare.sh`
2. Run `kubeadm token create —print-join-command` on Control Plane
3. Execute join command on worker node 