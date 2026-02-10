---
name: agenix
description: "agenix secrets management for this dotfiles repo. Use when adding, editing, removing, or referencing encrypted secrets. Triggers: 'add a secret', 'store API key', 'encrypt', 'age.secrets', 'agenix', '/run/agenix/', any task involving sensitive values (tokens, keys, credentials, passwords)."
---

# agenix Secrets

Secrets are age-encrypted files in `secrets/`, decrypted to `/run/agenix/<name>` on `switch`.

## Adding a Secret

Three files to touch:

### 1. Declare in `secrets/secrets.nix`

```nix
"my-secret.age".publicKeys = all;
```

### 2. Create the encrypted file

```bash
cd ~/.config/nix && agenix -e secrets/my-secret.age
```

Opens `$EDITOR` — type/paste the secret value, save, close. If `agenix` CLI is unavailable, use age directly:

```bash
echo "secret-value" | age -r "$(cat ~/.ssh/id_ed25519.pub)" -o secrets/my-secret.age
```

### 3. Register in `lib/mkHost.nix`

Add to the `age.secrets` block (next to `age.identityPaths`):

```nix
age.secrets.my-secret.file = ../secrets/my-secret.age;
```

Then `git add secrets/my-secret.age` and `switch`.

## Referencing Secrets in Modules

Decrypted secrets live at `/run/agenix/<name>`. Use in modules:

```nix
# As a file path (preferred — apps read the file)
config.age.secrets.my-secret.path

# As an environment variable (reads file content)
environment.variables.MY_KEY = "$(cat /run/agenix/my-secret)";

# In MCP server config
env.API_KEY_FILE = "/run/agenix/my-secret";
```

## Key Files

| File                  | Purpose                                                      |
| --------------------- | ------------------------------------------------------------ |
| `secrets/secrets.nix` | Declares which public keys can decrypt each secret           |
| `secrets/*.age`       | Encrypted secret files (safe to commit)                      |
| `lib/mkHost.nix`      | `age.secrets.<name>.file` declarations + `age.identityPaths` |
| `flake.nix`           | `agenix` flake input                                         |

## Commands

| Action                                            | Command                               |
| ------------------------------------------------- | ------------------------------------- |
| Create/edit secret                                | `agenix -e secrets/name.age`          |
| Re-encrypt all (after adding keys to secrets.nix) | `agenix --rekey`                      |
| Verify decrypted                                  | `cat /run/agenix/name` (after switch) |

## Gotchas

- `git add` new `.age` files before `switch` — flakes ignore untracked files
- Identity key: `~/.ssh/id_ed25519` — must exist on machine to decrypt
- New machine: either transfer the same SSH key, or add new pubkey to `secrets/secrets.nix` and `agenix --rekey`
- Never put secret values in Nix files — always reference paths
