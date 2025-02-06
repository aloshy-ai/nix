{ pkgs, ...}: {
  # Apps installed for all users, in every system.
  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
