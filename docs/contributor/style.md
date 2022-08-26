# Style

## Bash coding style

### Naming conventions

- Local variables **must** have a lowercase `snake_case` name.
- public variables **must** have an uppercase `snake_case` name and starts with `ELI_` if accessible from `eli` CLI.
- functions **must** have a lowercase `snake_case` name.
- private functions **must** contains a `_` prefix.
- executable scripts **must** contains a shebang using `/usr/bin/env` and have executable bits sets accordingly.
- files **must** have a `kebab-case` name.
- files, variables, functions must have explicit name.

### Script structure

Every bash script/lib **must** respect the following file structure:

- `source` and variables of sourced libraries.
- bash options:
  - `set -euo pipefail`
  - `shopt -s inherit_errexit`
  - a comment explaining why the above are missing or why other options are added
- script public variables
- public variables validation
- functions
- body of the script

> **NOTE**: Scripts **must** be commented unless code is already explicit.

### Good practices

- variables **must** almost always be double quoted.
- only source `lib/` files
