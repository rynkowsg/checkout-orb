# [checkout-orb][orb-info-docs]

[![CircleCI Build Status][orb-build-status]][orb-build-url]
[![CircleCI Orb Version][orb-info-version-svg]][orb-info-docs]
[![GitHub License][orb-license-svg]][orb-license]
[![CircleCI Community][orbs-discuss-svg]][orbs-discuss]

## Briefly

The sole purpose of this orb is doing advanced checkouts,
exceeding what can be done with default checkout.

Features:
- support for LFS, e.g.
  - fetch LFS files in repo using LFS
  - don't fetch LFS files in repo using LFS
- support for submodules, e.g.
  - clone repo with submodules
  - clone repo without submodules
- support using custom SSH key pair
- support for taking github token, e.g.
  - use github token for HTTPS connections
- support shallow clones
  - fetch last commit
  - fetch last N commits

## Usage

**Basic usage**

The simplest possible case includes replacement of `checkout` to `checkout-orb/checkout`.
```yaml
version: '2.1'

orbs:
  checkout-orb: rynkowsg/checkout-orb@0.1.0

jobs:
  test:
    docker: [{image: "cimg/base:2023.12"}]
    resource_class: small
    steps:
      - ...
      - checkout-orb/checkout
      - ...

workflows:
  main-workflow:
    jobs:
      - test
```

**Make shallow clone**

```yaml
jobs:
  test:
    # ...
    steps:
      - checkout-orb/checkout:
          depth: 1
```

**Clone with submodules**

```yaml
jobs:
  test:
    # ...
    steps:
      - checkout-orb/checkout:
          submodules: true
```

**Clone repository other than current**

```yaml
jobs:
  test:
    # ...
    steps:
      - checkout-orb/checkout:
          repo_url: "https://github.com/rynkowsg/test-clone-repo-l0.git"
          repo_branch: "master"
          repo_sha1: "f731330"

workflows:
  main-workflow:
    jobs:
      - test:
          context: [github-token]
```

If `github-token` context specifies `GITHUB_TOKEN`, the token is used on making HTTPS requests.


**Clone repository other than current, but private**

```yaml
jobs:
  test:
    # ...
    steps:
      - checkout-orb/checkout:
          repo_url: "git@github.com:rynkowsg/test-clone-repo-l0-priv.git"
          repo_branch: "master"
          repo_sha1: "f731330"

workflows:
  main-workflow:
    jobs:
      - test:
          context: [test-clone-priv]
```

By default CircleCI allows to fetch only current repository.
If you need fetch a private repository, e.g. one of your submodules, checkout would not work.
You need to provide an SSH identity with permissions to fetch all necessary repositories.
It can be done by providing one of two environment variables:
- `CHECKOUT_KEY` - private key in plain text
- `SSH_PRIVATE_KEY_B64` - private key in base64.

In this example one of them could be provided in `test-clone-priv` context.

---

For full usage guidelines, see the [orb registry listing][orb-info-docs].

## Contributing

I welcome [issues][gh-issues] to and [pull requests][gh-pulls] against this repository!

## Docs

- [troubleshooting](./docs/troubleshooting.md)

## License

Copyright © 2024 Greg Rynkowski

Released under the [MIT license][orb-license].

[gh-issues]: https://github.com/rynkowsg/checkout-orb/issues
[gh-pulls]: https://github.com/rynkowsg/checkout-orb/pulls
[orb-build-status]: https://circleci.com/gh/rynkowsg/checkout-orb.svg?style=shield "CircleCI Build Status"
[orb-build-url]: https://circleci.com/gh/rynkowsg/checkout-orb
[orb-info-docs]: https://circleci.com/developer/orbs/orb/rynkowsg/checkout-orb
[orb-info-version-svg]: https://badges.circleci.com/orbs/rynkowsg/checkout-orb.svg
[orb-license-svg]: https://img.shields.io/badge/license-MIT-lightgrey.svg
[orb-license]: https://raw.githubusercontent.com/rynkowsg/checkout-orb/master/LICENSE
[orbs-discuss-svg]: https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg
[orbs-discuss]: https://discuss.circleci.com/c/ecosystem/orbs
