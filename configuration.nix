{ config, pkgs, lib, ... }: {
  nix.nixPath = [ "nixpkgs=${builtins.storePath <nixpkgs>}" ];

  environment = {
    systemPackages = with pkgs; [ cargo rustup rustc git tmux sudo-rs vim openssl ];
  };

  security.sudo.enable = false;
  security.wrappers.sudo = {
    source = "${pkgs.sudo-rs}/bin/sudo";
    owner = "root";
    group = "root";
    permissions = "u+rs,g+x,o+x";
  };
  security.wrappers.su = lib.mkForce {
    source = "${pkgs.sudo-rs}/bin/su";
    owner = "root";
    group = "root";
    permissions = "u+rs,g+x,o+x";
  };

  security.pam.services.sudo-rs.text = ''
    auth      include login
    account   include login
    password  include login
    session   include login
  '';

  environment.etc."nixos/configuration.nix".source = ./configuration.nix;
  environment.etc."pam.d/sudo".source = "/etc/pam.d/sudo-rs";
  environment.etc."sudoers".text = ''
    #include /etc/sudoers
    root      ALL=(ALL:ALL) ALL
    %wheel    ALL=(ALL:ALL) ALL
  '';

  system.stateVersion = "25.05";

  users = {
    users."test" = {
      home = "/home/test";
      password = "test";
      isNormalUser = true;
    };
    users.root = { password = "root"; };

  };

  services.getty.autologinUser = "test";

  virtualisation.diskSize = 2 * 1024; # 2 Gb, this number is in megabytes 
}

