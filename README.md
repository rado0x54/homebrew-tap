# homebrew-tap

Homebrew tap for [ShellWatch](https://github.com/rado0x54/ShellWatch) tools.

> **Status: not yet installable.** The `shellwatch-agent` formula is in place and `brew audit`s clean, but the binaries it points at live in a release on the (currently private) upstream `rado0x54/ShellWatch` repo. `brew install` cannot carry GitHub auth, so the URLs 404 anonymously until the upstream goes public. Re-test once that ships.

## Install (once upstream is public)

```bash
brew install rado0x54/tap/shellwatch-agent
```

(Brew auto-derives the tap URL from the `homebrew-` prefix on the repo name; no separate `brew tap` step required.)

## What's here

| Formula | Description |
| --- | --- |
| `shellwatch-agent` | Thin SSH agent proxy that lets system SSH clients (`ssh`, `scp`, `git`) use [ShellWatch](https://github.com/rado0x54/ShellWatch)-managed keys, including WebAuthn-backed passkeys. |

## After install

```bash
# One-time browser-based authorization. Token lands in your OS keyring.
shellwatch-agent login

# Run as a launchd / systemd-user service.
brew services start shellwatch-agent

# Tell your shell where the agent's socket is (~/.zshrc or ~/.bashrc).
eval "$(shellwatch-agent --print-env)"

# Verify.
ssh-add -l
```

For self-hosted ShellWatch instances, pass `--server`:

```bash
shellwatch-agent login --server https://shellwatch.example.com
```

The daemon uses `https://app.shellwatch.ai` by default; override with `--server` or `SHELLWATCH_SERVER` in the service unit.

## Updates

Each new ShellWatch agent release (`agent/v*` tags on the main repo) auto-bumps the formula here via a workflow in the upstream repo. To upgrade:

```bash
brew update
brew upgrade shellwatch-agent
```

## Reporting issues

For issues with the formula itself (install fails, sha256 mismatch, etc.), file in this repo. For issues with the agent itself or the ShellWatch server, file at [rado0x54/ShellWatch](https://github.com/rado0x54/ShellWatch/issues).
