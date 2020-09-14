#!/bin/bash

tf_version=0.13.2

if [ "$EUID" -ne 0 ] ; then echo "Please run as root" ; exit ; fi

1_virtualization_installation () {
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y upgrade
apt-get -y install wget unzip
apt-get -y install qemu-kvm libvirt-dev virtinst virt-viewer libguestfs-tools virt-manager uuid-runtime curl linux-source libosinfo-bin
virsh net-start default
virsh net-autostart default
elif [ -f /etc/redhat-release ]; then
yum -y install wget unzip
yum -y install epel-release
yum -y upgrade
yum -y group install "Virtualization Host"
yum -y install virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts virt-top libguestfs-tools virt-viewer virt-manager curl
fi
}

2_terraform-provider-libvirt_installation () {
echo "security_driver = \"none\"" >> /etc/libvirt/qemu.conf
systemctl restart libvirtd
currentd=$PWD
cd /tmp
wget https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip
unzip terraform_${tf_version}_linux_amd64.zip
chmod +x terraform
mv terraform /usr/local/bin/
source /etc/os-release
if [ $ID == "ubuntu" ] && [ $VERSION_ID == "18.04" ] ; then
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
tar xvf terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Ubuntu_18.04.amd64.tar.gz
mkdir -p ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64
cp -r terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64/
fi
cd $currentd
}

3_docker_installation () {
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y install python3-pip
elif [ -f /etc/redhat-release ]; then
yum -y install python3-pip
fi
pip3 install docker-compose
}

1_virtualization_installation
2_terraform-provider-libvirt_installation
3_docker_installation
