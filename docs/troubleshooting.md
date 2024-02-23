# troubleshooting

## `git-lfs: api error: Bad credentials`

when we enter submodule, we two things: initialze lfs and pull
```
Entering 'sample-repo-l1-lfs'
17:02:49.620848 run-command.c:659       trace: run_command: cd sample-repo-l1-lfs; unset GIT_PREFIX; GIT_DIR=.git displaypath=sample-repo-l1-lfs name=sample-repo-l1-lfs sha1=4f6db90aecdd0ee0707668b34dbd5d1573986300 sm_path=sample-repo-l1-lfs toplevel=/tmp/sample-repo-l0-lfs 'path='\''sample-repo-l1-lfs'\''; [ -f .gitattributes ] && grep -q "filter=lfs" .gitattributes && git lfs install --local --skip-smudge && git lfs pull || echo "Skipping submodule without LFS or .gitattributes"'
```

The initilize part is not that much important
```
17:02:49.623700 git.c:749               trace: exec: git-lfs install --local --skip-smudge
17:02:49.623737 run-command.c:659       trace: run_command: git-lfs install --local --skip-smudge
17:02:49.627298 trace git-lfs: exec: git 'version'
17:02:49.628822 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'rev-parse' '--git-dir' '--show-toplevel'
17:02:49.630150 trace git-lfs: exec: git 'rev-parse' '--is-bare-repository'
17:02:49.631534 trace git-lfs: exec: git 'config' '--includes' '--local' 'lfs.repositoryformatversion'
17:02:49.632756 trace git-lfs: exec: git 'config' '--includes' '--local' 'filter.lfs.smudge'
17:02:49.633848 trace git-lfs: exec: git 'config' '--includes' '--replace-all' 'filter.lfs.smudge' 'git-lfs smudge --skip -- %f'
17:02:49.635728 trace git-lfs: exec: git 'config' '--includes' '--local' 'filter.lfs.process'
17:02:49.636898 trace git-lfs: exec: git 'config' '--includes' '--replace-all' 'filter.lfs.process' 'git-lfs filter-process --skip'
17:02:49.638308 trace git-lfs: exec: git 'config' '--includes' '--local' 'filter.lfs.required'
17:02:49.639525 trace git-lfs: exec: git 'config' '--includes' '--replace-all' 'filter.lfs.required' 'true'
17:02:49.641261 trace git-lfs: exec: git 'config' '--includes' '--local' 'filter.lfs.clean'
17:02:49.642352 trace git-lfs: exec: git 'config' '--includes' '--replace-all' 'filter.lfs.clean' 'git-lfs clean -- %f'
17:02:49.643719 trace git-lfs: exec: git 'rev-parse' '--is-bare-repository'
17:02:49.645010 trace git-lfs: exec: git 'config' '--includes' '--local' 'lfs.repositoryformatversion'
17:02:49.646173 trace git-lfs: exec: git 'config' '--includes' '-l'
17:02:49.647456 trace git-lfs: exec: git 'rev-parse' '--is-bare-repository'
17:02:49.668822 trace git-lfs: exec: git 'config' '--includes' '-l' '--blob' ':.lfsconfig'
17:02:49.670430 trace git-lfs: exec: git 'config' '--includes' '-l' '--blob' 'HEAD:.lfsconfig'
17:02:49.672157 trace git-lfs: Install hook: pre-push, force=false, path=/tmp/sample-repo-l0-lfs/.git/modules/sample-repo-l1-lfs/hooks/pre-push, upgrading...
17:02:49.672211 trace git-lfs: Install hook: post-checkout, force=false, path=/tmp/sample-repo-l0-lfs/.git/modules/sample-repo-l1-lfs/hooks/post-checkout, upgrading...
17:02:49.672245 trace git-lfs: Install hook: post-commit, force=false, path=/tmp/sample-repo-l0-lfs/.git/modules/sample-repo-l1-lfs/hooks/post-commit, upgrading...
17:02:49.672279 trace git-lfs: Install hook: post-merge, force=false, path=/tmp/sample-repo-l0-lfs/.git/modules/sample-repo-l1-lfs/hooks/post-merge, upgrading...
Updated Git hooks.
Git LFS initialized.
```

