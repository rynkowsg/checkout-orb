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

set -eo pipefail

#################################################
#                    COLORS                     #
#################################################

GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')

#################################################
#             ENVIRONMENT VARIABLES             #
#################################################

# vars that should be provided by system

HOME="${HOME:-/home/circleci}"

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
#

# When assigning final value, we prioritise orb params,
# then env variables, and at the end CircleCI-specific variables.

DEBUG=${PARAM_DEBUG:-${DEBUG:-0}}
if [ "${DEBUG}" = 1 ]; then
  set -x
  ssh-add -l
  ssh-add -L
  ssh-agent
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
  printenv | sort
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

#DEST_DIR - destination for repo, if not provided checks out in CWD
DEST_DIR=${PARAM_DEST_DIR:-.}
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
#SSH_PUBLIC_KEY_B64 - SSH public key encoded in Base64 (optional)), provided by context

printf "${GREEN}%s${NC}\n" "Environment variables - possible to provide via command params:"
printf "%s\n" "DEBUG=${DEBUG:-}"
printf "%s\n" "DEST_DIR=${DEST_DIR:-}"
printf "%s\n" "GITHUB_TOKEN=${GITHUB_TOKEN:-}"
printf "%s\n" "LFS_ENABLED=${LFS_ENABLED:-}"
printf "%s\n" "REPO_BRANCH=${REPO_BRANCH:-}"
printf "%s\n" "REPO_SHA1=${REPO_SHA1:-}"
printf "%s\n" "REPO_TAG=${REPO_TAG:-}"
printf "%s\n" "REPO_URL=${REPO_URL:-}"
printf "%s\n" "SUBMODULES_DEPTH=${SUBMODULES_DEPTH:-}"
printf "%s\n" "SUBMODULES_ENABLED=${SUBMODULES_ENABLED:-}"

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

function setup_git_lfs {
  printf "${GREEN}%s${NC}\n" "Setting up Git LFS"
  if ! which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 0 ]; then
    1; # do nothing
  elif ! which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 1 ]; then
    printf "${GREEN}%s${NC}\n" "Installing Git LFS..."
    curl -sSL https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install -y git-lfs
    printf "${GREEN}%s${NC}\n\n" "Installing Git LFS... DONE"
  elif which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 0 ]; then
    if git config --list --system | grep -q "filter.lfs"; then
        sudo git lfs uninstall --system
    fi
    if git config --list --global | grep -q "filter.lfs"; then
        git lfs uninstall
    fi
  elif which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 1 ]; then
    git lfs install
  else
    printf "${RED}%s${NC}\n" "This should never happen"
    exit 1
  fi
  printf "%s\n" ""
}

