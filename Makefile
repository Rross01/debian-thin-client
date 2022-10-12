#!/usr/bin/make -f

SHELL := /bin/bash

all: install_buildenv build

install_buildenv:
	# Install packages required to build the image
	sudo apt -y install live-build make build-essential wget git unzip colordiff apt-transport-https \
	rename ovmf rsync python3-venv gnupg squashfs-tools gettext po4a debhelper-compat
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

	virsh destroy dlc-test 2>/dev/null || echo "Skip" 
	virsh undefine dlc-test 2>/dev/null || echo "Skip"


	virt-install \
	--name dlc-test \
	--boot hd,cdrom \
	--network bridge=br0 \
	--video virtio \
	--disk path=/var/lib/libvirt/images/dlc-test-disk0.qcow2,format=qcow2,size=20,device=disk,bus=virtio,cache=none \
	--cdrom "/var/lib/libvirt/images/live-image-amd64.hybrid.iso" \
	--memory 4096 --vcpu 2

	virsh destroy dlc-test
	virsh undefine dlc-test
	
	rm -f /var/lib/libvirt/images//dlc-test-disk0.qcow2

test_kvm_uefi:

	# Run the resulting image in KVM/virt-manager (UEFI mode)
	# UEFI support must be enabled in QEMU config for EFI install tests https://wiki.archlinux.org/index.php/Libvirt#UEFI_Support (/usr/share/OVMF/*.fd)

	virsh destroy dlc-test
	virsh undefine dlc-test

	virt-install \
	--name dlc-test \
	--boot hd,loader=/usr/share/OVMF/OVMF_CODE.fd \
	--network bridge=br0 \
	--video virtio \
	--disk path=/var/lib/libvirt/images/dlc-test-disk0.qcow2,format=qcow2,size=20,device=disk,bus=virtio,cache=none \
	--cdrom "/var/lib/libvirt/images/live-image-amd64.hybrid.iso" \
	--memory 4096 --vcpu 2

	virsh destroy dlc-test
	virsh undefine dlc-test

	rm -f /var/lib/libvirt/images//dlc-test-disk0.qcow2