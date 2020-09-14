# Terraform with Libvirt/KVM provider

Terraforms examples with [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/).

I use qemu/KVM images built with packer thanks to this project : [packer-kvm](https://github.com/goffinet/packer-kvm). They are regularly published on a website.

Only for education and learning purposes. Do not use it in production.

## What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.[What is Terraform?](https://www.terraform.io/intro/index.html)

Here we use the third party [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/) to manage Libvirt resources as networks, storage pools, volumes, template for cloud-init iso disk with count functions and any [provisioners](https://www.terraform.io/docs/provisioners/index.html).

## Local installation

Setup a local installation on your virtualization host with Libvirt, Terraform and the Libvirt provider plugin for Terraform (Ubuntu bionic) :

```
git clone https://github.com/goffinet/terraform-libvirt
cd terraform-libvirt/
bash -x setup.sh
```

## Projects

- [basics examples](https://github.com/goffinet/terraform-libvirt/tree/master/basics) terraform-provider-libvirt resources based on contribs.
- [network labs](https://github.com/goffinet/terraform-libvirt/tree/master/labs) ported from bash.

## Deploy with terraform

```bash
git clone https://github.com/goffinet/terraform-libvirt
cd terraform-libvirt/basics/ubuntu
terraform plan
```

## Use Docker

```
cd terraform-libvirt/basics/ubuntu
docker run --rm --privileged --cap-add=ALL \
-v /lib/modules:/lib/modules \
-v /var/lib/libvirt:/var/lib/libvirt \
-v /var/log:/var/log \
-v /run:/run \
-v `pwd`:/opt/ \
-w /opt/ \
-it \
goffinet/terraform terraform init
```

## Deploy a routing lab with Terraform on Libvirt/KVM

See [this routing lab with 8 VMs](labs/103/README.md).

![](labs/103/lab103-ospf-quad-pod_small.png)

## References

- https://github.com/dmacvicar/terraform-provider-libvirt
- https://hub.docker.com/r/larsks/libvirt/dockerfile
