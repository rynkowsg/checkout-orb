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

set -euo pipefail

#################################################
#             ENVIRONMENT VARIABLES             #
#################################################

DEBUG=${DEBUG:-0}
if [ "${DEBUG}" = 1 ]; then
  set -x
  ssh-add -l
  ssh-add -L
  ssh-agent
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
  printenv | sort
fi

# Variables specified by CircleCI:
# - CHECKOUT_KEY - private key
# - CHECKOUT_KEY_PUBLIC - public key
# - CIRCLE_BRANCH - branch specified by CircleCI
# - CIRCLE_REPOSITORY_URL
# - CIRCLE_SHA1 - SHA specified by CircleCI
# - CIRCLE_TAG - tag specified by CircleCI

# repo coordinates, if not specified takes coordinates from CircleCI variables
REPO_URL=${REPO_URL:-${CIRCLE_REPOSITORY_URL:-}}
# If run from CircleCI, variables CIRCLE_REPOSITORY_URL and CIRCLE_SHA1 is
# always provided, while CIRCLE_TAG and CIRCLE_BRANCH are depend on whether
# the build is triggered by a tag or a branch, respectively..

if [ "${REPO_URL}" == "${CIRCLE_REPOSITORY_URL}" ]; then
  # if REPO_URL & CIRCLE_REPOSITORY_URL are same, we clone the repo triggering the CI.
  REPO_BRANCH=${REPO_BRANCH:-${CIRCLE_BRANCH:-}}
  REPO_TAG=${REPO_TAG:-${CIRCLE_TAG:-}}
  REPO_SHA1=${REPO_SHA1:-${CIRCLE_SHA1:-}}
else
  # otherwise we clone other repo then the repo triggering the CI.
  # In such case repo coordinates should be given.
  REPO_BRANCH=${REPO_BRANCH:-}
  REPO_TAG=${REPO_TAG:-}
  REPO_SHA1=${REPO_SHA1:-}
  # Example: If we used CIRCLE_ env as defaults here, we could end up with situation that
  # CI repo is triggered by TAG. In the workflow it clones other repo by branch,
  # but since CIRCLE_TAG exists, it will try to clone tag that doesn't exist.
fi

DEPTH=${DEPTH:--1}
SUBMODULES_DEPTH=${SUBMODULES_DEPTH:--1}

#DEST_DIR - destination for repo, if not provided checks out in CWD
DEST_DIR=${DEST_DIR:-.}
# eval to resolve ~ in the path
eval DEST_DIR="${DEST_DIR}"

# SUBMODULES_ENABLED - submodules support, if not specified, set to false
SUBMODULES_ENABLED=${SUBMODULES_ENABLED:-0}

# LFS_ENABLED - Git LFS support, if not specified, set to false
LFS_ENABLED=${LFS_ENABLED:-0}

SSH_CONFIG_DIR="${SSH_CONFIG_DIR:-}"
SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH:-}"
SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH:-}"

#SSH_PRIVATE_KEY_B64 - SSH private key encoded in Base64 (optional), provided by context
#SSH_PUBLIC_KEY_B64 - SSH public key encoded in Base64 (optional)), provided by context

printf "%s\n" "DEBUG=${DEBUG:-}"
printf "%s\n" "REPO_URL=${REPO_URL:-}"
printf "%s\n" "REPO_BRANCH=${REPO_BRANCH:-}"
printf "%s\n" "REPO_TAG=${REPO_TAG:-}"
printf "%s\n" "REPO_SHA1=${REPO_SHA1:-}"
printf "%s\n" "SUBMODULES_DEPTH=${SUBMODULES_DEPTH:-}"
printf "%s\n" "DEST_DIR=${DEST_DIR:-}"
printf "%s\n" "SUBMODULES_ENABLED=${SUBMODULES_ENABLED:-}"
printf "%s\n" "LFS_ENABLED=${LFS_ENABLED:-}"
printf "%s\n" "SSH_CONFIG_DIR=${SSH_CONFIG_DIR:-}"
printf "%s\n" "SSH_PRIVATE_KEY_PATH=${SSH_PRIVATE_KEY_PATH:-}"
printf "%s\n" "SSH_PUBLIC_KEY_PATH=${SSH_PUBLIC_KEY_PATH:-}"
printf "%s\n" "SSH_PRIVATE_KEY_B64=${SSH_PRIVATE_KEY_B64:-}"
printf "%s\n" "SSH_PUBLIC_KEY_B64=${SSH_PUBLIC_KEY_B64:-}"

