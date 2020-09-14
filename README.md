# Terraform with Libvirt/KVM provider

Terraforms examples with [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt/).

I use qemu/KVM images built with packer thanks to this project : [packer-kvm](https://github.com/goffinet/packer-kvm). They are regularly published on a website.

Only for education and learning purposes. Do not use it in production.

## Local installation

Setup a local installation with Libvirt, Terraform and the Libvirt provider plugin (Ubuntu bionic) :

```
bash -x setup.sh
```

## Projects

- [basics examples](https://github.com/goffinet/terraform-libvirt/tree/master/basics) terraform-provider-libvirt ressources based on contribs
- [network labs](https://github.com/goffinet/terraform-libvirt/tree/master/labs) ported from bash

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