function setup_ssh {
  printf "${GREEN}%s${NC}\n" "Setting up SSH..."
  # --- create SSH dir
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${SSH_CONFIG_DIR}"
  mkdir -p "${SSH_CONFIG_DIR}"
  chmod 0700 "${SSH_CONFIG_DIR}"

  # --- keys

  # Note:
  # CircleCI uses CHECKOUT_KEY & CHECKOUT_KEY_PUBLIC in the build-in checkout.
  # At least, they used it in the past when you could still preview their checkout script in CircleCI step.
  # The code below assumes CHECKOUT_KEY & CHECKOUT_KEY_PUBLIC could be available,
  # but unless CircleCI change current policy (and start setting them) or orb client
  # export these from step a before, they are not defined.
  #
  # To provide custom keys, you can use either:
  # - CHECKOUT_KEY & CHECKOUT_KEY_PUBLIC or
  # - SSH_PRIVATE_KEY_B64 and SSH_PUBLIC_KEY_B64.

  printf "${GREEN}%s${NC}\n" "Setting up SSH... private key"
  local ssh_private_key_path_default="${SSH_CONFIG_DIR}/id_rsa"
  local ssh_private_key_path=
  if [ -n "${SSH_PRIVATE_KEY_PATH}" ]; then
    if [ -f "${SSH_PRIVATE_KEY_PATH}" ]; then
      ssh_private_key_path="${SSH_PRIVATE_KEY_PATH}"
      printf "%s\n" "- found private key at SSH_PRIVATE_KEY_PATH (${SSH_PRIVATE_KEY_PATH})"
    else
      printf "${RED}%s${NC}\n" "Can not find private key at path SSH_PRIVATE_KEY_PATH (${SSH_PRIVATE_KEY_PATH})"
      exit 1
    fi
  elif (: "${SSH_PRIVATE_KEY_B64?}") 2>/dev/null; then
    printf "%s\n" "- saved private key from env var SSH_PRIVATE_KEY_B64"
    ssh_private_key_path="${ssh_private_key_path_default}"
    echo "${SSH_PRIVATE_KEY_B64}" | base64 -d > "${ssh_private_key_path}"
  elif [ -f "${HOME}/.ssh/id_rsa" ]; then
    printf "%s\n" "- found private key at ${HOME}/.ssh/id_rsa"
    ssh_private_key_path="${HOME}/.ssh/id_rsa"
  elif (: "${CHECKOUT_KEY?}") 2>/dev/null; then
    ssh_private_key_path="${ssh_private_key_path_default}"
    printf "%s" "${CHECKOUT_KEY}" > "${ssh_private_key_path}"
    printf "%s\n" "- saved private key from env var CHECKOUT_KEY"
  elif ssh-add -l &>/dev/null; then
    printf "%s\n" "- private key not provided, but identity already exist in the ssh-agent."
    ssh-add -l
  else
    printf "${RED}%s${NC}\n" "No SSH identity provided (private key)."
    exit 1
  fi
  if [ -n "${ssh_private_key_path}" ] && [ -f "${ssh_private_key_path}" ] ; then
    chmod 0600 "${ssh_private_key_path}"
    ssh-add "${ssh_private_key_path}"
  fi
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH... public key"
  ssh_public_key_path_default="${SSH_CONFIG_DIR}/id_rsa.pub"
  local ssh_public_key_path=
  if [ -n "${SSH_PUBLIC_KEY_PATH}" ]; then
    if [ -f "${SSH_PUBLIC_KEY_PATH}" ]; then
      ssh_public_key_path="${SSH_PUBLIC_KEY_PATH}"
      printf "%s\n" "- found public key at SSH_PUBLIC_KEY_PATH (${SSH_PUBLIC_KEY_PATH})"
    else
      printf "${RED}%s${NC}\n" "Can not find public key at path SSH_PUBLIC_KEY_PATH (${SSH_PUBLIC_KEY_PATH})"
      exit 1
    fi
  elif (: "${SSH_PUBLIC_KEY_B64?}") 2>/dev/null; then
    printf "%s\n" "- saved public key from env var SSH_PUBLIC_KEY_B64"
      ssh_public_key_path="${ssh_public_key_path_default}"
    echo "${SSH_PUBLIC_KEY_B64}" | base64 -d > "${ssh_public_key_path}"
  elif [ -f "${HOME}/.ssh/id_rsa.pub" ]; then
    printf "%s\n" "- found public key at ${HOME}/.ssh/id_rsa.pub"
    ssh_public_key_path="${HOME}/.ssh/id_rsa.pub"
  elif (: "${CHECKOUT_KEY_PUBLIC?}") 2>/dev/null; then
    ssh_public_key_path="${ssh_public_key_path_default}"
    printf "%s" "${CHECKOUT_KEY_PUBLIC}" > "${ssh_public_key_path}"
    printf "%s\n" "- saved public key from env var CHECKOUT_KEY_PUBLIC"
  elif ssh-add -l &>/dev/null; then
    printf "%s\n" "- public key not provided, but identity already exist in the ssh-agent."
    ssh-add -l
  else
    printf "${RED}%s${NC}\n" "No SSH identity provided (public key)."
    exit 1
  fi
  printf "%s\n" ""

  # --- create known_hosts
  local known_hosts="${SSH_CONFIG_DIR}/known_hosts"
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${known_hosts}"
  # Current fingerprints: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  {
    printf "%s\n" "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    printf "%s\n" "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    printf "%s\n" "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    printf "%s\n" "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
    printf "%s\n" "ssh.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    printf "%s\n" "ssh.github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    printf "%s\n" "ssh.github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    printf "%s\n" "ssh.github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
  } >>"${known_hosts}"
  # alternatively we could just use: ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  chmod 0600 "${known_hosts}"
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH...  misc settings"
  # point out the private key and known_hosts (alternative to use config file)
  local ssh_params=()
  [ "${DEBUG}" = 1 ] && ssh_params+=("-v")
  [ -n "${ssh_private_key_path}" ] && ssh_params+=("-i" "${ssh_private_key_path}")
  ssh_params+=("-o" "UserKnownHostsFile=\"${known_hosts}\"")
  # shellcheck disable=SC2155
  export GIT_SSH="$(which ssh)"
  export GIT_SSH_COMMAND="${GIT_SSH} ${ssh_params[*]}"
  # use git+ssh instead of https
  #git config --global url."ssh://git@github.com".insteadOf "https://github.com" || true
  git config --global --unset-all url.ssh://git@github.com.insteadof || true
  git config --global init.defaultBranch master
  git config --global gc.auto 0 || true
  printf "%s\n" ""

  # --- validate
  printf "${GREEN}%s${NC}\n" "Setting up SSH...  Validating GitHub authentication"
