#!/bin/bash

K8S_VERSION=1.26.1
CONTAINERD_VERSION=1.6.16
RUNC_VERSION=1.1.4
CNI_PLUGIN=1.2.0

cd /tmp/ || exit
apt-get update

# ------------------------------------
# Helper tools
# ------------------------------------

apt-get install -y apt-transport-https ca-certificates curl

# ------------------------------------
# Kernel prerequisites
# ------------------------------------
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# ------------------------------------
# Containerd setup
# ------------------------------------
wget https://github.com/containerd/containerd/releases
wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /usr/local/lib/systemd/system/
mv containerd.service /usr/local/lib/systemd/system/
systemctl daemon-reload
systemctl enable --now containerd
echo "check containerd service"
systemctl is-active containerd || exit

wget https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGIN}/cni-plugins-linux-amd64-v${CNI_PLUGIN}.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${CNI_PLUGIN}.tgz

mkdir -p /etc/containerd/
containerd config default > /etc/containerd/config.toml
sed -i -r 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl is-active containerd || exit

# ------------------------------------
# k8s components
# ------------------------------------
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
K8S_PKG_VERSION=$(apt-cache policy kubectl | grep -o Candidate:.*${K8S_VERSION}.* | cut -d: -f2 | tr -d " ")
apt-get install -y kubelet="${K8S_PKG_VERSION}" kubeadm="${K8S_PKG_VERSION}" kubectl="${K8S_PKG_VERSION}"
apt-mark hold kubelet kubeadm kubectl

systemctl daemon-reload
systemctl enable --now kubelet

kubeadm --help