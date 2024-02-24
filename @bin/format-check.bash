#!/usr/bin/env bash

set -uo pipefail

# detect ROOT_DIR - BEGIN
SCRIPT_PATH="$([ -L "$0" ] && readlink "$0" || echo "$0")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" || exit 1; pwd -P)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." || exit 1; pwd -P)"
# detect ROOT_DIR - END

DEBUG=${DEBUG:-0}
APPLY_PATCHES=${APPLY_PATCHES:-1}

if [ "${DEBUG}" = 1 ]; then
  echo "SCRIPT_DIR: ${SCRIPT_DIR}"
  echo "ROOT_DIR: ${ROOT_DIR}"
  echo "APPLY_PATCHES: ${APPLY_PATCHES}"
fi

if [ "${APPLY_PATCHES}" = 1 ]; then
  git apply "${SCRIPT_DIR}/res/pre-format.patch"
fi

find "${ROOT_DIR}" -type f \( -name '*.bash' -o -name '*.sh' \) | while IFS= read -r file; do
  echo "Processing file: $file"
  shfmt --language-dialect bash \
    --indent 2 \
    --case-indent \
    --binary-next-line \
    --diff \
    "${file}"
done

find "${ROOT_DIR}" -type f -name '*.bats' | while IFS= read -r file; do
  echo "Processing file: $file"
  shfmt --language-dialect bats \
    --indent 2 \
    --case-indent \
    --binary-next-line \
    --diff \
    "${file}"
done

if [ "${APPLY_PATCHES}" = 1 ]; then
  git apply "${SCRIPT_DIR}/res/post-format.patch"
fi
