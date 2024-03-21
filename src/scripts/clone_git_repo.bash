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
  SCRIPT_PATH="$([[ ! "${SCRIPT_PATH_1}" =~ ^(/bin/)?(ba)?sh$ ]] && readlink -f "${SCRIPT_PATH_1}" || echo "")"
  SCRIPT_DIR="$([ -n "${SCRIPT_PATH}" ] && (cd "$(dirname "${SCRIPT_PATH}")" && pwd -P) || echo "")"
  ROOT_DIR="$([ -n "${SCRIPT_DIR}" ] && (cd "${SCRIPT_DIR}/../.." && pwd -P) || echo "/tmp")"
  SHELL_GR_DIR="${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@aaef6de"
fi
# Library Sourcing
# shellcheck source=.github_deps/rynkowsg/shell-gr@aaef6de/lib/color.bash
source "${SHELL_GR_DIR}/lib/color.bash"
# shellcheck source=.github_deps/rynkowsg/shell-gr@aaef6de/lib/circleci.bash
source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info
# shellcheck source=.github_deps/rynkowsg/shell-gr@aaef6de/lib/git_lfs.bash
source "${SHELL_GR_DIR}/lib/git_lfs.bash" # setup_git_lfs
# shellcheck source=.github_deps/rynkowsg/shell-gr@aaef6de/lib/github.bash
source "${SHELL_GR_DIR}/lib/github.bash" # github_authorized_repo_url
# shellcheck source=.github_deps/rynkowsg/shell-gr@aaef6de/lib/ssh.bash
source "${SHELL_GR_DIR}/lib/ssh.bash" # setup_ssh

#################################################
#             ENVIRONMENT VARIABLES             #
#################################################

# vars that should be provided by system

# vars that can be provided:
# - by user in orb params
# - by user in environment vars by previous steps
# - by CircleCI in their environment vars
#
# All params from orb are prefixed with PARAM_.
#
# The params we expect to see from CircleCI are:
# - CHECKOUT_KEY - private key
# - CHECKOUT_KEY_PUBLIC - public key
# - CIRCLE_BRANCH - branch specified by CircleCI
# - CIRCLE_REPOSITORY_URL
# - CIRCLE_SHA1 - SHA specified by CircleCI
# - CIRCLE_TAG - tag specified by CircleCI
# - CIRCLE_WORKING_DIRECTORY - working directory
#

# When assigning final value, we prioritise orb params,
# then env variables, and at the end CircleCI-specific variables.

DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
DEBUG_SSH=${DEBUG_SSH:-0}
DEBUG_GIT=${DEBUG_GIT:-0}
if [ "${DEBUG}" = 1 ]; then
  set -x
  printenv | sort
fi
if [ "${DEBUG_SSH}" = 1 ]; then
  ssh-add -l
  ssh-add -L
fi
if [ "${DEBUG_GIT}" = 1 ]; then
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
fi

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

SSH_CONFIG_DIR="${SSH_CONFIG_DIR:-${HOME}/.ssh}"
SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-}"
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-}"

#SSH_PRIVATE_KEY_B64 - SSH private key encoded in Base64 (optional), provided by context
#SSH_PUBLIC_KEY_B64 - SSH public key encoded in Base64 (optional), provided by context

printf "${GREEN}%s${NC}\n" "Environment variables - possible to provide via command params:"
printf "%s\n" "DEBUG=${DEBUG:-}"
printf "%s\n" "DEPTH=${DEPTH:-}"
printf "%s\n" "DEST_DIR=${DEST_DIR:-}"
printf "%s\n" "GITHUB_TOKEN=${GITHUB_TOKEN:-}"
printf "%s\n" "LFS_ENABLED=${LFS_ENABLED:-}"
printf "%s\n" "REPO_BRANCH=${REPO_BRANCH:-}"
printf "%s\n" "REPO_SHA1=${REPO_SHA1:-}"
printf "%s\n" "REPO_TAG=${REPO_TAG:-}"
printf "%s\n" "REPO_URL=${REPO_URL:-}"
printf "%s\n" "SUBMODULES_DEPTH=${SUBMODULES_DEPTH:-}"
printf "%s\n" "SUBMODULES_ENABLED=${SUBMODULES_ENABLED:-}"
printf "%s\n" ""

printf "${GREEN}%s${NC}\n" "Environment variables - rest:"
printf "%s\n" "CHECKOUT_KEY=${CHECKOUT_KEY:-}"
printf "%s\n" "CHECKOUT_KEY_PUBLIC=${CHECKOUT_KEY_PUBLIC:-}"
printf "%s\n" "SSH_CONFIG_DIR=${SSH_CONFIG_DIR:-}"
printf "%s\n" "SSH_PRIVATE_KEY_B64=${SSH_PRIVATE_KEY_B64:-}"
printf "%s\n" "SSH_PRIVATE_KEY_PATH=${SSH_PRIVATE_KEY_PATH:-}"
printf "%s\n" "SSH_PUBLIC_KEY_B64=${SSH_PUBLIC_KEY_B64:-}"
printf "%s\n" "SSH_PUBLIC_KEY_PATH=${SSH_PUBLIC_KEY_PATH:-}"
printf "%s\n" ""