#################################################
#                    COLORS                     #
#################################################

GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')

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

if [ -z "${SSH_CONFIG_DIR}" ]; then
  SSH_CONFIG_DIR="$(mktemp -d -t "clone_git_repo-ssh-$(date +%Y%m%d_%H%M%S)-XXX")"
  # shellcheck disable=SC2064
  if [ "${DEBUG}" = 0 ]; then
    # remove this, but only when DEBUG is false
    # It might be useful to keep it when debugging.
    trap "rm -rf \"${SSH_CONFIG_DIR}\"" EXIT
  fi
#  SSH_CONFIG_DIR=~/.ssh
fi

# Note:
# I think CircleCI back in the days used CHECKOUT_KEY & CHECKOUT_KEY_PUBLIC to provide SSH identity.
#
# but in some cases when I want my own keys (e.g. I want to fetch multiple repos),
# then it can by done by providing SSH_PRIVATE_KEY_B64 and SSH_PUBLIC_KEY_B64
SSH_PRIVATE_KEY=
if (: "${SSH_PRIVATE_KEY_B64?}") 2>/dev/null; then
  printf "%s\n" "- found env var SSH_PRIVATE_KEY_B64"
  SSH_PRIVATE_KEY="$(echo "${SSH_PRIVATE_KEY_B64}" | base64 -d)"
elif [ -n "${SSH_PRIVATE_KEY_PATH}" ]; then
  SSH_PRIVATE_KEY="$(cat "${SSH_PRIVATE_KEY_PATH}")"
  printf "%s\n" "- SSH_PRIVATE_KEY read from SSH_PRIVATE_KEY_PATH"
elif [ -f ~/.ssh/id_rsa ]; then
  SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
  printf "%s\n" "- SSH_PRIVATE_KEY read from ~/.ssh/id_rsa"
elif [ -n "${CHECKOUT_KEY:-}" ]; then
  SSH_PRIVATE_KEY="${CHECKOUT_KEY:-}"
  printf "%s\n" "- SSH_PRIVATE_KEY set to CHECKOUT_KEY"
elif ssh-add -l &>/dev/null; then
  printf "%s\n" "- detected ssh-agent has some keys already loaded:"
  ssh-add -l
else
  printf "${RED}%s${NC}\n" "No SSH identity provided (private key)."
  exit 1
fi
SSH_PUBLIC_KEY=
if (: "${SSH_PUBLIC_KEY_B64?}") 2>/dev/null; then
  printf "%s\n" "- found env var SSH_PUBLIC_KEY_B64"
  SSH_PUBLIC_KEY="$(echo "${SSH_PUBLIC_KEY_B64}" | base64 -d)"
elif [ -n "${SSH_PUBLIC_KEY_PATH}" ]; then
  SSH_PUBLIC_KEY="$(cat "${SSH_PUBLIC_KEY_PATH}")"
  printf "%s\n" "- SSH_PUBLIC_KEY read from SSH_PUBLIC_KEY_PATH"
elif [ -f ~/.ssh/id_rsa.pub ]; then
  SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
  printf "%s\n" "- SSH_PUBLIC_KEY read from ~/.ssh/id_rsa.pub"
elif [ -n "${CHECKOUT_KEY_PUBLIC:-}" ]; then
  SSH_PUBLIC_KEY="${CHECKOUT_KEY_PUBLIC:-}"
  printf "%s\n" "- SSH_PUBLIC_KEY set to CHECKOUT_KEY_PUBLIC"
elif ssh-add -l &>/dev/null; then
  printf "%s\n" "- public key not provided, but identity already exist in the ssh-agent."
  ssh-add -l
else
  printf "${RED}%s${NC}\n" "No SSH identity provided (public key)."
  exit 1
fi

#################################################
#                   UTILITIES                   #
#################################################