What is important is what follows, pull part:
```
17:02:49.672330 trace git-lfs: filepathfilter: creating pattern ".git" of type gitignore
17:02:49.672340 trace git-lfs: filepathfilter: creating pattern "**/.git" of type gitignore
17:02:49.672381 trace git-lfs: filepathfilter: accepting "tmp"
17:02:49.674631 git.c:749               trace: exec: git-lfs pull
17:02:49.674665 run-command.c:659       trace: run_command: git-lfs pull
17:02:49.678071 trace git-lfs: exec: git 'version'
17:02:49.679502 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'rev-parse' '--git-dir' '--show-toplevel'
17:02:49.681065 trace git-lfs: exec: git 'rev-parse' '--is-bare-repository'
17:02:49.682384 trace git-lfs: exec: git 'config' '--includes' '--local' 'lfs.repositoryformatversion'
17:02:49.683719 trace git-lfs: exec: git 'config' '--includes' '-l'
17:02:49.685137 trace git-lfs: exec: git 'rev-parse' '--is-bare-repository'
17:02:49.686444 trace git-lfs: exec: git 'config' '--includes' '-l' '--blob' ':.lfsconfig'
17:02:49.687902 trace git-lfs: exec: git 'config' '--includes' '-l' '--blob' 'HEAD:.lfsconfig'
17:02:49.689570 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'rev-parse' 'HEAD' '--symbolic-full-name' 'HEAD'
17:02:49.690919 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'rev-parse' 'HEAD' '--symbolic-full-name' 'HEAD'
17:02:49.692287 trace git-lfs: tq: running as batched queue, batch size of 100
17:02:49.692459 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'ls-tree' '-r' '-l' '-z' '--full-tree' '4f6db90aecdd0ee0707668b34dbd5d1573986300'
17:02:49.692749 trace git-lfs: exec: git '-c' 'filter.lfs.smudge=' '-c' 'filter.lfs.clean=' '-c' 'filter.lfs.process=' '-c' 'filter.lfs.required=false' 'rev-parse' '--git-common-dir'
17:02:49.693905 trace git-lfs: filepathfilter: accepting ".gitattributes"
17:02:49.693936 trace git-lfs: filepathfilter: accepting ".gitmodules"
17:02:49.693940 trace git-lfs: filepathfilter: accepting "README.md"
17:02:49.693942 trace git-lfs: filepathfilter: accepting "lfs-file.ltxt"
17:02:49.693946 trace git-lfs: filepathfilter: accepting "regular-file.txt"
17:02:49.694751 trace git-lfs: fetch lfs-file.ltxt [43bfaf28b5a3aca98d196aa1d2a7f6a19c080e51df1c87c4428ba5d7d90b3c17]
17:02:49.694831 trace git-lfs: attempting pure SSH protocol connection
17:02:49.694843 trace git-lfs: spawning pure SSH connection
17:02:49.695004 trace git-lfs: run_command: sh -c ssh -v -i /tmp/clone_git_repo-ssh-20240215_170243-yiN/id -o UserKnownHostsFile="/tmp/clone_git_repo-ssh-20240215_170243-yiN/known_hosts" '-oControlMaster=auto' '-oControlPath=/tmp/sock-3824174181/sock-%C' git@github.com 'git-lfs-transfer rynkowsg/rynkowsg-orb-sample-repo-l1.git download'
17:02:49.695185 trace git-lfs: exec: sh '-c' 'ssh -v -i /tmp/clone_git_repo-ssh-20240215_170243-yiN/id -o UserKnownHostsFile="/tmp/clone_git_repo-ssh-20240215_170243-yiN/known_hosts" '-oControlMaster=auto' '-oControlPath=/tmp/sock-3824174181/sock-%C' git@github.com 'git-lfs-transfer rynkowsg/rynkowsg-orb-sample-repo-l1.git download''
17:02:50.170277 trace git-lfs: pure SSH connection successful
17:02:50.170289 trace git-lfs: pure SSH protocol connection failed: Unable to negotiate version with remote side (unable to read capabilities): EOF
17:02:50.170505 trace git-lfs: tq: sending batch of size 1
17:02:50.170591 trace git-lfs: run_command: sh -c ssh -v -i /tmp/clone_git_repo-ssh-20240215_170243-yiN/id -o UserKnownHostsFile="/tmp/clone_git_repo-ssh-20240215_170243-yiN/known_hosts" git@github.com 'git-lfs-authenticate rynkowsg/rynkowsg-orb-sample-repo-l1.git download'
17:02:50.170661 trace git-lfs: exec: sh '-c' 'ssh -v -i /tmp/clone_git_repo-ssh-20240215_170243-yiN/id -o UserKnownHostsFile="/tmp/clone_git_repo-ssh-20240215_170243-yiN/known_hosts" git@github.com 'git-lfs-authenticate rynkowsg/rynkowsg-orb-sample-repo-l1.git download''
```
At first we see that `pure SSH connection successful`.

