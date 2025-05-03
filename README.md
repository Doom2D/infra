# About
This is a Nix flake for managing Doom2D related deployments.

# Mini HOWTO
## Update dependencies
```sh
nix flake update
```

## Check that configuration builds
```sh
# or dirtcheap-servers-nsk or dirtcheap-servers-usa
nix build .#nixosConfigurations.servers-msk.config.system.build.toplevel --verbose --show-trace
```

## Apply new configuration to host
```sh
# Make sure server has your SSH public key
# Make sure your SSH private key is in your ssh-agent
nix run github:zhaofengli/colmena#colmena -- apply --on servers-dirtcheap-nsk  --impure
nix run github:zhaofengli/colmena#colmena -- apply --on servers-dirtcheap-usa  --impure
nix run github:zhaofengli/colmena#colmena -- apply --on servers-msk  --impure
```

# Install instructions
## New York (Gullo's)

```sh
# Choose Debian 12 in Gullo's.
# Uncomment inputs.nixos-openvz.nixosModules.ovz-installer and change instance IPs, then
nix build .#nixosConfigurations.servers-dirtcheap-usa.config.system.build.tarball
# SSH into the VPS, make space for tarball
ssh root@IP -p PORT
rm -rf /var/ /usr/lib/x86_64-linux-gnu/{perl,libicudata.so.72.1} /usr/share/perl /usr/share/vim
exit
# Upload the tarball to the VPS, then extract it onto the root filesystem
scp -P PORT result/tarball/nixos-system-x86_64-linux.tar.xz root@IP:/root/
ssh root@IP -p PORT
tar xpf nixos-system-x86_64-linux.tar.xz -C /
# Exit SSH, reboot from the control panel
# Comment ovz-installer back and deploy changes.
nix run github:zhaofengli/colmena#colmena -- apply --on servers-dirtcheap-usa --impure
```

## Novosibirsk (4vps)

```sh
# Change IPs, gateways and interface names accordingly
# Choose Debian 12 in 4vps'
# Run kexec phase of nixos-anywhere
nixos-anywhere --no-substitute-on-destination -L --debug --build-on local --flake .#servers-dirtcheap-nsk --phases kexec root@IP
# SSH into VPS after changing root password from VNC
ssh root@IP
# Create a zram device, make nix store larger, because the defaults are too small for 1 gb of ram
modprobe zram
zramctl /dev/zram0 --algorithm zstd --size 500M
mkswap -U clear /dev/zram0
swapon --discard --priority 100 /dev/zram0
mount -o remount,size=800M /nix/.rw-store
exit
# Proceed with the rest of nixos-anywhere install
nixos-anywhere --no-substitute-on-destination -L --debug --build-on local --flake .#servers-dirtcheap-nsk root@IP
# After installation is finished, reboot from the control panel

# Deploy
nix run github:zhaofengli/colmena#colmena -- apply --on servers-dirtcheap-nsk --impure
```

## Moscow

```ssh
# Choose any image at firstbyte's
# Power down the VM in the vm manager.
# In the iso images, download nixos-minimal.
# Add nixos-minimal iso to VM boot order.
# When nixos booted, configure the network.
systemctl stop dhcpcd
ip a flush dev ens3
ip a add IP/24 dev ens3
ip route add default via GATEWAY dev ens3
# Create a zram device.
modprobe zram
zramctl /dev/zram0 --algorithm zstd --size 500M
mkswap -U clear /dev/zram0
swapon --discard --priority 100 /dev/zram0
# First iteration. This ise expected to fail.
nixos-anywhere --no-substitute-on-destination -L --debug --build-on local --flake .#servers-msk root@IP
# The install will fail due to lack of space.
# SSH into the VPS, and remount the overlay.
mount -o remount,size=800M /nix/.rw-store
# Proceed with the install.
nixos-anywhere --no-substitute-on-destination -L --debug --build-on local --flake .#servers-msk root@IP
# Stop the VPS from control panel when install is finished.
# Remove ISO image from boot order.
# Start the VPS.
```

## Netherlands

Same as 4vps.

## Germany

Same as 4vps.