#  eval "$(ssh-agent -s)"
#  timeout 5
  ssh "${ssh_params[@]}" -T git@github.com || case $? in
      0) ;; # since we ssh github, it should never happen
      1) ;; # ignore, 1 is here acceptable
      *) echo "ssh validation failed with exit code $?"; exit 1;;
  esac
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH... DONE"
  printf "%s\n" ""
}

# $1 - repo url
# $2 - github token
function adjust_repo_url {
  local repo_url="${1}"
  local github_token="${2}"
  if [[ $repo_url == "https://github.com"* ]] && [[ -n "${github_token}" ]]; then
    echo "https://${github_token}@${repo_url#https://}"
  else
    echo "${repo_url}"
  fi
}

# $1 - dest
function repo_checkout {
  local -r dest="${1}"
  # To facilitate cloning shallow repo for branch, tag or particular sha,
  # we don't use `git clone`, but combination of `git init` & `git fetch`.
  printf "${GREEN}%s${NC}\n" "Creating clean git repo..."
  printf "%s\n" "- src: ${REPO_URL}"
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
  git init
  local repo_url
  repo_url="$(adjust_repo_url "${REPO_URL}" "${GITHUB_TOKEN}")"
  git remote add origin "${repo_url}"
  [ "${LFS_ENABLED}" = 1 ] && git lfs install --local --skip-smudge
  if [ "${DEBUG}" = 1 ]; then
    if [ "${LFS_ENABLED}" = 1 ]; then
      printf "${YELLOW}%s${NC}\n" "[LOGS] git lfs env"
      git lfs env
    fi
    printf "${YELLOW}%s${NC}\n" "[LOGS] git config -l"
    git config -l --system | sort
    git config -l --global | sort
    git config -l --worktree | sort
    git config -l --local | sort
  fi
  printf "%s\n" ""

  fetch_params=()
  [ "${DEPTH}" -ne -1 ] && fetch_params+=("--depth" "${DEPTH}")
  fetch_params+=("origin")
  if [ -n "${REPO_TAG+x}" ] && [ -n "${REPO_TAG}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out tag..."
    git fetch "${fetch_params[@]}" "tags/${REPO_TAG}"
    git checkout --force "tags/${REPO_TAG}"
    git reset --hard "${REPO_SHA1}"
  elif [ -n "${REPO_BRANCH+x}" ] && [ -n "${REPO_BRANCH}" ] && [ -n "${REPO_SHA1+x}" ] && [ -n "${REPO_SHA1}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out branch..."
    git fetch "${fetch_params[@]}" "${REPO_BRANCH}"
    git checkout --force -B "${REPO_BRANCH}" "${REPO_SHA1}"
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
      git submodule foreach --recursive '[ -f .gitattributes ] && grep -q "filter=lfs" .gitattributes && git lfs install --local --skip-smudge && git lfs pull || echo "Skipping submodule without LFS or .gitattributes"'
    fi
  fi
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Summary"
  git --no-pager log --no-color -n 1 --format="HEAD is now at %h %s"
  printf "%s\n" ""
}

#################################################
#                     MAIN                      #
#################################################

main() {
  # omit checkout when code already exist (e.g. mounted locally with -v param)
  if [ ! -e "${HOME}/code/.git" ]; then
    setup_git_lfs
    setup_ssh
    repo_checkout "${DEST_DIR}"
  fi
}

# shellcheck disable=SC2199
# to disable warning about concatenation of BASH_SOURCE[@]
# It is not a problem. This part pf condition is only to prevent `unbound variable` error.
if [[ -n "${BASH_SOURCE[@]}" && "${BASH_SOURCE[0]}" != "${0}" ]]; then
  [[ -n "${BASH_SOURCE[0]}" ]] && printf "%s\n" "Loaded: ${BASH_SOURCE[0]}"
else
  main "$@"
fi
