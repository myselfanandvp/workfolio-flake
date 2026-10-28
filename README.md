# Workfolio Nix Flake

Run **Workfolio** on NixOS (or any Linux with Nix) with a single command.

Workfolio is shipped by its makers as a `.deb` file, which NixOS can't use directly. This flake unpacks it and fixes it so it works on Nix.

> This package only works on **64-bit Linux** (`x86_64-linux`).

---

## What you need first

1. A computer running **NixOS**, or Linux with **Nix** installed.
2. **Flakes turned on.** If you're not sure, add this line to `~/.config/nix/nix.conf` (create the file if it doesn't exist):

   ```
   experimental-features = nix-command flakes
   ```

---

## Option 1: Just try it (easiest)

Open a terminal and paste:

```bash
nix run github:myselfanandvp/workfolio-flake
```

Workfolio will download and open. Nothing is installed permanently, so it's a great way to test.

---

## Option 2: Install it on NixOS

Think of it as three small steps: **add it, use it, apply it.**

### Step 1: Add Workfolio to your `flake.nix`

Find the `inputs` part of your system's `flake.nix` and add the `workfolio` lines:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  workfolio = {
    url = "github:myselfanandvp/workfolio-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Then make sure `inputs` is passed to your configuration, using `specialArgs`:

```nix
outputs = { self, nixpkgs, workfolio, ... }@inputs: {
  nixosConfigurations.YOUR_HOSTNAME = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };   # <-- this line is important
    modules = [ ./configuration.nix ];
  };
};
```

### Step 2: Add the package to `configuration.nix`

```nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = [
    inputs.workfolio.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

### Step 3: Apply your changes

```bash
sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME
```

Replace `YOUR_HOSTNAME` with your computer's name in your NixOS config.

When it finishes, open Workfolio from your app launcher, or type `workfolio` in a terminal.

---

## Option 3: Install with Home Manager

Use this if you manage your own user settings with Home Manager.

### Step 1: Add the input

Add the same `workfolio` input shown in Option 2, Step 1, to your `flake.nix`.

### Step 2: Add the package

In your Home Manager config:

```nix
{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.workfolio.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

Make sure `inputs` is passed to Home Manager too. If you use Home Manager as part of NixOS, add `extraSpecialArgs = { inherit inputs; };`.

### Step 3: Apply

Standalone Home Manager:

```bash
home-manager switch --flake .#YOUR_USERNAME
```

Home Manager inside NixOS:

```bash
sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME
```

---

## Updating

```bash
nix flake update workfolio
```

Then run your `switch` command again (the one from Option 2 or 3).

> **Note:** This only updates the flake. You get a newer Workfolio version only when the flake's author changes the download link and hash in `flake.nix`.

---

## Something went wrong?

**"error: experimental Nix feature 'flakes' is disabled"**
Flakes aren't turned on. See *What you need first* above.

**"attribute 'default' missing" or "package not found"**
Check that:
- the `workfolio` input is in your `flake.nix`,
- `inputs` is passed through `specialArgs` (or `extraSpecialArgs` for Home Manager),
- you're on 64-bit Linux (`x86_64-linux`).

**It installed but won't open**
Run it from a terminal to see the real error message:

```bash
workfolio
```

- If it says a library (`.so` file) is missing, open an issue and paste the message.
- If it mentions a *sandbox* error, open an issue too. It can usually be fixed in the flake.

**It's not in my app launcher**
Log out and back in, or run `workfolio` from a terminal. If it opens there but not in the launcher, the package may be missing a desktop entry. Please open an issue.

---

## Contributing

Found a bug or have an idea? Please [open an issue](https://github.com/myselfanandvp/workfolio-flake/issues) and include the error message and what you did before it happened.

## License

See the `LICENSE` file in this repository for the flake itself. Workfolio is made by its own publisher and has its own license terms.

## Thanks to

- [Nix](https://nixos.org/) and [NixOS](https://nixos.org/)
- [Nixpkgs](https://github.com/NixOS/nixpkgs)
- `autoPatchelfHook`, which makes the `.deb` work on Nix
