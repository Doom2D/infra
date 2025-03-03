# About
This is a Nix flake for managing Doom2D related deployments.

# Instructions
## dirtcheap-usa

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
