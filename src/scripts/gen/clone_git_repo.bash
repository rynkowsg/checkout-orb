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
# source "${SHELL_GR_DIR}/lib/color.bash" # BEGIN
#!/usr/bin/env bash

#################################################
#                    COLORS                     #
#################################################

# shellcheck disable=SC2034
GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')
# source "${SHELL_GR_DIR}/lib/color.bash" # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/circleci.bash
# source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info # BEGIN
#!/usr/bin/env bash

# Path Initialization
if [ -n "${SHELL_GR_DIR}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
else
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # GREEN, NC # SKIPPED

fix_home_in_old_images() {
  # Workaround old docker images with incorrect $HOME
  # check https://github.com/docker/docker/issues/2968 for details
  if [ -z "${HOME}" ] || [ "${HOME}" = "/" ]; then
    HOME="$(getent passwd "$(id -un)" | cut -d: -f6)"
    export HOME
  fi
}

# Prints common debug info
# Usage:
#     print_common_debug_info "$@"
print_common_debug_info() {
  printf "${GREEN}%s${NC}\n" "Common debug info"
  bash --version
  # typical CLI debugging variables
  printf "\$0: %s\n" "$0"
  printf "\$@: %s\n" "$@"
  printf "BASH_SOURCE[0]: %s\n" "${BASH_SOURCE[0]}"
  printf "BASH_SOURCE[*]: %s\n" "${BASH_SOURCE[*]}"
  # other common
  printf "HOME: %s\n" "${HOME}"
  printf "PATH: %s\n" "${PATH}"
  printf "CIRCLECI: %s\n" "${CIRCLECI}"
  # shellpack related
  [ -n "${SCRIPT_PATH:-}" ] && printf "SCRIPT_PATH: %s\n" "${SCRIPT_PATH}"
  [ -n "${SCRIPT_DIR:-}" ] && printf "SCRIPT_DIR: %s\n" "${SCRIPT_DIR}"
  [ -n "${ROOT_DIR:-}" ] && printf "ROOT_DIR: %s\n" "${ROOT_DIR}"
  [ -n "${SHELL_GR_DIR:-}" ] && printf "SHELL_GR_DIR: %s\n" "${SHELL_GR_DIR}"
  [ -n "${_SHELL_GR_DIR:-}" ] && printf "_SHELL_GR_DIR: %s\n" "${_SHELL_GR_DIR}"
  printf "%s\n" ""
}
# source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/git_checkout_advanced.bash
# source "${SHELL_GR_DIR}/lib/git_checkout_advanced.bash" # git_checkout_advanced # BEGIN
#!/usr/bin/env bash

# Path Initialization
if [ -n "${SHELL_GR_DIR}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
else
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # GREEN, NC, RED, YELLOW # SKIPPED
# source "${_SHELL_GR_DIR}/lib/git.bash"   # is_git_repository # BEGIN
#!/usr/bin/env bash

is_git_repository() {
  git rev-parse --git-dir >/dev/null 2>&1
}
# source "${_SHELL_GR_DIR}/lib/git.bash"   # is_git_repository # END

# $1 - dest
git_checkout_advanced() {
  local -r input_DEBUG="${GR_GITCO__DEBUG:-}"
  local -r input_DEBUG_GIT="${GR_GITCO__DEBUG_GIT:-}"
  local -r input_DEPTH="${GR_GITCO__DEPTH:-}"
  local -r input_DEST_DIR="${GR_GITCO__DEST_DIR:-}"
  local -r input_LFS_ENABLED="${GR_GITCO__LFS_ENABLED:-}"
  local -r input_REPO_BRANCH="${GR_GITCO__REPO_BRANCH:-}"
  local -r input_REPO_SHA1="${GR_GITCO__REPO_SHA1:-}"
  local -r input_REPO_TAG="${GR_GITCO__REPO_TAG:-}"
  local -r input_REPO_URL="${GR_GITCO__REPO_URL:-}"
  local -r input_SUBMODULES_DEPTH="${GR_GITCO__SUBMODULES_DEPTH:-}"
  local -r input_SUBMODULES_ENABLED="${GR_GITCO__SUBMODULES_ENABLED:-}"

  local -r debug="${input_DEBUG}"
  local -r depth="${input_DEPTH}"
  local -r debug_git="${input_DEBUG_GIT}"
  local -r dest="${input_DEST_DIR}"
  local -r lfs_enabled="${input_LFS_ENABLED}"
  local -r repo_branch="${input_REPO_BRANCH}"
  local -r repo_tag="${input_REPO_TAG}"
  local -r repo_sha1="${input_REPO_SHA1}"
  local repo_url
  repo_url="$(github_authorized_repo_url "${input_REPO_URL}" "${GITHUB_TOKEN}")"
  if [[ "${repo_url}" != "${input_REPO_URL}" ]]; then
    printf "${GREEN}%s${NC}\n" "Detected GitHub token. Update:"
    printf "%s\n" "- repo_url: ${repo_url}"
  fi
  readonly repo_url
  local -r submodules_enabled="${input_SUBMODULES_ENABLED}"
  local -r submodules_depth="${input_SUBMODULES_DEPTH}"

  # To facilitate cloning shallow repo for branch, tag or particular sha,
  # we don't use `git clone`, but combination of `git init` & `git fetch`.
  printf "${GREEN}%s${NC}\n" "Creating clean git repo..."
  printf "%s\n" "- repo_url: ${input_REPO_URL}"
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
  cd "${dest}" || error_exit "Can't enter destination directory: '${dest}'"
  # Skip smudge to download binary files later in a faster batch
  [ "${lfs_enabled}" = 1 ] && git lfs install --skip-smudge
  # --skip-smudge

  if is_git_repository; then
    git remote set-url origin "${repo_url}"
  else
    git init
    git remote add origin "${repo_url}"
  fi
  [ "${lfs_enabled}" = 1 ] && git lfs install --local --skip-smudge
  if [ "${debug_git}" = 1 ]; then
    if [ "${lfs_enabled}" = 1 ]; then
      printf "${YELLOW}%s${NC}\n" "[LOGS] git lfs env"
      git lfs env
    fi
    printf "${YELLOW}%s${NC}\n" "[LOGS] git config -l"
    [ -f /etc/gitconfig ] && git config --list --system | sort
    git config --list --global | sort
    git config --list --worktree | sort
    git config --list --local | sort
  fi
  printf "%s\n" ""

  fetch_params=()
  [ "${depth}" -ne -1 ] && fetch_params+=("--depth" "${depth}")
  fetch_params_serialized="$(
    IFS=,
    echo "${fetch_params[*]}"
  )"
  # create fetch_repo_script
  local fetch_repo_script
  fetch_repo_script="$(create_fetch_repo_script)"
  # start checkout
  if [ -n "${repo_tag}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out tag..."
    git fetch "${fetch_params[@]}" origin "refs/tags/${repo_tag}:refs/tags/${repo_tag}"
    git -c advice.detachedHead=false checkout --force "${repo_tag}"
    git reset --hard "${repo_sha1}"
  elif [ -n "${repo_branch}" ] && [ -n "${repo_sha1}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out branch..."
    bash "${fetch_repo_script}" "${debug}" "${fetch_params_serialized}" "refs/heads/${repo_branch}:refs/remotes/origin/${repo_branch}" "${repo_branch}" "${repo_sha1}"
  else
    printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository."
    printf "${RED}%s${NC}\n" "Need to specify REPO_TAG to fetch by tag or REPO_BRANCH and REPO_SHA1 to fetch by branch."
    exit 1
  fi
  submodule_update_params=("--init" "--recursive")
  [ "${submodules_depth}" -ne -1 ] && submodule_update_params+=("--depth" "${submodules_depth}")
  [ "${submodules_enabled}" = 1 ] && git submodule update "${submodule_update_params[@]}"
  if [ "${lfs_enabled}" = 1 ]; then
    git lfs pull
    if [ "${submodules_enabled}" = 1 ]; then
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
# source "${SHELL_GR_DIR}/lib/git_checkout_advanced.bash" # git_checkout_advanced # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/git_lfs.bash
# source "${SHELL_GR_DIR}/lib/git_lfs.bash" # setup_git_lfs # BEGIN
#!/usr/bin/env bash

# Path Initialization
if [ -n "${SHELL_GR_DIR}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
else
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # GREEN, NC, RED # SKIPPED

setup_git_lfs() {
  local -r lfs_enabled="$1"
  printf "${GREEN}%s${NC}\n" "Setting up Git LFS"
  if ! which git-lfs >/dev/null && [ "${lfs_enabled}" = 0 ]; then
    printf "%s\n" "git-lfs is not installed, but also it's not needed. Nothing to do here."
  elif ! which git-lfs >/dev/null && [ "${lfs_enabled}" = 1 ]; then
    printf "${GREEN}%s${NC}\n" "Installing Git LFS..."
    curl -sSL https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install -y git-lfs
    printf "${GREEN}%s${NC}\n\n" "Installing Git LFS... DONE"
  elif which git-lfs >/dev/null && [ "${lfs_enabled}" = 0 ]; then
    if [ -f /etc/gitconfig ] && git config --list --system | grep -q "filter.lfs"; then
      sudo git lfs uninstall --system
    fi
    if git config --list --global | grep -q "filter.lfs"; then
      git lfs uninstall
    fi
  elif which git-lfs >/dev/null && [ "${lfs_enabled}" = 1 ]; then
    git lfs install
  else
    printf "${RED}%s${NC}\n" "This should never happen"
    exit 1
  fi
  printf "%s\n" ""
}
# source "${SHELL_GR_DIR}/lib/git_lfs.bash" # setup_git_lfs # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/github.bash
# source "${SHELL_GR_DIR}/lib/github.bash" # github_authorized_repo_url # BEGIN
#!/usr/bin/env bash

# Returns GitHub authorized URL if github token provided.
# Otherwise returns same URL.
# Params:
# $1 - repo url
# $2 - github token
github_authorized_repo_url() {
  local repo_url="${1}"
  local github_token="${2}"
  if [[ $repo_url == "https://github.com"* ]] && [[ -n "${github_token}" ]]; then
    echo "https://${github_token}@${repo_url#https://}"
  else
    echo "${repo_url}"
  fi
}
# source "${SHELL_GR_DIR}/lib/github.bash" # github_authorized_repo_url # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@5a6105b/lib/ssh.bash
# source "${SHELL_GR_DIR}/lib/ssh.bash" # setup_ssh # BEGIN
#!/usr/bin/env bash

# Path Initialization
if [ -n "${SHELL_GR_DIR}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
else
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # GREEN, NC, RED # SKIPPED

setup_ssh() {
  local -r input_SSH_CONFIG_DIR="${GR_SSH__SSH_CONFIG_DIR:-}"
  local -r input_SSH_PRIVATE_KEY_PATH="${GR_SSH__SSH_PRIVATE_KEY_PATH:-}"
  local -r input_SSH_PUBLIC_KEY_PATH="${GR_SSH__SSH_PUBLIC_KEY_PATH:-}"
  local -r input_SSH_PRIVATE_KEY_B64="${GR_SSH__SSH_PRIVATE_KEY_B64:-}"
  local -r input_CHECKOUT_KEY="${GR_SSH__CHECKOUT_KEY:-}"
  local -r input_CHECKOUT_KEY_PUBLIC="${GR_SSH__CHECKOUT_KEY_PUBLIC:-}"
  local -r input_SSH_PUBLIC_KEY_B64="${GR_SSH__SSH_PUBLIC_KEY_B64:-}"
  local -r input_DEBUG_SSH="${GR_SSH__DEBUG_SSH:-}"

  printf "${GREEN}%s${NC}\n" "Setting up SSH..."
  # --- create SSH dir
  local -r ssh_config_dir="${input_SSH_CONFIG_DIR:-"${HOME}/.ssh"}"
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${ssh_config_dir}"
  mkdir -p "${ssh_config_dir}"
  chmod 0700 "${ssh_config_dir}"

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
  local ssh_private_key_path_default="${ssh_config_dir}/id_rsa"
  local ssh_private_key_path=
  if [ -n "${input_SSH_PRIVATE_KEY_PATH}" ]; then
    if [ -f "${input_SSH_PRIVATE_KEY_PATH}" ]; then
      ssh_private_key_path="${input_SSH_PRIVATE_KEY_PATH}"
      printf "%s\n" "- found private key at given path (${input_SSH_PRIVATE_KEY_PATH})"
    else
      printf "${RED}%s${NC}\n" "Can not find private key at the given path (${input_SSH_PRIVATE_KEY_PATH})"
      exit 1
    fi
  elif [ -n "${input_SSH_PRIVATE_KEY_B64}" ]; then
    printf "%s\n" "- found private key at given base64 value"
    ssh_private_key_path="${ssh_private_key_path_default}"
    echo "${input_SSH_PRIVATE_KEY_B64}" | base64 -d >"${ssh_private_key_path}"
  elif [ -f "${HOME}/.ssh/id_rsa" ]; then
    printf "%s\n" "- found private key at ${HOME}/.ssh/id_rsa"
    ssh_private_key_path="${HOME}/.ssh/id_rsa"
  elif [ -n "${input_CHECKOUT_KEY}" ]; then
    ssh_private_key_path="${ssh_private_key_path_default}"
    printf "%s" "${input_CHECKOUT_KEY}" >"${ssh_private_key_path}"
    printf "%s\n" "- saved private key from env var"
  elif ssh-add -l &>/dev/null; then
    printf "%s\n" "- private key not provided, but identity already exist in the ssh-agent."
    ssh-add -l
  else
    printf "${RED}%s${NC}\n" "No SSH identity provided (private key)."
    exit 1
  fi
  if [ -n "${ssh_private_key_path}" ] && [ -f "${ssh_private_key_path}" ]; then
    chmod 0600 "${ssh_private_key_path}"
    ssh-add "${ssh_private_key_path}"
  fi
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH... public key"
  ssh_public_key_path_default="${ssh_config_dir}/id_rsa.pub"
  local ssh_public_key_path=
  if [ -n "${input_SSH_PUBLIC_KEY_PATH}" ]; then
    if [ -f "${input_SSH_PUBLIC_KEY_PATH}" ]; then
      ssh_public_key_path="${input_SSH_PUBLIC_KEY_PATH}"
      printf "%s\n" "- found public key at given path (${input_SSH_PUBLIC_KEY_PATH})"
    else
      printf "${RED}%s${NC}\n" "Can not find public key at the given path (${input_SSH_PUBLIC_KEY_PATH})"
      exit 1
    fi
  elif [ -n "${input_SSH_PUBLIC_KEY_B64}" ]; then
    printf "%s\n" "- saved public key from env var SSH_PUBLIC_KEY_B64"
    ssh_public_key_path="${ssh_public_key_path_default}"
    echo "${input_SSH_PUBLIC_KEY_B64}" | base64 -d >"${ssh_public_key_path}"
  elif [ -f "${HOME}/.ssh/id_rsa.pub" ]; then
    printf "%s\n" "- found public key at ${HOME}/.ssh/id_rsa.pub"
    ssh_public_key_path="${HOME}/.ssh/id_rsa.pub"
  elif [ -n "${input_CHECKOUT_KEY_PUBLIC}" ]; then
    ssh_public_key_path="${ssh_public_key_path_default}"
    printf "%s" "${input_CHECKOUT_KEY_PUBLIC}" >"${ssh_public_key_path}"
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
  local known_hosts="${ssh_config_dir}/known_hosts"
  printf "${GREEN}%s${NC}\n" "Setting up SSH... ${known_hosts}"
  # BitBucket: https://bitbucket.org/site/ssh, https://bitbucket.org/blog/ssh-host-key-changes
  # GitHub: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  # GitLab: https://docs.gitlab.com/ee/user/gitlab_com/#ssh-known_hosts-entries
  {
    cat <<-EOF
bitbucket.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPIQmuzMBuKdWeF4+a2sjSSpBK0iqitSQ+5BM9KhpexuGt20JpTVM7u5BDZngncgrqDMbWdxMWWOGtZ9UgbqgZE=
bitbucket.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazEu89wgQZ4bqs3d63QSMzYVa0MuJ2e2gKTKqu+UUO
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQeJzhupRu0u0cdegZIa8e86EG2qOCsIsD1Xw0xSeiPDlCr7kq97NLmMbpKTX6Esc30NuoqEEHCuc7yWtwp8dI76EEEB1VqY9QJq6vk+aySyboD5QF61I/1WeTwu+deCbgKMGbUijeXhtfbxSxm6JwGrXrhBdofTsbKRUsrN1WoNgUa8uqN1Vx6WAJw1JHPhglEGGHea6QICwJOAr/6mrui/oB7pkaWKHj3z7d1IC4KWLtY47elvjbaTlkN04Kc/5LFEirorGYVbt15kAUlqGM65pk6ZBxtaO3+30LVlORZkxOh+LKL/BvbZ/iRNhItLqNyieoQj/uh/7Iv4uyH/cV/0b4WDSd3DptigWq84lJubb9t/DnZlrJazxyDCulTmKdOR7vs9gMTo+uoIrPSb8ScTtvw65+odKAlBj59dhnVp9zd7QUojOpXlL62Aw56U4oO+FALuevvMjiWeavKhJqlR7i5n9srYcrNV7ttmDw7kf/97P5zauIhxcjX+xHv4M=
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=
gitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf
gitlab.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9
ssh.github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
ssh.github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
ssh.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
ssh.github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
EOF
  } >>"${known_hosts}"
  # alternatively we could just use: ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  chmod 0600 "${known_hosts}"
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH...  misc settings"
  # point out the private key and known_hosts (alternative to use config file)
  local ssh_params=()
  [ "${input_DEBUG_SSH}" = 1 ] && ssh_params+=("-v")
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
  ssh "${ssh_params[@]}" -T git@github.com || case $? in
    0) ;; # since we ssh github, it should never happen
    1) ;; # ignore, 1 is here acceptable
    *)
      echo "ssh validation failed with exit code $?"
      exit 1
      ;;
  esac
  printf "%s\n" ""

  printf "${GREEN}%s${NC}\n" "Setting up SSH... DONE"
  printf "%s\n" ""
}
# source "${SHELL_GR_DIR}/lib/ssh.bash" # setup_ssh # END

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
#                     MAIN                      #
#################################################

main() {
  fix_home_in_old_images
  print_common_debug_info "$@"
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
