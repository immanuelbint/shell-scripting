# Automating `kinit` Using Shell Script

A Bash script to automatically renew Kerberos tickets using `kinit`. Designed for use in cron jobs or systemd timers to ensure continuous access to Kerberized services (e.g., Hadoop, Hive, Kafka).

---

## Problem

In Kerberized environments, authenticating as a specific Hadoop service user requires running `kinit` with the corresponding keytab. Doing this repeatedly for different services manually is time-consuming and error-prone, especially in large-scale systems.

## Goal

To reduce repetition by automating the `kinit` process based on available service keytabs, while still allowing manual override when needed.

---

## Solution – Bash Script for Flexible `kinit`

### Features:
- Auto-detect service name and keytab location from a predefined list.
- Allow manual override for custom services.
- Validate keytab file existence before attempting authentication.
- Print success/failure feedback.

---

## Usage

1. **Make the script executable:**

```bash
chmod +x kinit.sh
```

2. **Run the script:**

```bash
./kinit.sh
```

---

## Notes & Improvements

> This script is part of an ongoing learning project and may not fully reflect best practices. Future improvements include:
>
> * Adding support for JSON-based config files.
> * Full automation using arguments (e.g. `--service=hdfs`).
> * Improved error handling and logging.
> * Secure credential handling via environment variables or vault integration.
>
> I'm actively improving this script toward production-ready standards.

## Author

Made by immanuelbint for fun, learning, and Linux scripting practice.

---

## License

MIT License — see [LICENSE](../LICENSE) for details.

---

