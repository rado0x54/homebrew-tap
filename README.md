# homebrew-tap

Homebrew tap for [rado0x54](https://github.com/rado0x54) projects.

## Install

```bash
brew install rado0x54/tap/shellwatch-agent
brew install rado0x54/tap/minisatip
```

(Brew auto-derives the tap URL from the `homebrew-` prefix on the repo name; no separate `brew tap` step required.)

## What's here

| Formula | Description |
| --- | --- |
| `shellwatch-agent` | Thin SSH agent proxy that lets system SSH clients (`ssh`, `scp`, `git`) use [ShellWatch](https://github.com/rado0x54/ShellWatch)-managed keys, including WebAuthn-backed passkeys. |
| `minisatip` | SAT>IP server fork ([rado0x54/minisatip](https://github.com/rado0x54/minisatip)) with HDHomeRun tuner emulation, userspace DVB drivers via libusb, and macOS support. |

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

## minisatip

The release binary statically links libdvbcsa, libsrt, libhdhomerun, and OpenSSL — only system libs are dynamic, so no extra Homebrew dependencies are needed.

```bash
# Web UI lives under share/minisatip/; firmware blobs go under var/.
# Service block bakes in -R and FIRMWARE_DIR, so brew services just works:
brew services start minisatip

# Or run directly:
FIRMWARE_DIR="$(brew --prefix)/var/lib/minisatip/firmware" \
  minisatip -R "$(brew --prefix minisatip)/share/minisatip/html"
```

For userspace DVB hardware, drop firmware blobs into `$(brew --prefix)/var/lib/minisatip/firmware` — this path survives `brew upgrade`. See `$(brew --prefix minisatip)/share/doc/minisatip/firmware-README.txt` for blob sources.

## Updates

Each new ShellWatch agent release (`agent/v*` tags on the main repo) auto-bumps `shellwatch-agent` here via a workflow in the upstream repo. `minisatip` is currently bumped by hand on each `v*` tag of [rado0x54/minisatip](https://github.com/rado0x54/minisatip). To upgrade:

```bash
brew update
brew upgrade shellwatch-agent minisatip
```

## Reporting issues

For issues with the formula itself (install fails, sha256 mismatch, etc.), file in this repo. For issues with the underlying tools, file at [rado0x54/ShellWatch](https://github.com/rado0x54/ShellWatch/issues) or [rado0x54/minisatip](https://github.com/rado0x54/minisatip/issues).
