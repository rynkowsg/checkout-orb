#!/bin/bash
#  Copyright (c) 2024 Greg Rynkowski. All rights reserved.
#  License: MIT License

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
  SHELL_GR_DIR="${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@v0.9.0"
fi
# Library Sourcing
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/color.bash
# source "${SHELL_GR_DIR}/lib/color.bash" # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# shellcheck disable=SC2034
GREEN=$(printf '\033[32m')
# shellcheck disable=SC2034
RED=$(printf '\033[31m')
# shellcheck disable=SC2034
YELLOW=$(printf '\033[33m')
# shellcheck disable=SC2034
NC=$(printf '\033[0m')

# Color enabled by default
COLOR=${COLOR:-1}

is_color() {
  case "${COLOR}" in
    1 | "true") return 0 ;; # true
    *) return 1 ;;          # false
  esac
}
# source "${SHELL_GR_DIR}/lib/color.bash" # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/circleci.bash
# source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
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
  # sosh related
  [ -n "${SCRIPT_PATH:-}" ] && printf "SCRIPT_PATH: %s\n" "${SCRIPT_PATH}"
  [ -n "${SCRIPT_DIR:-}" ] && printf "SCRIPT_DIR: %s\n" "${SCRIPT_DIR}"
  [ -n "${ROOT_DIR:-}" ] && printf "ROOT_DIR: %s\n" "${ROOT_DIR}"
  [ -n "${SHELL_GR_DIR:-}" ] && printf "SHELL_GR_DIR: %s\n" "${SHELL_GR_DIR}"
  [ -n "${_SHELL_GR_DIR:-}" ] && printf "_SHELL_GR_DIR: %s\n" "${_SHELL_GR_DIR}"
  printf "%s\n" ""
}
# source "${SHELL_GR_DIR}/lib/circleci.bash" # fix_home_in_old_images, print_common_debug_info # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/git_checkout_advanced.bash
# source "${SHELL_GR_DIR}/lib/git_checkout_advanced.bash" # git_checkout_advanced # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash"      # GREEN, NC, RED, YELLOW # SKIPPED
# source "${_SHELL_GR_DIR}/lib/git.bash"        # is_git_repository_root_dir # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

is_git_repository() {
  git rev-parse --git-dir >/dev/null 2>&1
}

# Succeeds when the current directory is the root of a repo, not just somewhere inside one.
is_git_repository_root_dir() {
  is_git_repository && [ "$(git rev-parse --show-toplevel)" = "$(pwd -P)" ]
}
# source "${_SHELL_GR_DIR}/lib/git.bash"        # is_git_repository_root_dir # END
# source "${_SHELL_GR_DIR}/lib/git_deepen.bash" # git_deepen_to_branch, git_deepen_to_tag # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # GREEN, NC, RED, YELLOW # SKIPPED

# Prints the remote and the refspec of the upstream of the current branch,
# separated by a space. Prints nothing for a detached HEAD or a branch without
# an upstream.
_git_deepen_upstream() {
  # Without a ref, for-each-ref would list every ref, so a detached HEAD is
  # checked first.
  local head_ref
  head_ref="$(git symbolic-ref -q HEAD || true)"
  if [ -z "${head_ref}" ]; then
    return 0
  fi
  local upstream_remote upstream_remote_ref upstream_tracking_ref
  read -r upstream_remote upstream_remote_ref upstream_tracking_ref \
    <<<"$(git for-each-ref --format="%(upstream:remotename) %(upstream:remoteref) %(upstream)" "${head_ref}")"
  if [ -z "${upstream_remote_ref}" ]; then
    return 0
  fi
  # The refspec names only the branch of HEAD, since a bare
  # `git fetch <remote>` takes every branch the remote has.
  printf "%s %s\n" "${upstream_remote}" "${upstream_remote_ref}:${upstream_tracking_ref}"
}

