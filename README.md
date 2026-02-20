# Achterhus NAS Tools

This is a script collection for NAS-related utilities running on the `achterhus` TinyPC.

## Prerequisites

The service files for `systemd` defined in the `services` directory make use of a configuration file (defined in the parameter `EnvironmentFile`) that defines the scripts folder (`SCRIPTS_DIR`).

Make sure the configuration file exists and is accessible.

See also the `achterhus-nas-tools.config.example` in the `config` folder.
