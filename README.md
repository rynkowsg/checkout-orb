# [checkout-orb][orb-page]

[![CircleCI Build Status][badge-orb-build-status]][orb-pipeline]
[![CircleCI Orb Version][badge-orb-version]][orb-page]
[![License][badge-license]][orb-license]
[![CircleCI Community][badge-orbs-discuss]][orbs-discuss]

CircleCI orb for advanced checkouts.

## Motivation

The standard `checkout` command is good for basic stuff, but when you need to do more, it can get tricky.
This orb makes those tricky things easier.

What it does:

- Supports shallow clones, so you can
  - grab just the latest commit if that's all you need, or
  - get the last few commits, depending on what you need.

- Works with LFS (Large File Storage), so you can:
  - get LFS files in your repo, or
  - choose not to get LFS files if you don't need them.

- Helps with submodules in a couple of ways:
  - you can clone repos that have submodules,
  - you can also clone repos without bringing along the submodules.

- Lets you use your own SSH keys.

- Supports running job locally on your machine.

- Supports usage of GitHub token for fetching public repositories.


## Quickstart

The simplest possible case includes replacement of `checkout` to `checkout-orb/checkout`.

```yaml
version: '2.1'

orbs:
  checkout-orb: rynkowsg/checkout-orb@0.1.4

jobs:
  test:
    docker: [{image: "cimg/base:stable"}]
    steps:
      - checkout-orb/checkout

workflows:
  main-workflow:
    jobs:
      - test
```

## Usage

### Shallow clone

```yaml
jobs:
  test:
    steps:
      - checkout-orb/checkout:
          depth: 1
```
Setting `depth: 1` will clone only the top commit whether checking out the branch or a tag.

### Clone with LFS support

```yaml
jobs:
  test:
    steps:
      - checkout-orb/checkout:
          lfs: true
```

### Clone with submodules

```yaml
jobs:
  test:
    steps:
      - checkout-orb/checkout:
          submodules: true
```

### Clone additional repository

```yaml
jobs:
  test:
    # ...
    steps:
      - checkout-orb/checkout
      - checkout-orb/checkout:
          repo_url: "https://github.com/rynkowsg/test-clone-repo-l0.git"
          repo_branch: "master"
          repo_sha1: "f731330"
          dest_dir: /tmp/test-clone
```
In this case, we first clone the current repository, and then additional one to given destination.

> **WARNING:** If the `dest_dir` is not provided, the command will fail because both will try to clone the repo to the default location `~/project`.


### Authenticate with GitHub token

If GitHub token is available all HTTPS clones uses it.
It can be provided by:
- command param `github-token` or
- in environment variable `GITHUB_TOKEN`.

### Authenticate with custom SSH identity

The SSH identity provided by default in CircleCI job allows only to fetch the current repository.
Some scenarios when it is problematic includes:
- when you fetch private repo other than current,
- you employ submodules in your repository from which some are private.

In such a case you need to provide additional SSH identity with access for given repository.
Either via CircleCI dashboard or with environment variables.
It can be done by providing one of two environment variables:
- `CHECKOUT_KEY` - private key in plain text
- `SSH_PRIVATE_KEY_B64` - private key in base64.

---

For more guidelines and examples, see the [orb registry listing][orb-page].

## Contributing

I welcome [issues][gh-issues] to and [pull requests][gh-pulls] against this repository!

## More

- [troubleshooting](./docs/troubleshooting.md)
- [testing](./docs/testing.md)
- [todo](./docs/todo.md)

## Similar projects

- https://github.com/guitarrapc/git-shallow-clone-orb
- https://github.com/issmirnov/fast-checkout-orb
- https://github.com/vsco/advanced-checkout-orb

## License

Copyright © 2024 Greg Rynkowski

Released under the [MIT license][orb-license].

[badge-license]: https://img.shields.io/badge/license-MIT-lightgrey.svg
[badge-orb-build-status]: https://circleci.com/gh/rynkowsg/checkout-orb.svg?style=shield "CircleCI Build Status"
[badge-orb-version]: https://badges.circleci.com/orbs/rynkowsg/checkout-orb.svg
[badge-orbs-discuss]: https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg
[gh-issues]: https://github.com/rynkowsg/checkout-orb/issues
[gh-pulls]: https://github.com/rynkowsg/checkout-orb/pulls
[orb-license]: https://raw.githubusercontent.com/rynkowsg/checkout-orb/master/LICENSE
[orb-page]: https://circleci.com/developer/orbs/orb/rynkowsg/checkout-orb
[orb-pipeline]: https://circleci.com/gh/rynkowsg/checkout-orb
[orbs-discuss]: https://discuss.circleci.com/c/ecosystem/orbs
