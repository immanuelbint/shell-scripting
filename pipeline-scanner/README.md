# pipeline-scanner

A lightweight **Bash-based scanner** for detecting hardcoded credentials 
(secrets, tokens, passwords) inside pipeline configuration files (YAML, Jenkinsfile, etc).

> Useful for DevOps, SREs, or SysAdmins who want a quick way to audit pipelines 
> and avoid leaking sensitive information.


---

## Features

- Scans `.yml`, `.yaml`, and `Jenkinsfile` by default
- Detects keywords like `aws_`, `slack_`, `github_`, `token`, `password`, `secret`
- Logs progress with clear output (`INFO` / `WARN` / `ERROR`)
- Fails gracefully with meaningful error messages
- Works with any target directory (default: current workdir)


---

## Usage

```bash
# Scan current directory
bash pipeline-scanner.sh 

# Scan a specific directory or file
bash pipeline-scanner.sh /path/to/project
````

### Example:

```bash
$ bash pipeline-scanner.sh /data/l2bot
Starting the scanner ...
INFO: Scanning directory /data/l2bot/
INFO: Found 1 file(s) to be scanned.
INFO: Scanning file /data/l2bot/docker-compose.yml
INFO: File /data/l2bot/docker-compose.yml is clean
INFO: Scan finished.
INFO: 1 file(s) clean.
WARN: 0 file(s) with issues.

```

---

## Requirements

* Rocky Linux, AlmaLinux, RHEL, CentOS
* Root/sudo access (if the target directory requires elevated permissions)

---

## What It Does

1. Automatically detects current path if not specified
2. Outputs success or error messages

---

## Future Improvements

- Add option for custom keyword patterns
- Export scan results to JSON/CSV for CI integration
- Add Git pre-commit hook support
- Colorized output (green/red logs)


---

## Author

Made by immanuelbint for learning, and Linux scripting practice.

---

## License

MIT License — see [LICENSE](../LICENSE) for details.

---