#################################################
#      ENVIRONMENT VARIABLES - VALIDATION       #
#################################################

if [ -z "${REPO_BRANCH}" ] && [ -z "${REPO_TAG}" ]; then
  printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository: either REPO_BRANCH or REPO_TAG is required."
  exit 1
fi
if [ -z "${REPO_SHA1}" ]; then
  printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository: REPO_SHA1 is always required."
  exit 1
fi

#################################################
#                   UTILITIES                   #
#################################################

# $1 - dest
repo_checkout() {
  local -r dest="${1}"
  # To facilitate cloning shallow repo for branch, tag or particular sha,
  # we don't use `git clone`, but combination of `git init` & `git fetch`.
  printf "${GREEN}%s${NC}\n" "Creating clean git repo..."
  printf "%s\n" "- repo_url: ${REPO_URL}"
  printf "%s\n" "- dst: ${dest}"
  printf "%s\n" ""

  # --- check dest directory
  mkdir -p "${dest}"
  if [ "$(ls -A "${dest}")" ]; then
    printf "${YELLOW}%s${NC}\n" "Directory \"${dest}\" is not empty."
    ls -Al "${dest}"
    printf "%s\n" ""
  fi
  # --- init repo
  cd "${dest}"
  # Skip smudge to download binary files later in a faster batch
  [ "${LFS_ENABLED}" = 1 ] && git lfs install --skip-smudge
  # --skip-smudge
  local repo_url
  repo_url="$(github_authorized_repo_url "${REPO_URL}" "${GITHUB_TOKEN}")"
  if [[ "${repo_url}" != "${REPO_URL}" ]]; then
    printf "${GREEN}%s${NC}\n" "Detected GitHub token. Update:"
    printf "%s\n" "- repo_url: ${repo_url}"
  fi
  git init
  git remote add origin "${repo_url}"
  [ "${LFS_ENABLED}" = 1 ] && git lfs install --local --skip-smudge
  if [ "${DEBUG_GIT}" = 1 ]; then
    if [ "${LFS_ENABLED}" = 1 ]; then
      printf "${YELLOW}%s${NC}\n" "[LOGS] git lfs env"
      git lfs env
    fi
    printf "${YELLOW}%s${NC}\n" "[LOGS] git config -l"
    [ -f /etc/gitconfig ] && git config -l --system | sort
    git config -l --global | sort
    git config -l --worktree | sort
    git config -l --local | sort
  fi
  printf "%s\n" ""

  fetch_params=()
  [ "${DEPTH}" -ne -1 ] && fetch_params+=("--depth" "${DEPTH}")
  fetch_params_serialized="$(
    IFS=,
    echo "${fetch_params[*]}"
  )"
  # create fetch_repo_script
  local fetch_repo_script
  fetch_repo_script="$(create_fetch_repo_script)"
  # start checkout
  if [ -n "${REPO_TAG+x}" ] && [ -n "${REPO_TAG}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out tag..."
    git fetch "${fetch_params[@]}" origin "refs/tags/${REPO_TAG}:refs/tags/${REPO_TAG}"
    git -c advice.detachedHead=false checkout --force "${REPO_TAG}"
    git reset --hard "${REPO_SHA1}"
  elif [ -n "${REPO_BRANCH+x}" ] && [ -n "${REPO_BRANCH}" ] && [ -n "${REPO_SHA1+x}" ] && [ -n "${REPO_SHA1}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out branch..."
    bash "${fetch_repo_script}" "${DEBUG}" "${fetch_params_serialized}" "refs/heads/${REPO_BRANCH}:refs/remotes/origin/${REPO_BRANCH}" "${REPO_BRANCH}" "${REPO_SHA1}"
  else
    printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository."
    printf "${RED}%s${NC}\n" "Need to specify REPO_TAG to fetch by tag or REPO_BRANCH and REPO_SHA1 to fetch by branch."
    exit 1
  fi
  submodule_update_params=("--init" "--recursive")
  [ "${SUBMODULES_DEPTH}" -ne -1 ] && submodule_update_params+=("--depth" "${SUBMODULES_DEPTH}")
  [ "${SUBMODULES_ENABLED}" = 1 ] && git submodule update "${submodule_update_params[@]}"
  if [ "${LFS_ENABLED}" = 1 ]; then
    git lfs pull
    if [ "${SUBMODULES_ENABLED}" = 1 ]; then
      local fetch_lfs_in_submodule
      fetch_lfs_in_submodule="$(mktemp -t "checkout-fetch_lfs_in_submodule-$(date +%Y%m%d_%H%M%S)-XXXXX")"
      # todo: add cleanup
      cat <<-EOF >"${fetch_lfs_in_submodule}"
if [ -f .gitattributes ] && grep -q "filter=lfs" .gitattributes; then
  git lfs install --local --skip-smudge
  git lfs pull
else
  echo "Skipping submodule without LFS or .gitattributes"
fi
EOF
      git submodule foreach --recursive "bash \"${fetch_lfs_in_submodule}\""
    fi
  fi
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Summary"
  git --no-pager log --no-color -n 1 --format="HEAD is now at %h %s"
  printf "%s\n" ""
}

create_fetch_repo_script() {
  local fetch_repo_script
  fetch_repo_script="$(mktemp -t "checkout-fetch_repo-$(date +%Y%m%d_%H%M%S)-XXXXX")"
  # todo: add cleanup
  cat <<-'EOF' >"${fetch_repo_script}"
DEBUG=${1:-0}
[ "${DEBUG}" = 1 ] && set -x
FETCH_PARAMS_SERIALIZED="${2}"
REFSPEC="${3}"
BRANCH="${4}"
SHA1="${5}"

GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')

fetch_repo() {
  local fetch_params_serialized="${1}"
  local refspec="${2}"
  local branch="${3}"
  local sha1="${4}"

  IFS=',' read -r -a fetch_params <<< "${fetch_params_serialized}"

  # Find depth in fetch_params
  local depth_specified=0
  local depth=
  for ((i = 0; i < ${#fetch_params[@]}; i++)); do
    if [[ ${fetch_params[i]} == "--depth" ]]; then
      depth_specified=1
      depth=${fetch_params[i+1]}
    fi
  done

  # fetch
  git fetch "${fetch_params[@]}" origin "${refspec}"

  local checkout_error checkout_status
  # Try to checkout
  checkout_error=$(git checkout --force -B "${branch}" "${sha1}" 2>&1)
  checkout_status=$?

  if [ ${checkout_status} -eq 0 ]; then
    message=$([ ${depth_specified} == 0 ] && echo "Full checkout succeeded." || echo "Shallow checkout succeeded.")
    printf "${GREEN}%s${NC}\n" "${message}"
  else
    printf "${RED}%s${NC}\n" "Checkout failed with status: ${checkout_status}"
    if [[ $checkout_error == *"is not a commit and a branch"* ]]; then
      printf "${RED}%s${NC}\n" "Commit not found, deepening..."
      local commit_found=false
      # Deepen the clone until the commit is found or a limit is reached
      for i in {1..10}; do
        printf "${YELLOW}%s${NC}\n" "Deepening attempt ${i}: by 10 commits"
        git fetch --deepen 10
        # Try to checkout again
        checkout_error=$(git checkout --force -B "${branch}" "${sha1}" 2>&1)
        checkout_status=$?
        if [ $checkout_status -eq 0 ]; then
          printf "${GREEN}%s${NC}\n" "Checkout succeeded after deepening."
          commit_found=true
          break
        elif [[ $checkout_error == *"is not a commit and a branch"* ]]; then
          # same error, commit still not found
          :
        else
          # If the error is not about the commit being missing, break the loop
          printf "${RED}%s${NC}\n" "Checkout failed with an unexpected error: $checkout_error"
          break
        fi
      done

      if [[ $commit_found != true ]]; then
        printf "${RED}%s${NC}\n" "Failed to find commit after deepening. Fetching the full history..."
        git fetch --unshallow
        checkout_error=$(git checkout --force -B "${branch}" "${sha1}")
        checkout_status=$?
        if [ $checkout_status -eq 0 ]; then
          printf "${GREEN}%s${NC}\n" "Checkout succeeded after full fetch."
        else
          printf "${RED}%s${NC}\n" "Full checkout failed."
          exit ${checkout_status}
        fi
      fi

    else
      echo "Checkout failed with an unexpected error: $checkout_error"
      exit 1
    fi
  fi
}

fetch_repo "${FETCH_PARAMS_SERIALIZED}" "${REFSPEC}" "${BRANCH}" "${SHA1}"
EOF
  echo "${fetch_repo_script}"
}

#################################################
#                     MAIN                      #
#################################################

main() {
  fix_home_in_old_images
  print_common_debug_info "$@"
  # omit checkout when code already exist (e.g. mounted locally with -v param)
  if [ ! -e "${HOME}/code/.git" ]; then
    setup_git_lfs "${LFS_ENABLED}"

    GR_SSH__SSH_CONFIG_DIR="${SSH_CONFIG_DIR:-}" \
      GR_SSH__SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-}" \
      GR_SSH__SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-}" \
      GR_SSH__SSH_PRIVATE_KEY_B64="${SSH_PRIVATE_KEY_B64:-}" \
      GR_SSH__CHECKOUT_KEY="${CHECKOUT_KEY:-}" \
      GR_SSH__CHECKOUT_KEY_PUBLIC="${CHECKOUT_KEY_PUBLIC:-}" \
      GR_SSH__SSH_PUBLIC_KEY_B64="${SSH_PUBLIC_KEY_B64:-}" \
      GR_SSH__DEBUG_SSH="${DEBUG_SSH:-}" \
      setup_ssh

    repo_checkout "${DEST_DIR}"
  fi
}

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ "${CIRCLECI}" == "true" ]]; then
  main "$@"
else
  printf "%s\n" "Loaded: ${BASH_SOURCE[0]:-}"
fi
