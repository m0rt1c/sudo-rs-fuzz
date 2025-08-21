{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix.nixPath = [ "nixpkgs=${builtins.storePath <nixpkgs>}" ];

  environment = {
    systemPackages = with pkgs; [
      cargo
      gnumake
      rustup
      rustc
      gcc
      git
      tmux
      sudo-rs
      vim
      openssl
      pam
      pkg-config
    ];
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
    # First, always allow 'test' user
    auth    [success=1 default=ignore] pam_succeed_if.so user = test
    auth    sufficient    pam_permit.so

    # Then include normal login auth
    auth      include login
    account   include login
    password  include login
    session   include login
  '';

  environment.etc."nixos/configuration.nix".source = ./configuration.nix;
  environment.etc."pam.d/sudo".source = "/etc/pam.d/sudo-rs";
  environment.etc."sudoers".text = ''
    #includedir /root/
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
    users.root = {
      password = "root";
    };

  };

  # sudo-rs searches zoneinfo in some paths but not in /etc/zoneinfo
  # but nixos has it only in /etc/zoneinfo and /etc/staic/zoneinfo
  # so we add a symlink
  systemd.tmpfiles.rules = [ "L+ /usr/share/zoneinfo - - - - /etc/zoneinfo" ];

  services.getty.autologinUser = "test";

  virtualisation.diskSize = 5 * 1024; # 5 Gb, this number is in megabytes
}
