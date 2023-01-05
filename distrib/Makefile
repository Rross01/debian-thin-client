#!/usr/bin/make -f

SHELL := /bin/bash

all: install_buildenv build

install_buildenv:
	# Install packages required to build the image
	sudo apt -y install live-build make build-essential wget git unzip colordiff apt-transport-https \
	rename ovmf rsync python3-venv gnupg squashfs-tools gettext po4a debhelper-compat \
	qemu-system qemu-kvm libvirt-clients libvirt-daemon-system \
	bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin
	chmod +x auto/*

##############################

clean:
	sudo lb clean --all

build:
	# Build the live system/ISO image
	sudo lb clean --all
	sudo lb config
	sudo lb build

################################

tests: copy_iso test_kvm_bios test_kvm_uefi

copy_iso:
	mkdir /var/lib/libvirt/images -p
	cp live-image-amd64.hybrid.iso /var/lib/libvirt/images/live-image-amd64.hybrid.iso --force

test_kvm_bios:

	# Run the resulting image in KVM/virt-manager (legacy BIOS mode)

	virsh net-start default 2>/dev/null || echo "Skip" 

	virsh destroy dlc-test 2>/dev/null || echo "Skip" 
	virsh undefine dlc-test 2>/dev/null || echo "Skip"


	virt-install \
	--name dlc-test \
	--boot hd,cdrom \
	--network=default \
	--video virtio \
	--disk path=/var/lib/libvirt/images/dlc-test-disk0.qcow2,format=qcow2,size=10,device=disk,bus=virtio,cache=none \
	--cdrom "/var/lib/libvirt/images/live-image-amd64.hybrid.iso" \
	--memory 4096 --vcpu 2

	virsh destroy dlc-test
	virsh undefine dlc-test
	
	rm -f /var/lib/libvirt/images/dlc-test-disk0.qcow2

test_kvm_uefi:

	# Run the resulting image in KVM/virt-manager (UEFI mode)
	# UEFI support must be enabled in QEMU config for EFI install tests https://wiki.archlinux.org/index.php/Libvirt#UEFI_Support (/usr/share/OVMF/*.fd)

	virsh net-start default 2>/dev/null || echo "Skip" 
	
	virsh destroy dlc-test 2>/dev/null || echo "Skip" 
	virsh undefine dlc-test 2>/dev/null || echo "Skip"

	virt-install \
	--name dlc-test \
	--boot hd,loader=/usr/share/OVMF/OVMF_CODE.fd \
	--network=default \
	--video virtio \
	--disk path=/var/lib/libvirt/images/dlc-test-disk0.qcow2,format=qcow2,size=10,device=disk,bus=virtio,cache=none \
	--cdrom "/var/lib/libvirt/images/live-image-amd64.hybrid.iso" \
	--memory 4096 --vcpu 2

	virsh destroy dlc-test
	virsh undefine dlc-test

	rm -f /var/lib/libvirt/images/dlc-test-disk0.qcow2
