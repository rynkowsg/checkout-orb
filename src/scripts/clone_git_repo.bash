#!/bin/bash

###
# Clones git repository.
#
# Example with defaults:
#
#   ./src/scripts/clone_repo.bash
#
# Example with params specified:
#
#  ./src/scripts/clone_repo.bash
#
###

# Bash Strict Mode Settings
set -euo pipefail
# Path Initialization
if [ -z "${SHELL_GR_DIR:-}" ]; then
  SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  SCRIPT_PATH="$([[ ! "${SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${SCRIPT_PATH_1}" || echo "")"
  SCRIPT_DIR="$([ -n "${SCRIPT_PATH}" ] && (cd "$(dirname "${SCRIPT_PATH}")" && pwd -P) || echo "")"
  ROOT_DIR="$([ -n "${SCRIPT_DIR}" ] && (cd "${SCRIPT_DIR}/../.." && pwd -P) || echo "/tmp")"
  SHELL_GR_DIR="${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@5a6105b"
fi
# Library Sourcing
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/color.bash
source "${SHELL_GR_DIR}/lib/color.bash"
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/circleci.bash
source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/git_checkout_advanced.bash
source "${SHELL_GR_DIR}/lib/git_checkout_advanced.bash" # git_checkout_advanced
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/git_lfs.bash
source "${SHELL_GR_DIR}/lib/git_lfs.bash" # setup_git_lfs
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/github.bash
source "${SHELL_GR_DIR}/lib/github.bash" # github_authorized_repo_url
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/ssh.bash
source "${SHELL_GR_DIR}/lib/ssh.bash" # setup_ssh

#################################################
#                    INPUTS                     #
#################################################

# All parameters to the script comes from environment variables.
# vars that can be provided:
# - by user in orb params
# - by user in environment vars by previous steps
# - by CircleCI in their environment vars
##
# The params we expect that could be provided by CircleCI are:
# - CHECKOUT_KEY - private key
# - CHECKOUT_KEY_PUBLIC - public key
# - CIRCLE_BRANCH - branch specified by CircleCI
# - CIRCLE_REPOSITORY_URL
# - CIRCLE_SHA1 - SHA specified by CircleCI
# - CIRCLE_TAG - tag specified by CircleCI
# - CIRCLE_WORKING_DIRECTORY - working directory
#
# Rest is provided either from orb params, or via user defined
# environment parameters in previous steps.
#
# All params from orb are prefixed with PARAM_.
#
# When assigning final value, we prioritise orb params,
# then env variables, and at the end CircleCI-specific variables.
#
# To see the exact list of expected env variables, read content of init_input_vars_* functions.

init_input_vars_debug() {
  DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
  DEBUG_GIT=${DEBUG_GIT:-0}
  DEBUG_SSH=${DEBUG_SSH:-0}
  printf "${GREEN}%s${NC}\n" "Debug variables:"
  printf "%s\n" "- DEBUG=${DEBUG}"
  printf "%s\n" "- DEBUG_GIT=${DEBUG_GIT}"
  printf "%s\n" "- DEBUG_SSH=${DEBUG_SSH}"
  printf "%s\n" ""

  if [ "${DEBUG}" = 1 ]; then
    set -x
    printenv | sort
    printf "%s\n" ""
  fi
  if [ "${DEBUG_SSH}" = 1 ]; then
    ssh-add -l
    ssh-add -L
    printf "%s\n" ""
  fi
  if [ "${DEBUG_GIT}" = 1 ]; then
    export GIT_TRACE=1
    export GIT_CURL_VERBOSE=1
  fi
}

init_input_vars_ssh() {
  CHECKOUT_KEY="${CHECKOUT_KEY:-}"
  CHECKOUT_KEY_PUBLIC="${CHECKOUT_KEY_PUBLIC:-}"
  SSH_CONFIG_DIR="${SSH_CONFIG_DIR:-}"
  SSH_PRIVATE_KEY_B64="${SSH_PRIVATE_KEY_B64:-}"
  SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-}"
  SSH_PUBLIC_KEY_B64="${SSH_PUBLIC_KEY_B64:-}"
  SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-}"

  #SSH_PRIVATE_KEY_B64 - SSH private key encoded in Base64 (optional), provided by context
  #SSH_PUBLIC_KEY_B64 - SSH public key encoded in Base64 (optional), provided by context

  printf "${GREEN}%s${NC}\n" "SSH variables:"
  printf "%s\n" "- CHECKOUT_KEY=${CHECKOUT_KEY}"
  printf "%s\n" "- CHECKOUT_KEY_PUBLIC=${CHECKOUT_KEY_PUBLIC}"
  printf "%s\n" "- SSH_CONFIG_DIR=${SSH_CONFIG_DIR}"
  printf "%s\n" "- SSH_PRIVATE_KEY_B64=${SSH_PRIVATE_KEY_B64}"
  printf "%s\n" "- SSH_PRIVATE_KEY_PATH=${SSH_PRIVATE_KEY_PATH}"
  printf "%s\n" "- SSH_PUBLIC_KEY_B64=${SSH_PUBLIC_KEY_B64}"
  printf "%s\n" "- SSH_PUBLIC_KEY_PATH=${SSH_PUBLIC_KEY_PATH}"
  printf "%s\n" ""
}

