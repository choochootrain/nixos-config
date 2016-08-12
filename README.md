#nixos-config

My NixOS configuration. I have no idea what I'm doing and now you can _reproducibly_ feel the same way.

###Setup
```bash
git clone git@github.com:NixOS/nixpkgs.git /etx/nixos/nixpkgs
git clone git@github.com:choochootrain/nixos-config.git /etc/nixos/config
export NIX_PATH=/etc/nixos:nixos-config=/etc/nixos/config
sudo nixos-rebuild switch
```

Then create a `default.nix` and import the modules you want. For example:
```
{ config, pkgs, ... }:

{
    imports = [
        ./machines/thinkpad.nix
        ./common.nix
    ];
}
```
