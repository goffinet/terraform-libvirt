# Lab 101

## Topologie

![lab101](https://www.lucidchart.com/publicSegments/view/cddee598-583c-41a4-8523-d17129144dfd/image.png)

## Description

Deux facilités réseaux :

* Un commutateur (switch) isolé qui fait office de réseau local appelé `lan101`
* Un routeur NAT/IPv6 qui fait office d'Internet appelé `wan101`

Deux machines :

* Un client connecté au switch `lan101` (eth0)
* Un routeur connecté au switch `lan101` (eth0) et au switch `wan101` (eth1) qui rendra les services DNS, DHCP, DHCPv6, SLAAC sur lan101. Les plages du LAN sont adressées en `192.168.168.0/24` et `fd00:168:168::/64`.

## Usage

Déploiement de la topologie.

```bash
docker run --rm --privileged --cap-add=ALL -v /lib/modules:/lib/modules -v /var/lib/libvirt:/var/lib/libvirt -v /var/log:/var/log -v /run:/run -v `pwd`:/opt/ -w /opt/ -it goffinet/terraform /bin/terraform init
docker run --rm --privileged --cap-add=ALL -v /lib/modules:/lib/modules -v /var/lib/libvirt:/var/lib/libvirt -v /var/log:/var/log -v /run:/run -v `pwd`:/opt/ -w /opt/ -it goffinet/terraform /bin/terraform apply -auto-approve
```

Entrer dans le routeur virtuel.

```bash
virsh console r101
```

Source du lab101 : https://github.com/goffinet/virt-scripts/blob/master/labs/101/
