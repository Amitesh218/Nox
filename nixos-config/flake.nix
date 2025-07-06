{
  description = "Flake-based NixOS config for Nyx with Home Manager";

  inputs = {
    # Pull in the latest nixpkgs unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager module, used as a NixOS module
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    # Define a NixOS system configuration for hostname "Nyx"
    nixosConfigurations.Nyx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # Your main system config and hardware scan
        ./hosts/nyx/configuration.nix
        # Removed the hardware configuration import cause configuration.nix already has imported it.
        # ./hosts/nyx/hardware-configuration.nix

        # Home Manager as a NixOS module (runs as part of nixos-rebuild)
        home-manager.nixosModules.home-manager

        {
          # Use system's nixpkgs in Home Manager (avoids duplication)
          home-manager.useGlobalPkgs = true;

          # Don't allow Home Manager to install user-specific packages
          home-manager.useUserPackages = false;

          # This defines your Home Manager config for user "S01"
          home-manager.users.S01 = import ./home/S01.nix;

          # Optional: pass extra variables to home.nix
          # home-manager.extraSpecialArgs = { inherit someVar; };
        }
      ];
    };
  };
}
