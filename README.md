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

See [this routing lab with 8 VMs](labs/103/README.md)

![](labs/103/lab103-ospf-quad-pod_small.png)

## References

- https://github.com/dmacvicar/terraform-provider-libvirt
- https://hub.docker.com/r/larsks/libvirt/dockerfile
