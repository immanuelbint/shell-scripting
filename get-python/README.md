# get-python

A simple Bash script to download, compile, and install a specific version of Python from source on Linux systems (e.g. Rocky, CentOS, AlmaLinux, RHEL).

> Ideal for developers or sysadmins who need to manage multiple Python versions without affecting the system default.

---

## Features

- Download official Python tarballs from [python.org](https://www.python.org/ftp/python)
- Automatically install system dependencies (on supported RPM-based systems)
- Compile with `--enable-optimizations` for better performance
- Logs progress with clean, readable output
- Error handling with helpful messages

---

## 🚀 Usage

```bash
bash getpython.sh --version <python_version>
````

### Example:

```bash
bash getpython.sh --version 3.11.0
```

---

## Requirements

* Rocky Linux, AlmaLinux, RHEL, CentOS
* `dnf` or `yum` as package manager
* Root/sudo access (to install dependencies)

---

## What It Does

1. Detects supported Linux distribution
2. Installs required development packages
3. Downloads the specified Python version
4. Compiles and installs it using `make altinstall`
5. Outputs success or error messages

---

## Install Path

By default, all operations happen inside:

```
/tmp/getpython
```

You can edit the `DEFAULT_INSTALL_PATH` variable inside the script to change this.

---

## Installed Dependencies

The script installs the following packages (if missing):

* gcc
* make
* curl
* tar
* wget
* zlib-devel
* openssl-devel
* bzip2-devel
* libffi-devel
* readline-devel
* xz-devel
* sqlite-devel

These are required to properly compile and run Python from source.

---

## Future Improvements

* Add `--prefix` option for custom install locations
* Add `--force` flag to re-download or overwrite
* Add support for Debian/Ubuntu (`apt`)
* Add checksum verification for downloads

---

## Author

Made by immanuelbint for fun, learning, and Linux scripting practice.

---

## License

MIT License — see [LICENSE](../LICENSE) for details.

---