init_input_vars_checkout() {
  # repo coordinates, if not specified takes coordinates from CircleCI variables
  REPO_URL=${PARAM_REPO_URL:-${REPO_URL:-${CIRCLE_REPOSITORY_URL:-}}}
  # If run from CircleCI, variables CIRCLE_REPOSITORY_URL and CIRCLE_SHA1 is
  # always provided, while CIRCLE_TAG and CIRCLE_BRANCH are depend on whether
  # the build is triggered by a tag or a branch, respectively..

  if [ "${REPO_URL}" == "${CIRCLE_REPOSITORY_URL}" ]; then
    # if REPO_URL & CIRCLE_REPOSITORY_URL are same, we clone the repo triggering the CI.
    REPO_BRANCH=${PARAM_REPO_BRANCH:-${REPO_BRANCH:-${CIRCLE_BRANCH:-}}}
    REPO_TAG=${PARAM_REPO_TAG:-${REPO_TAG:-${CIRCLE_TAG:-}}}
    REPO_SHA1=${PARAM_REPO_SHA1:-${REPO_SHA1:-${CIRCLE_SHA1:-}}}
  else
    # otherwise we clone other repo then the repo triggering the CI.
    # In such case repo coordinates should be given.
    REPO_BRANCH=${PARAM_REPO_BRANCH:-${REPO_BRANCH:-}}
    REPO_TAG=${PARAM_REPO_TAG:-${REPO_TAG:-}}
    REPO_SHA1=${PARAM_REPO_SHA1:-${REPO_SHA1:-}}
    # Example: If we used CIRCLE_ env as defaults here, we could end up with situation that
    # CI repo is triggered by TAG. In the workflow it clones other repo by branch,
    # but since CIRCLE_TAG exists, it will try to clone tag that doesn't exist.
  fi

  DEPTH=${PARAM_DEPTH:--1}
  SUBMODULES_DEPTH=${PARAM_SUBMODULES_DEPTH:--1}

  # DEST_DIR - destination for repo
  #     If not provided in orb param, try DEST_DIR env var.
  #     If DEST_DIR not available, try CIRCLE_WORKING_DIRECTORY.
  #     If also this one missing, try current directory.
  DEST_DIR=${PARAM_DEST_DIR:-${DEST_DIR:-${CIRCLE_WORKING_DIRECTORY:-.}}}
  # eval to resolve ~ in the path
  eval DEST_DIR="${DEST_DIR}"

  # GITHUB_TOKEN - from env vars, e.g. from context or project env vars
  # GITHUB_TOKEN_PARAM - from orb command params
  # prefer the latter, if not available, try to take the former
  GITHUB_TOKEN=${PARAM_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}

  # SUBMODULES_ENABLED - submodules support, if not specified, set to false
  SUBMODULES_ENABLED=${PARAM_SUBMODULES_ENABLED:-${SUBMODULES_ENABLED:-0}}

  # LFS_ENABLED - Git LFS support, if not specified, set to false
  LFS_ENABLED=${PARAM_LFS_ENABLED:-${LFS_ENABLED:-0}}

  printf "${GREEN}%s${NC}\n" "Checkout vars:"
  printf "%s\n" "- DEPTH=${DEPTH:-}"
  printf "%s\n" "- DEST_DIR=${DEST_DIR:-}"
  printf "%s\n" "- GITHUB_TOKEN=${GITHUB_TOKEN:-}"
  printf "%s\n" "- LFS_ENABLED=${LFS_ENABLED:-}"
  printf "%s\n" "- REPO_BRANCH=${REPO_BRANCH:-}"
  printf "%s\n" "- REPO_SHA1=${REPO_SHA1:-}"
  printf "%s\n" "- REPO_TAG=${REPO_TAG:-}"
  printf "%s\n" "- REPO_URL=${REPO_URL:-}"
  printf "%s\n" "- SUBMODULES_DEPTH=${SUBMODULES_DEPTH:-}"
  printf "%s\n" "- SUBMODULES_ENABLED=${SUBMODULES_ENABLED:-}"
  printf "%s\n" ""

  if [ -z "${REPO_BRANCH}" ] && [ -z "${REPO_TAG}" ]; then
    printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository: either REPO_BRANCH or REPO_TAG is required."
    exit 1
  fi
  if [ -z "${REPO_SHA1}" ]; then
    printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository: REPO_SHA1 is always required."
    exit 1
  fi
}

