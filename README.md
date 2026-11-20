# Linux-gateway

A Shell-first deployment and lifecycle framework for a future multi-egress gateway.

## Supported target matrix

- Debian 11 and Debian 12
- Ubuntu 20.04 and Ubuntu 22.04
- Linux amd64 and arm64
- systemd-based hosts

Compatibility is capability-driven. A supported distribution label does not imply that every optional kernel feature is present. PPP/L2TP and conntrack support are detected independently.

## Design principles

1. `install.sh` is the only interactive entry point.
2. Shell scripts detect, validate, repair prerequisites, install, update, diagnose and remove components.
3. Go binaries implement long-running network/data-plane workloads.
4. No installer may silently replace default routes, flush firewall rules, enable forwarding, change SSH policy, or replace a kernel.
5. Every mutating action must show a plan, request confirmation, create a backup where applicable, validate before applying, and provide a rollback path.
6. Node credentials and runtime secrets must never be committed to Git.
7. The scaffold does not yet install Gateway Core or Probe Client. Those components are deliberately gated until their release artifacts and integration tests exist.

## Quick start

```bash
git clone https://github.com/yonghu996/Linux-gateway.git
cd Linux-gateway
sudo bash install.sh
```

Run a read-only environment check:

```bash
sudo bash install.sh --check
```

Generate a diagnostic report:

```bash
sudo bash install.sh --diagnose
```

## Development validation

```bash
bash ci/validate.sh
```

`shellcheck` is used when available; the validation script does not install packages.

## Current scaffold status

- Interactive menu: implemented.
- OS/architecture detection: implemented for the stated matrix.
- Read-only capability checks: implemented.
- Diagnostic report: implemented.
- Repair/install/update/rollback/uninstall: guarded scaffolds; production mutations are not enabled yet.
- Gateway Core and Probe Client: not included in this scaffold release.

## Security

Do not expose management APIs or probe endpoints to the public Internet by default. Runtime secrets belong under `/etc/linux-gateway/` with restrictive permissions, never in the repository. Firewall and routing changes must be explicit and reversible.

## Publishing

The repository is `https://github.com/yonghu996/Linux-gateway`. The Windows helper `windows/publish-to-github.ps1` verifies the expected origin and pushes to the existing `main` branch. It does not create a repository or change its visibility.