# Deepens a shallow repo until the history of HEAD reaches a tag whose name
# matches a regex, then fetches the matching tags found in that history.
# Each round deepens twice as much as the one before. When no matching tag
# shows up within these rounds, or the remote has none, it fetches the full
# history. A repo with the full history is not deepened, but it still gets the
# matching tags in that history when they were not fetched.
# Works in the current directory.
# Inputs:
# GR_GITDEEPEN__REMOTE    - remote name, e.g. origin
# GR_GITDEEPEN__REFSPEC   - refspec to deepen, e.g. refs/heads/main:refs/remotes/origin/main
# GR_GITDEEPEN__TAG_REGEX - extended regex (ERE) the tag name has to match,
#                           e.g. ^v[0-9]+\.[0-9]+\.[0-9]+$; empty matches any tag
# The remote and the refspec left empty are taken from the upstream of the
# current branch. When they are neither given nor found there, the function
# fails.
git_deepen_to_tag() {
  local remote="${GR_GITDEEPEN__REMOTE:-}"
  local refspec="${GR_GITDEEPEN__REFSPEC:-}"
  local -r tag_regex="${GR_GITDEEPEN__TAG_REGEX:-}"
  local -r max_rounds=6

  printf "${GREEN}%s${NC}\n" "Deepening to a tag..."
  printf "%s\n" "- tag regex: ${tag_regex}"
  # Bash returns 2 from =~ when the regex itself is invalid.
  local regex_status=0
  # shellcheck disable=SC2319 # the status of the =~ test is the one needed here
  [[ "" =~ ${tag_regex} ]] || regex_status=$?
  if [ "${regex_status}" -eq 2 ]; then
    printf "${RED}%s${NC}\n" "Can not deepen: the tag regex is invalid."
    return 1
  fi
  local local_tag
  local_tag="$(git for-each-ref --merged HEAD --sort=-creatordate --format="%(refname:strip=2)" refs/tags \
    | grep -E -m 1 -e "${tag_regex}" || true)"
  if [ -n "${local_tag}" ]; then
    printf "%s\n" "- tag already in history: ${local_tag}"
    printf "%s\n" ""
    return 0
  fi

  local upstream_remote upstream_refspec
  read -r upstream_remote upstream_refspec <<<"$(_git_deepen_upstream)"
  remote="${remote:-"${upstream_remote}"}"
  refspec="${refspec:-"${upstream_refspec}"}"
  if [ -z "${remote}" ] || [ -z "${refspec}" ]; then
    printf "${RED}%s${NC}\n" "Can not deepen: the remote or the refspec is neither given nor found in the upstream of HEAD."
    return 1
  fi
  readonly remote refspec
  printf "%s\n" "- remote: ${remote}"
  printf "%s\n" "- refspec: ${refspec}"

  # Map each matching remote tag to the commit it points to. An annotated tag
  # is listed twice, and its line ending with "^{}" holds the commit, so that
  # line wins.
  local -A tag_commits=()
  local sha ref name
  while read -r sha ref; do
    name="${ref#refs/tags/}"
    [[ "${name%"^{}"}" =~ ${tag_regex} ]] || continue
    if [[ "${name}" == *"^{}" ]]; then
      tag_commits["${name%"^{}"}"]="${sha}"
    elif [ -z "${tag_commits["${name}"]:-}" ]; then
      tag_commits["${name}"]="${sha}"
    fi
  done < <(git ls-remote --tags "${remote}")
  # Turn it around to look up tags by commit. Ref names cannot hold spaces, so
  # the names of tags on one commit are kept in one space separated string.
  local -A commit_tags=()
  for name in "${!tag_commits[@]}"; do
    commit_tags["${tag_commits["${name}"]}"]+="${name} "
  done

  local step=10
  local round=0
  local -a found_names found_refspecs names
  while true; do
    found_names=()
    found_refspecs=()
    if [ ${#commit_tags[@]} -gt 0 ]; then
      # grep streams the history, so even a long one is never held in memory.
      # rev-list starts from HEAD, so the first tag found is the nearest one.
      while read -r sha; do
        read -r -a names <<<"${commit_tags["${sha}"]}"
        for name in "${names[@]}"; do
          found_names+=("${name}")
          found_refspecs+=("refs/tags/${name}:refs/tags/${name}")
        done
      done < <(git rev-list HEAD | grep -F -x -f <(printf "%s\n" "${!commit_tags[@]}"))
    fi
    if [ ${#found_refspecs[@]} -gt 0 ]; then
      git fetch --no-tags "${remote}" "${found_refspecs[@]}"
      printf "%s\n" "- found tag: ${found_names[0]}"
      printf "%s\n" ""
      return 0
    fi
    if [ "$(git rev-parse --is-shallow-repository)" != "true" ]; then
      printf "${YELLOW}%s${NC}\n" "- no matching tag in the history of HEAD"
      printf "%s\n" ""
      return 0
    fi
    round=$((round + 1))
    if [ ${#commit_tags[@]} -eq 0 ] || [ "${round}" -gt "${max_rounds}" ]; then
      printf "%s\n" "- fetching the full history"
      git fetch --no-tags --unshallow "${remote}" "${refspec}"
    else
      printf "%s\n" "- deepening by ${step} commits"
      git fetch --no-tags --deepen "${step}" "${remote}" "${refspec}"
      step=$((step * 2))
    fi
  done
}

# Fetches the tip of a branch and deepens it together with HEAD until their
# histories meet, so `git merge-base HEAD <remote>/<branch>` works.
# The branch lands in refs/remotes/<remote>/<branch>.
# Each round deepens twice as much as the one before. When the histories do
# not meet within these rounds, it fetches the full history of both.
# Works in the current directory.
# Inputs:
# GR_GITDEEPEN__REMOTE  - remote name, e.g. origin
# GR_GITDEEPEN__REFSPEC - refspec of HEAD to deepen, e.g. refs/heads/feature:refs/remotes/origin/feature
# GR_GITDEEPEN__BRANCH  - branch name on the remote, e.g. main
# The remote and the refspec left empty are taken from the upstream of the
# current branch. When they are neither given nor found there, or the branch is
# not given, the function fails.
git_deepen_to_branch() {
  local remote="${GR_GITDEEPEN__REMOTE:-}"
  local head_refspec="${GR_GITDEEPEN__REFSPEC:-}"
  local -r branch="${GR_GITDEEPEN__BRANCH:-}"
  local -r max_rounds=6

  printf "${GREEN}%s${NC}\n" "Deepening to a branch..."
  local upstream_remote upstream_refspec
  read -r upstream_remote upstream_refspec <<<"$(_git_deepen_upstream)"
  remote="${remote:-"${upstream_remote}"}"
  head_refspec="${head_refspec:-"${upstream_refspec}"}"
  if [ -z "${remote}" ] || [ -z "${head_refspec}" ]; then
    printf "${RED}%s${NC}\n" "Can not deepen: the remote or the refspec is neither given nor found in the upstream of HEAD."
    return 1
  fi
  if [ -z "${branch}" ]; then
    printf "${RED}%s${NC}\n" "Can not deepen: the branch is not given."
    return 1
  fi
  readonly remote head_refspec
  local -r tracking_ref="refs/remotes/${remote}/${branch}"
  local -r branch_refspec="refs/heads/${branch}:${tracking_ref}"
  printf "%s\n" "- remote: ${remote}"
  printf "%s\n" "- refspec: ${head_refspec}"
  printf "%s\n" "- branch: ${branch}"

  local tip
  tip="$(git ls-remote "${remote}" "refs/heads/${branch}" | cut -f 1)"
  if [ -z "${tip}" ]; then
    printf "${RED}%s${NC}\n" "Can not deepen: the branch is not found on the remote."
    return 1
  fi
  if git cat-file -e "${tip}^{commit}" 2>/dev/null; then
    # The tip is already here, so only the ref is missing. A fetch with
    # --depth would mark the tip as shallow and cut the history of HEAD below it.
    git update-ref "${tracking_ref}" "${tip}"
  elif [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    # The tip is a new commit, so with --depth 1 only that commit becomes
    # shallow and the history of HEAD stays as it is.
    git fetch --no-tags --depth 1 "${remote}" "${branch_refspec}"
  else
    git fetch --no-tags "${remote}" "${branch_refspec}"
  fi

  # Both histories are deepened, since the fork point can be missing on either
  # side.
  local step=10
  local round=0
  while true; do
    if git merge-base HEAD "${tracking_ref}" >/dev/null 2>&1; then
      printf "%s\n" "- found merge base: $(git merge-base HEAD "${tracking_ref}")"
      printf "%s\n" ""
      return 0
    fi
    if [ "$(git rev-parse --is-shallow-repository)" != "true" ]; then
      printf "${YELLOW}%s${NC}\n" "- no common history with HEAD"
      printf "%s\n" ""
      return 0
    fi
    round=$((round + 1))
    if [ "${round}" -gt "${max_rounds}" ]; then
      printf "%s\n" "- fetching the full history"
      git fetch --no-tags --unshallow "${remote}" "${head_refspec}" "${branch_refspec}"
    else
      printf "%s\n" "- deepening by ${step} commits"
      git fetch --no-tags --deepen "${step}" "${remote}" "${head_refspec}" "${branch_refspec}"
      step=$((step * 2))
    fi
  done
}
# source "${_SHELL_GR_DIR}/lib/git_deepen.bash" # git_deepen_to_branch, git_deepen_to_tag # END
# source "${_SHELL_GR_DIR}/lib/github.bash"     # github_authorized_repo_url # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

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
# source "${_SHELL_GR_DIR}/lib/github.bash"     # github_authorized_repo_url # END

# $1 - dest
git_checkout_advanced() {
  local -r input_DEBUG="${GR_GITCO__DEBUG:-}"
  local -r input_DEBUG_GIT="${GR_GITCO__DEBUG_GIT:-}"
  local -r input_DEPTH="${GR_GITCO__DEPTH:-}"
  local -r input_DEPTH_FOR_SUBMODULES="${GR_GITCO__DEPTH_FOR_SUBMODULES:-}"
  local -r input_DEPTH_UNTIL_BRANCH="${GR_GITCO__DEPTH_UNTIL_BRANCH:-}"
  local -r input_DEPTH_UNTIL_TAG="${GR_GITCO__DEPTH_UNTIL_TAG:-}"
  local -r input_DEST_DIR="${GR_GITCO__DEST_DIR:-}"
  local -r input_ENABLED_LFS="${GR_GITCO__ENABLED_LFS:-}"
  local -r input_ENABLED_SUBMODULES="${GR_GITCO__ENABLED_SUBMODULES:-}"
  local -r input_GITHUB_TOKEN="${GR_GITCO__GITHUB_TOKEN:-}"
  local -r input_REMOTE_NAME="${GR_GITCO__REMOTE_NAME:-}"
  local -r input_REPO_BRANCH="${GR_GITCO__REPO_BRANCH:-}"
  local -r input_REPO_SHA1="${GR_GITCO__REPO_SHA1:-}"
  local -r input_REPO_TAG="${GR_GITCO__REPO_TAG:-}"
  local -r input_REPO_URL="${GR_GITCO__REPO_URL:-}"

  local -r debug="${input_DEBUG}"
  local -r debug_git="${input_DEBUG_GIT}"
  local -r depth="${input_DEPTH}"
  local -r depth_for_submodules="${input_DEPTH_FOR_SUBMODULES}"
  local -r depth_until_branch="${input_DEPTH_UNTIL_BRANCH}"
  local -r depth_until_tag="${input_DEPTH_UNTIL_TAG}"
  local -r dest="${input_DEST_DIR}"
  local -r enabled_lfs="${input_ENABLED_LFS}"
  local -r enabled_submodules="${input_ENABLED_SUBMODULES}"
  local -r github_token="${input_GITHUB_TOKEN}"
  local -r remote_name="${input_REMOTE_NAME:-"origin"}"
  local -r repo_branch="${input_REPO_BRANCH}"
  local -r repo_sha1="${input_REPO_SHA1}"
  local -r repo_tag="${input_REPO_TAG}"
  local repo_url
  repo_url="$(github_authorized_repo_url "${input_REPO_URL}" "${github_token}")"
  if [[ "${repo_url}" != "${input_REPO_URL}" ]]; then
    printf "${GREEN}%s${NC}\n" "Detected GitHub token. Update:"
    printf "%s\n" "- repo_url: ${repo_url}"
  fi
  readonly repo_url

  # To facilitate cloning shallow repo for branch, tag or particular sha,
  # we don't use `git clone`, but combination of `git init` & `git fetch`.
  printf "${GREEN}%s${NC}\n" "Establishing git repo..."
  printf "%s\n" "- repo_url: ${repo_url}"
  printf "%s\n" "- remote_name: ${remote_name}"
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
  [ "${enabled_lfs}" = 1 ] && git lfs install --skip-smudge
  # --skip-smudge

  if is_git_repository_root_dir; then
    git remote set-url "${remote_name}" "${repo_url}"
  else
    git init
    git remote add "${remote_name}" "${repo_url}"
  fi
  [ "${enabled_lfs}" = 1 ] && git lfs install --local --skip-smudge
  if [ "${debug_git}" = 1 ]; then
    if [ "${enabled_lfs}" = 1 ]; then
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
    git fetch "${fetch_params[@]}" "${remote_name}" "refs/tags/${repo_tag}:refs/tags/${repo_tag}"
    git -c advice.detachedHead=false checkout --force "${repo_tag}"
    git reset --hard "${repo_sha1}"
  elif [ -n "${repo_branch}" ] && [ -n "${repo_sha1}" ]; then
    printf "${GREEN}%s${NC}\n" "Fetching & checking out branch..."
    DEBUG="${debug}" \
      TMP__FETCH_PARAMS_SERIALIZED="${fetch_params_serialized}" \
      TMP__REMOTE="${remote_name}" \
      TMP__REFSPEC="refs/heads/${repo_branch}:refs/remotes/${remote_name}/${repo_branch}" \
      TMP__BRANCH="${repo_branch}" \
      TMP__SHA1="${repo_sha1}" \
      bash "${fetch_repo_script}"
    # Submodules with relative URLs and Git LFS find the remote through the
    # upstream of the current branch, and fall back to "origin" without one.
    git branch --set-upstream-to="${remote_name}/${repo_branch}" "${repo_branch}"
  else
    printf "${RED}%s${NC}\n" "Missing coordinates to clone the repository."
    printf "${RED}%s${NC}\n" "Need to specify REPO_TAG to fetch by tag or REPO_BRANCH and REPO_SHA1 to fetch by branch."
    exit 1
  fi
  local deepen_refspec="refs/heads/${repo_branch}:refs/remotes/${remote_name}/${repo_branch}"
  [ -n "${repo_tag}" ] && deepen_refspec="refs/tags/${repo_tag}:refs/tags/${repo_tag}"
  if [ -n "${depth_until_tag}" ]; then
    GR_GITDEEPEN__REMOTE="${remote_name}" \
      GR_GITDEEPEN__REFSPEC="${deepen_refspec}" \
      GR_GITDEEPEN__TAG_REGEX="${depth_until_tag}" \
      git_deepen_to_tag || exit 1
  fi
  if [ -n "${depth_until_branch}" ]; then
    GR_GITDEEPEN__REMOTE="${remote_name}" \
      GR_GITDEEPEN__REFSPEC="${deepen_refspec}" \
      GR_GITDEEPEN__BRANCH="${depth_until_branch}" \
      git_deepen_to_branch || exit 1
  fi
  submodule_update_params=("--init" "--recursive")
  [ "${depth_for_submodules}" -ne -1 ] && submodule_update_params+=("--depth" "${depth_for_submodules}")
  [ "${enabled_submodules}" = 1 ] && git submodule update "${submodule_update_params[@]}"
  if [ "${enabled_lfs}" = 1 ]; then
    git lfs pull "${remote_name}"
    if [ "${enabled_submodules}" = 1 ]; then
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
DEBUG=${DEBUG:-0}
[ "${DEBUG}" = 1 ] && set -x

GREEN=$(printf '\033[32m')
RED=$(printf '\033[31m')
YELLOW=$(printf '\033[33m')
NC=$(printf '\033[0m')

fetch_repo() {
  local -r fetch_params_serialized="${TMP__FETCH_PARAMS_SERIALIZED}"
  local -r remote="${TMP__REMOTE}"
  local -r refspec="${TMP__REFSPEC}"
  local -r branch="${TMP__BRANCH}"
  local -r sha1="${TMP__SHA1}"

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
  git fetch "${fetch_params[@]}" "${remote}" "${refspec}"

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
        git fetch --deepen 10 "${remote}"
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
        git fetch --unshallow "${remote}"
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

fetch_repo
EOF
  echo "${fetch_repo_script}"
}
# source "${SHELL_GR_DIR}/lib/git_checkout_advanced.bash" # git_checkout_advanced # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/git_lfs.bash
# source "${SHELL_GR_DIR}/lib/git_lfs.bash" # setup_git_lfs # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
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
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/normalize.bash
# source "${SHELL_GR_DIR}/lib/normalize.bash" # GR_NORMALIZE__normalize # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/log.bash" # log_debug # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
# source "${_SHELL_GR_DIR}/lib/color.bash" # NC, RED, YELLOW, is_color # SKIPPED
# source "${_SHELL_GR_DIR}/lib/debug.bash" # is_debug # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Debug disabled by default
DEBUG=${DEBUG:-0}

is_debug() {
  case "${DEBUG}" in
    1 | "true") return 0 ;; # true
    *) return 1 ;;          # false
  esac
}
# source "${_SHELL_GR_DIR}/lib/debug.bash" # is_debug # END

# Expected env vars for log functions:
# COLOR - to enable/disable colors
# DEBUG - to enable/disable debug logs
# PREFIX - log prefix

__LOG_PREFIX="${LOG_PREFIX:-}"

# shellcheck disable=SC2059
log_error_f() {
  if is_color; then
    printf "${RED}${__LOG_PREFIX}${1}${NC}" "${@:2}"
  else
    printf "$@"
  fi
}

log_error() {
  log_error_f "%s\n" "$@"
}

# shellcheck disable=SC2059
log_warning_f() {
  if is_color; then
    printf "${YELLOW}${__LOG_PREFIX}${1}${NC}" "${@:2}"
  else
    printf "$@"
  fi
}

log_warning() {
  log_warning_f "%s\n" "$@"
}

log_info_f() {
  # shellcheck disable=SC2059
  printf "${__LOG_PREFIX}${1}" "${@:2}"
}

log_info() {
  log_info_f "${__LOG_PREFIX}%s\n" "$@"
}

log_debug_f() {
  if is_debug; then
    # shellcheck disable=SC2059
    printf "${__LOG_PREFIX}${1}" "${@:2}"
  fi
}

log_debug() {
  log_debug_f "%s\n" "$@"
}
# source "${_SHELL_GR_DIR}/lib/log.bash" # log_debug # END

# Recovers builtin cd if it is overridden
GR_NORMALIZE__recover_builtin_cd() {
  if declare -f cd >/dev/null; then
    unset -f cd
    log_debug "Reverted cd to its builtin behavior."
  fi
}

# Normalizes the environment.
GR_NORMALIZE__normalize() {
  GR_NORMALIZE__recover_builtin_cd
}
# source "${SHELL_GR_DIR}/lib/normalize.bash" # GR_NORMALIZE__normalize # END
# shellcheck source=.github_deps/rynkowsg/shell-gr@v0.9.0/lib/ssh.bash
# source "${SHELL_GR_DIR}/lib/ssh.bash" # setup_ssh # BEGIN
#!/usr/bin/env bash
# Copyright (c) 2024-2026 Greg Rynkowski. All rights reserved.
# License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
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
  DEPTH_FOR_SUBMODULES=${PARAM_DEPTH_FOR_SUBMODULES:--1}
  # DEPTH_UNTIL_BRANCH - base branch to deepen to, if not specified, no deepening
  DEPTH_UNTIL_BRANCH=${PARAM_DEPTH_UNTIL_BRANCH:-${DEPTH_UNTIL_BRANCH:-}}
  # DEPTH_UNTIL_TAG - regex of the tag to deepen to, if not specified, no deepening
  DEPTH_UNTIL_TAG=${PARAM_DEPTH_UNTIL_TAG:-${DEPTH_UNTIL_TAG:-}}

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

  # REMOTE_NAME - name of the remote, if not specified, set to origin
  REMOTE_NAME=${PARAM_REMOTE_NAME:-${REMOTE_NAME:-"origin"}}

  # ENABLED_SUBMODULES - submodules support, if not specified, set to false
  ENABLED_SUBMODULES=${PARAM_WITH_SUBMODULES:-${ENABLED_SUBMODULES:-0}}

  # ENABLED_LFS - Git LFS support, if not specified, set to false
  ENABLED_LFS=${PARAM_WITH_LFS:-${ENABLED_LFS:-0}}

  printf "${GREEN}%s${NC}\n" "Checkout vars:"
  printf "%s\n" "- DEPTH=${DEPTH}"
  printf "%s\n" "- DEPTH_FOR_SUBMODULES=${DEPTH_FOR_SUBMODULES}"
  printf "%s\n" "- DEPTH_UNTIL_BRANCH=${DEPTH_UNTIL_BRANCH}"
  printf "%s\n" "- DEPTH_UNTIL_TAG=${DEPTH_UNTIL_TAG}"
  printf "%s\n" "- DEST_DIR=${DEST_DIR}"
  printf "%s\n" "- ENABLED_LFS=${ENABLED_LFS}"
  printf "%s\n" "- ENABLED_SUBMODULES=${ENABLED_SUBMODULES}"
  printf "%s\n" "- GITHUB_TOKEN=${GITHUB_TOKEN}"
  printf "%s\n" "- REMOTE_NAME=${REMOTE_NAME}"
  printf "%s\n" "- REPO_BRANCH=${REPO_BRANCH}"
  printf "%s\n" "- REPO_SHA1=${REPO_SHA1}"
  printf "%s\n" "- REPO_TAG=${REPO_TAG}"
  printf "%s\n" "- REPO_URL=${REPO_URL}"
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
  GR_NORMALIZE__normalize

  print_common_debug_info "$@"
  init_input_vars_debug
  init_input_vars_ssh
  init_input_vars_checkout

  setup_git_lfs "${ENABLED_LFS}"

  GR_SSH__CHECKOUT_KEY="${CHECKOUT_KEY}" \
    GR_SSH__CHECKOUT_KEY_PUBLIC="${CHECKOUT_KEY_PUBLIC}" \
    GR_SSH__DEBUG_SSH="${DEBUG_SSH}" \
    GR_SSH__SSH_CONFIG_DIR="${SSH_CONFIG_DIR}" \
    GR_SSH__SSH_PRIVATE_KEY_B64="${SSH_PRIVATE_KEY_B64}" \
    GR_SSH__SSH_PRIVATE_KEY_PATH="${SSH_PRIVATE_KEY_PATH}" \
    GR_SSH__SSH_PUBLIC_KEY_B64="${SSH_PUBLIC_KEY_B64}" \
    GR_SSH__SSH_PUBLIC_KEY_PATH="${SSH_PUBLIC_KEY_PATH}" \
    setup_ssh

  GR_GITCO__DEBUG="${DEBUG}" \
    GR_GITCO__DEBUG_GIT="${DEBUG_GIT}" \
    GR_GITCO__DEPTH="${DEPTH}" \
    GR_GITCO__DEPTH_FOR_SUBMODULES="${DEPTH_FOR_SUBMODULES}" \
    GR_GITCO__DEPTH_UNTIL_BRANCH="${DEPTH_UNTIL_BRANCH}" \
    GR_GITCO__DEPTH_UNTIL_TAG="${DEPTH_UNTIL_TAG}" \
    GR_GITCO__DEST_DIR="${DEST_DIR}" \
    GR_GITCO__ENABLED_LFS="${ENABLED_LFS}" \
    GR_GITCO__ENABLED_SUBMODULES="${ENABLED_SUBMODULES}" \
    GR_GITCO__GITHUB_TOKEN="${GITHUB_TOKEN}" \
    GR_GITCO__REMOTE_NAME="${REMOTE_NAME}" \
    GR_GITCO__REPO_BRANCH="${REPO_BRANCH}" \
    GR_GITCO__REPO_SHA1="${REPO_SHA1}" \
    GR_GITCO__REPO_TAG="${REPO_TAG}" \
    GR_GITCO__REPO_URL="${REPO_URL}" \
    git_checkout_advanced
}

if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]] || [[ "${CIRCLECI}" == "true" ]]; then
  main "$@"
else
  printf "%s\n" "Loaded: ${BASH_SOURCE[0]:-}"
fi