#################################################
#                     MAIN                      #
#################################################

main() {
  fix_home_in_old_images

  print_common_debug_info "$@"
  init_input_vars_debug
  init_input_vars_ssh
  init_input_vars_checkout

  setup_git_lfs "${LFS_ENABLED}"

  GR_SSH__CHECKOUT_KEY="${CHECKOUT_KEY:-}" \
    GR_SSH__CHECKOUT_KEY_PUBLIC="${CHECKOUT_KEY_PUBLIC:-}" \
    GR_SSH__DEBUG_SSH="${DEBUG_SSH:-}" \
    GR_SSH__SSH_CONFIG_DIR="${SSH_CONFIG_DIR:-}" \
    GR_SSH__SSH_PRIVATE_KEY_B64="${SSH_PRIVATE_KEY_B64:-}" \
    GR_SSH__SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-}" \
    GR_SSH__SSH_PUBLIC_KEY_B64="${SSH_PUBLIC_KEY_B64:-}" \
    GR_SSH__SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-}" \
    setup_ssh

  GR_GITCO__DEBUG="${DEBUG:-}" \
    GR_GITCO__DEBUG_GIT="${DEBUG_GIT:-}" \
    GR_GITCO__DEPTH="${DEPTH:-}" \
    GR_GITCO__DEST_DIR="${DEST_DIR:-}" \
    GR_GITCO__LFS_ENABLED="${LFS_ENABLED:-}" \
    GR_GITCO__REPO_BRANCH="${REPO_BRANCH:-}" \
    GR_GITCO__REPO_SHA1="${REPO_SHA1:-}" \
    GR_GITCO__REPO_TAG="${REPO_TAG:-}" \
    GR_GITCO__REPO_URL="${REPO_URL:-}" \
    GR_GITCO__SUBMODULES_DEPTH="${SUBMODULES_DEPTH:-}" \
    GR_GITCO__SUBMODULES_ENABLED="${SUBMODULES_ENABLED:-}" \
    git_checkout_advanced
}

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ "${CIRCLECI}" == "true" ]]; then
  main "$@"
else
  printf "%s\n" "Loaded: ${BASH_SOURCE[0]:-}"
fi
