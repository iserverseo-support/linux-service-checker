# Linux Service Checker

A lightweight Bash utility for checking the status of Linux systemd services.

The tool checks whether services are running, stopped, failed, or unavailable and returns meaningful exit codes for scripting and monitoring.

## Features

- Check multiple systemd services.
- Check default services when no arguments are provided.
- Identify running, stopped, failed, and missing services.
- Validate service names.
- Return meaningful exit codes.
- Produce machine-readable output using pipe-separated values.
- No external dependencies beyond systemd and Bash.

## Requirements

- Linux operating system with systemd.
- Bash 4 or later.
- Permission to query systemd services.

Tested on AlmaLinux 9.

## Project Structure

```text
linux-service-checker/
├── src/
│   └── check-services.sh
├── tests/
├── docs/
└── README.md
