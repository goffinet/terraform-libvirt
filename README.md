# Terraform with Libvirt/KVM provider

Terraforms examples with [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/).

Only for education and learning purposes.

## Local installation

Setup a local installation with Libvirt, Terraform and the Libvirt provider plugin (Ubuntu bionic) :

```
bash -x setup.sh
```

## Deploy with terraform

```bash
git clone https://github.com/goffinet/terraform-libvirt
cd terraform-libvirt/basics/ubuntu
terraform plan
```

## Docker

```bash
if [ "$EUID" -ne 0 ] ; then echo "Please run as root" ; exit ; fi
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y install python3-pip
elif [ -f /etc/redhat-release ]; then
yum -y install python3-pip
fi
pip3 install docker-compose
```

```
docker run --rm --privileged --cap-add=ALL \
-v /lib/modules:/lib/modules \
-v /var/lib/libvirt:/var/lib/libvirt \
-v /var/log:/var/log \
-v /run:/run \
-v `pwd`:/opt/ \
-w /opt/ \
-it \
goffinet/terraform
```
