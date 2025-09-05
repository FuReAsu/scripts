#!/bin/bash
#Kubernetes Node Startup

#Get Node type
echo please specify the node type 'M for Master and W for Worker'
read -p 'M or W: ' nodetype

#Perform dnf exclusion to keep the current rocky version
DNF_CONF="/etc/dnf/dnf.conf"
EXCLUDE="exclude=kernel* rocky-release* rocky-repo* rocky-gpg-keys* grub* systemd* dracut* glibc*"

if ! grep -Fxq "$EXCLUDE" "$DNF_CONF"; then
    sudo echo "$EXCLUDE" | sudo tee -a "$DNF_CONF" > /dev/null
    echo "DNF exclusion line added to $DNF_CONF"
else
    echo "DNF exclusion line already exists 
    SKIPPING..."    
fi

sleep 2

sudo dnf update --assumeyes

sleep 2

#install vmware tools and chrony
sudo dnf install chrony --assumeyes
sudo systemctl enable --now chronyd

sleep 2

sudo sed -i 's|2\.rocky\.pool\.ntp\.org|asia.pool.ntp.org|g' /etc/chrony.conf

sudo systemctl restart chronyd
sudo chronyc refresh

sleep 2

#turn off selinux
sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

sleep 2

#firewall rules
if [[ "$nodetype" == M ]]
then
    sudo firewall-cmd --add-port=6443/tcp --permanent
    sudo firewall-cmd --add-port=2379-2380/tcp --permanent
    sudo firewall-cmd --add-port=10250/tcp --permanent
    sudo firewall-cmd --add-port=10259/tcp --permanent
    sudo firewall-cmd --add-port=10257/tcp --permanent
    sudo firewall-cmd --add-port=179/tcp --permanent
    sudo firewall-cmd --add-port=10256/tcp --permanent
    sudo firewall-cmd --add-port=30000-32767/tcp --permanent
fi

if [[ "$nodetype" == W ]]
then
    sudo firewall-cmd --add-port=10250/tcp --permanent
    sudo firewall-cmd --add-port=10256/tcp --permanent
    sudo firewall-cmd --add-port=179/tcp --permanent
    sudo firewall-cmd --add-port=30000-32767/tcp --permanent
fi

sudo firewall-cmd --add-port=7946/tcp --permanent
sudo firewall-cmd --add-port=7946/udp --permanent
sudo firewall-cmd --add-protocol=ipip --permanent
sudo firewall-cmd --add-source=0.0.0.0/0 --permanent
sudo firewall-cmd --zone=public --add-interface=tunl0 --permanent
sudo firewall-cmd --reload
echo firewall rules added for notetype $nodetype

sleep 2

K8S_VER=v1.32
CRIO_VER=v1.32

#cri-o repo
sudo echo "[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VER/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VER/rpm/repodata/repomd.xml.key" | sudo tee /etc/yum.repos.d/cri-o.repo > /dev/null

echo added crio repo
sleep 2

#k8s repo
sudo echo "[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$K8S_VER/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$K8S_VER/rpm/repodata/repomd.xml.key" | sudo tee /etc/yum.repos.d/k8s.repo > /dev/null

echo added k8s repo
sleep 2

#install CRI-O & K8S
sudo dnf update --assumeyes
sudo dnf install cri-o kubeadm kubelet kubectl --assumeyes

#start crio
sudo systemctl enable --now crio
sudo systemctl enable --now kubelet

sleep 2

#hold the version of crio and k8s
sudo echo "exclude=cri-o" | sudo tee -a /etc/yum.repos.d/cri-o.repo > /dev/null
sudo echo "exclude=kubeadm kubelet kubectl cri-tools" | sudo tee -a /etc/yum.repos.d/k8s.repo > /dev/null

sleep 2

#disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sleep 2

#enable modules
sudo echo "overlay
br_netfilter" | sudo tee /etc/modules-load.d/cri-o.conf > /dev/null

sudo modprobe overlay
sudo modprobe br_netfilter

#system configurations
sudo echo "net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
kernel.printk = 3 4 1 3" | sudo tee /etc/sysctl.d/k8s.conf > /dev/null

#reload system configurations
sudo sysctl --system

sudo systemctl daemon-reload && sudo systemctl restart kubelet

sudo echo "192.168.52.10  k8s-lab-m1
192.168.52.11 k8s-lab-w1
192.168.52.12 k8s-lab-w2" | sudo tee -a /etc/hosts > /dev/null

echo added records to hosts file

sleep 2

sudo echo " --resolv-conf=/etc/resolv.conf" | sudo tee /var/lib/kubelet/kubeadm-flags.env > /dev/null

sleep 2

echo "All the prerequisites done, now try running 'kubeadm init' or 'kubeadm join'"