function setup_git_lfs {
  if ! which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 0 ]; then
    1; # do nothing
  elif ! which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 1 ]; then
    printf "${GREEN}%s${NC}\n" "Installing Git LFS..."
    curl -sSL https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install -y git-lfs
    printf "${GREEN}%s${NC}\n\n" "Installing Git LFS... DONE"
  elif which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 0 ]; then
    sudo git lfs uninstall --system
    git lfs uninstall
  elif which git-lfs >/dev/null && [ "${LFS_ENABLED}" = 1 ]; then
    git lfs install
  else
    printf "${RED}%s${NC}\n" "This should never happen"
    exit 1
  fi
}

function setup_ssh {
  printf "${GREEN}%s${NC}\n" "Setting up SSH..."
  # --- create SSH dir
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${SSH_CONFIG_DIR}"
  mkdir -p "${SSH_CONFIG_DIR}"
  chmod 0700 "${SSH_CONFIG_DIR}"
  # --- create known_hosts
  local known_hosts="${SSH_CONFIG_DIR}/known_hosts"
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${known_hosts}"
  # Current fingerprints: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  {
    printf "%s\n" "ssh.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    printf "%s\n" "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
    printf "%s\n" "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
    printf "%s\n" "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
  } >>"${known_hosts}"
  mkdir -p ~/.ssh
  cp "${known_hosts}" ~/.ssh/known_hosts
  # alternatively we could just use: ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  chmod 0600 "${known_hosts}"
  # --- create id_rsa.pub (it's not necessary though)
  local public_key_path=
  if [ -n "${SSH_PUBLIC_KEY}" ]; then
    public_key_path="${SSH_CONFIG_DIR}/id.pub"
    printf "${GREEN}%s${NC}\n" "Setting up SSH... ${public_key_path}"
    printf "%s" "${SSH_PUBLIC_KEY}" >"${public_key_path}"
  fi
  # --- create id_rsa
  local private_key_path=
  if [ -n "${SSH_PRIVATE_KEY}" ]; then
    private_key_path="${SSH_CONFIG_DIR}/id"
    printf "${GREEN}%s${NC}\n" "Setting up SSH... ${private_key_path}"
    printf "%s\n" "${SSH_PRIVATE_KEY}" >"${private_key_path}"
    chmod 0600 "${private_key_path}"
    ssh-add "${private_key_path}"
  fi
  eval "$(ssh-agent -s)"

  # point out the private key and known_hosts (alternative to use config file)
  local ssh_params=()
  [ "${DEBUG}" = 1 ] && ssh_params+=("-v")
  [ -n "${private_key_path}" ] && ssh_params+=("-i" "${private_key_path}")
  ssh_params+=("-o" "UserKnownHostsFile=\"${known_hosts}\"")
  export GIT_SSH="ssh ${ssh_params[*]}"
  export GIT_SSH_COMMAND="ssh ${ssh_params[*]}"
  # use git+ssh instead of https
  #git config --global url."ssh://git@github.com".insteadOf "https://github.com" || true
  git config --global --unset-all url.ssh://git@github.com.insteadof || true
  git config --global gc.auto 0 || true
  printf "${GREEN}%s${NC}\n" "Setting up SSH... DONE"
  printf "%s\n" ""
  # --- validate
  printf "${GREEN}%s${NC}\n" "Validating GitHub authentication..."
  ssh "${ssh_params[@]}" -T git@github.com || true
  printf "%s\n" ""
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
  mkdir -p "${dest}"
  if [ "$(ls -A "${dest}")" ]; then
    printf "${RED}%s${NC}\n" "Directory \"${dest}\" is not empty."
    exit 1
  fi
  cd "${dest}"
  # Skip smudge to download binary files later in a faster batch
  git config --global init.defaultBranch master
  [ "${LFS_ENABLED}" = 1 ] && git lfs install --skip-smudge
  # --skip-smudge
  git init
  git remote add origin "${REPO_URL}"
  [ "${LFS_ENABLED}" = 1 ] && git lfs install --local --skip-smudge
  if [ "${DEBUG}" = 1 ]; then
    if [ "${LFS_ENABLED}" = 1 ]; then
      printf "${YELLOW}%s${NC}\n" "[LOGS] git lfs env"
      git lfs env
      printf "%s\n" ""
    fi
    printf "${YELLOW}%s${NC}\n" "[LOGS] git config -l"
    git config -l --system | sort
    git config -l --global | sort
    git config -l --worktree | sort
    git config -l --local | sort
    printf "%s\n" ""
  fi
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
