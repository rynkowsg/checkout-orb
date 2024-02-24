#!/usr/bin/env bash

set -uo pipefail

find . -type f \( -name '*.bash' -o -name '*.sh' \) -exec \
  shellcheck \
  --shell=bash \
  --external-sources \
  {} +

find . -type f -name '*.bats' -exec \
  shellcheck \
  --shell=bats \
  --external-sources \
  {} +
