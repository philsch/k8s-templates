#!/bin/bash

#
# Dynamic configs
#
echo "Networks:"
ifconfig | grep "inet\ .*"
ifconfig | grep "inet6\ .*"

echo "Control Plane IP? (e.g. 10.0.0.1)"
read -r control_plane_ip
echo "Pod network CIDR? (e.g. 192.168.0.0/16)"
read -r pod_cidr

#
# Kubeadm
#
kubeadm init \
 --pod-network-cidr="${pod_cidr}" \
 --apiserver-advertise-address="${control_plane_ip}"

#
# Move config
#
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
