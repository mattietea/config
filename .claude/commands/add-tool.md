# Add Tool to Nix Configuration

Add a new tool/program to the nix dotfiles configuration.

## Tool to add: $ARGUMENTS

## Instructions

1. **Search for home-manager support**
   - Use context7 to search home-manager documentation for `programs.$ARGUMENTS`
   - Check if `programs.<tool>.enable` option exists

2. **Determine tool type**
   - CLI tool -> `modules/home-manager/packages/<tool>/default.nix`
   - GUI application -> `modules/home-manager/applications/<tool>/default.nix`

3. **Check nixpkgs**
   - If no home-manager program support, search nixpkgs for the package name
   - Package might have a different name than the tool (e.g., `nodejs` vs `node`)

4. **Look at existing similar tools for patterns**
   - Check existing configs in `modules/home-manager/packages/` for integration ideas
   - Look for: shell integrations, editor integrations, cross-tool references

5. **Create the configuration**

   If home-manager program support exists:

   ```nix
   { pkgs, ... }:
   {
     programs.<tool> = {
       enable = true;
       enableZshIntegration = true;  # if available
       # Add sensible defaults based on documentation
     };
   }
   ```

   If only nixpkg available:

   ```nix
   { pkgs, ... }:
   {
     home.packages = [ pkgs.<tool> ];
   }
   ```

6. **Ask where to add the tool**
   - Ask the user which host(s) to add the tool to: `personal`, `work`, or `both`
   - Add the import to the appropriate host config(s):
     - `hosts/personal/default.nix`
     - `hosts/work/default.nix`
   - Import path: `../../modules/home-manager/packages/<tool>` or `../../modules/home-manager/applications/<tool>`

## After creating the config

Run `devenv shell -- format` to format the new file.
