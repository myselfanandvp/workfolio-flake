Workfolio Nix Flake

A clean, reproducible Nix Flake for packaging and running the official Workfolio .deb release on NixOS.

This flake handles runtime dependency resolution and dynamic linking using autoPatchelfHook, providing the libraries required by Workfolio's Electron/Chromium runtime, including GTK, audio, graphics, and other system dependencies.

Features
Nix Flake support — Integrates with modern Nix workflows.
Reproducible packaging — Builds Workfolio using Nix.
Automatic runtime patching — Uses autoPatchelfHook to patch ELF binaries.
Electron/Chromium compatibility — Includes the required runtime libraries.
Flexible installation — Supports temporary execution, system-wide installation, and Home Manager.
No manual dependency setup — Runtime dependencies are declared through the Nix package.
Prerequisites

Before getting started, ensure you have:

Nix installed with Flakes enabled.
A NixOS system or a compatible Nix environment.
Git available if you want to manage the flake through your own configuration repository.

For more information, see the Nix Flakes documentation.

Quick Start
Run Workfolio without installing it

You can launch Workfolio directly from GitHub without adding it to your system profile:

bash
nix run github:myselfanandvp/workfolio-flake

This is the quickest way to try the package.

Installation

Choose the installation method that best fits your setup.

Option 1: Install system-wide on NixOS

1. Add the flake input

In your system's flake configuration (flake.nix), add Workfolio as an input:

nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    workfolio = {
      url = "github:myselfanandvp/workfolio-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, workfolio, ... }@inputs: {
    # Your existing system and other outputs.
  };
}

Keep your existing outputs configuration and merge the workfolio input into it rather than replacing your current configuration.

1. Add Workfolio to your system packages

In your NixOS configuration, typically configuration.nix, add:

nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.workfolio.packages.${pkgs.system}.default
  ];
}

Make sure your NixOS configuration has access to the inputs attribute. If your system configuration is imported from flake.nix, pass inputs through specialArgs or use your existing input-passing mechanism.

1. Apply the configuration

From the directory containing your system flake, run:

bash
sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME

Replace YOUR_HOSTNAME with the hostname of your NixOS configuration.

After the rebuild completes, Workfolio should be available to launch from your desktop environment or application launcher, assuming the package provides the appropriate desktop entry.

Option 2: Install using Home Manager

If you manage your user environment with Home Manager, you can install Workfolio without adding it to environment.systemPackages.

1. Add the flake input

Add the same workfolio input to your existing flake.nix:

nix
workfolio = {
  url = "github:myselfanandvp/workfolio-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};

Ensure that inputs.workfolio is accessible to your Home Manager configuration.

1. Add Workfolio to your Home Manager packages

In your Home Manager configuration, add:

nix
{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.workfolio.packages.${pkgs.system}.default
  ];
}

If your Home Manager module does not currently receive inputs, pass them through your existing module configuration.

1. Apply the configuration

For standalone Home Manager, run:

bash
home-manager switch --flake .#YOUR_USERNAME

Replace YOUR_USERNAME with the appropriate Home Manager flake configuration name.

If you use Home Manager as a NixOS module, rebuild your NixOS configuration instead:

bash
sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME

Usage

Once installed, you can launch Workfolio using your desktop application's launcher if the package provides a desktop entry.

You can also run the package directly using Nix:

bash
nix run github:myselfanandvp/workfolio-flake

Updating Workfolio

To update the flake's locked dependencies and package inputs, run the following command from your configuration repository:

bash
nix flake update

Then apply the updated configuration using the appropriate NixOS or Home Manager command.

Note: Updating the flake inputs does not necessarily fetch a newer Workfolio release unless the package definition is configured to track that release.

Troubleshooting
Missing shared libraries

The package uses autoPatchelfHook to patch ELF binaries and resolve shared-library dependencies. If Workfolio fails to launch because a library is missing, verify that the required dependency is declared in the package definition.

Flake input or package not found

Confirm that:

The workfolio input is declared in flake.nix.
The inputs attribute is passed to the relevant NixOS or Home Manager module.
The package output packages.${pkgs.system}.default exists for your system architecture.
Desktop entry not appearing

Try launching Workfolio using the quick-start command. If it runs successfully but does not appear in your application launcher, check whether the package installs a valid desktop entry and application icon.

Contributing

Contributions, bug reports, and improvements are welcome. If you encounter an issue, please open an issue in the repository with the relevant error output and steps to reproduce it.

License

Refer to the repository's license file for the licensing terms of this flake. Workfolio itself may be distributed under separate terms defined by its original publisher.

Acknowledgements
Nix — Declarative package management and reproducible builds.
NixOS — The Linux distribution and configuration ecosystem.
Nixpkgs — Package infrastructure and build tooling.
autoPatchelfHook — Automatic ELF runtime dependency patching.

Workfolio Nix Flake — A straightforward way to run Workfolio on NixOS.