Running command like the one above:
```
ssh -v -i /tmp/clone_git_repo-ssh-20240215_170243-yiN/id -o UserKnownHostsFile="/tmp/clone_git_repo-ssh-20240215_170243-yiN/known_hosts" git@github.com 'git-lfs-authenticate rynkowsg/rynkowsg-orb-sample-repo-l1.git download'
```
we succeed and get credentials used later by curl.

But curl fails:
```
17:02:50.629659 trace git-lfs: api: batch 1 files
17:02:50.630120 trace git-lfs: HTTP: POST https://lfs.github.com/rynkowsg/rynkowsg-orb-sample-repo-l1/objects/batch
> POST /rynkowsg/rynkowsg-orb-sample-repo-l1/objects/batch HTTP/1.1
> Host: lfs.github.com
> Accept: application/vnd.git-lfs+json
> Authorization: RemoteAuth gitauth-v1-guj25Dt7HKnuvh2zChru4bSolsF9sBfPVZ7D6S0KaxdnnXQlaZLOZc5GEoOmbWVtYmVy2gAzcmVwbzo3NTY5MjA4OTE6cnlua293c2cvcnlua293c2ctb3JiLXNhbXBsZS1yZXBvLWwxpXByb3Rvo3NzaKpkZXBsb3lfa2V5zgWoV18
> Content-Length: 214
> Content-Type: application/vnd.git-lfs+json; charset=utf-8
> Github-Deploy-Key: 94918495
> User-Agent: git-lfs/3.4.0 (GitHub; linux amd64; go 1.20.6)
>
{"operation":"download","objects":[{"oid":"43bfaf28b5a3aca98d196aa1d2a7f6a19c080e51df1c87c4428ba5d7d90b3c17","size":26}],"transfers":["lfs-standalone-file","basic","ssh"],"ref":{"name":"HEAD"},"hash_algo":"sha256"}17:02:50.758658 trace git-lfs: http: decompressed gzipped response
17:02:50.758679 trace git-lfs: HTTP: 403


< HTTP/2.0 403 Forbidden
< Access-Control-Allow-Origin: *
< Access-Control-Expose-Headers: ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset
< Content-Security-Policy: default-src 'none'
< Content-Type: application/json; charset=utf-8
< Date: Thu, 15 Feb 2024 17:02:50 GMT
< Referrer-Policy: origin-when-cross-origin, strict-origin-when-cross-origin
< Request-Hmac: 1708016570.909c288b7dd36f39cc15611885c91b87d26c82692fed9d42c3deb293e25c6cd9
< Server: GitHub.com
< Strict-Transport-Security: max-age=31536000; includeSubdomains; preload
< Vary: Accept-Encoding, Accept, X-Requested-With
< X-Content-Type-Options: nosniff
< X-Frame-Options: deny
< X-Github-Media-Type: unknown
< X-Github-Request-Id: BA22:0E01:3EBD150:7D9B446:65CE43BA
< X-Ratelimit-Limit: 100
< X-Ratelimit-Remaining: 98
< X-Ratelimit-Reset: 1708016629
< X-Ratelimit-Resource: lfs
< X-Ratelimit-Used: 2
< X-Xss-Protection: 0
<
17:02:50.758934 trace git-lfs: HTTP: {"message":"Bad credentials","documentation_url":"https://support.github.com/contact"}
{"message":"Bad credentials","documentation_url":"https://support.github.com/contact"}17:02:50.758990 trace git-lfs: api error: Bad credentials
batch response: Bad credentials
Failed to fetch some objects from 'https://github.com/rynkowsg/rynkowsg-orb-sample-repo-l1.git/info/lfs'
```

What I think?

I think the problem is because, despite its a public repository, only l0 uses https:// url.
The other two, l1 and l2 use git://.
l2 succeeds, but I guess only because I added to job context key added to l2 repo.

So for public repos, you either have to have all urls added by https://, add to context a SSH key that has access to all linked repos by ssh.

Some notes on git-lfs auth:
https://github.com/git-lfs/git-lfs/blob/main/docs/api/server-discovery.md

## `Failed to connect to github.com port 443 after 130477 ms: Connection timed out`

Example log:
```text
Fetching & checking out branch...
fatal: unable to access 'https://github.com/rynkowsg/test-clone-repo-l2.git/': Failed to connect to github.com port 443 after 130477 ms: Connection timed out
```

It is not entirely clear to me why I occasionally see these timeouts.
The orb supports github token, so if GITHUB_TOKEN is specified it is used with HTTPS requests
but from my observations it doesn't help much.
