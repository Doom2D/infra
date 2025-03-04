# About
This is a Nix flake for managing Doom2D related deployments.

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
