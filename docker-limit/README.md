# Automating Docker Resource Management

## Problem

Containers without resource limits can consume system memory and CPU without restriction, causing host-level performance issues.

## Goal

Provide a quick CLI tool for setting, monitoring, and resetting CPU/memory limits on Docker containers interactively.

---

## Solution – Bash Menu Script

### Features:
- Limit CPU usage by core
- Limit memory and swap
- Monitor resource usage live (`docker stats`)
- Reset all limitations

---

## Usage

1. Save as `docker-limit.sh`
2. Make executable:

```bash
chmod +x docker-limit.sh
```

3. Run the script:

```bash
./docker-limit.sh
```

---

## Notes & Improvements

> * Script assumes Docker is already installed and the user has appropriate permissions.
> * Future improvements:
>
>   * Add CPU quota limits (`--cpu-quota`, `--cpu-period`)
>   * Include container auto-complete
>   * Add logging feature for changes

---

## Author

Made by immanuelbint for fun, learning, and Linux scripting practice.

---

## License

MIT License — see [LICENSE](../LICENSE) for details.

---

