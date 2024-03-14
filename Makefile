.PHONY: lint format-check format-apply format-update-patches

deps_format: @bin/format.bash
	shellpack fetch @bin/format.bash

deps_lint: @bin/lint.bash
	shellpack fetch @bin/lint.bash

deps_src:
	shellpack fetch src/scripts/clone_git_repo.bash

format: deps_format
	\@bin/format.bash check

format-apply: deps_format
	\@bin/format.bash apply

lint: deps_format deps_lint deps_src
	\@bin/lint.bash

# Since formatting doesn't allow to ignore some parts, I apply patches before and after formatting to overcome this.
# Here are commands to update these patches
format-update-patches:
	rm -f @bin/res/pre-format.patch @bin/res/post-format.patch
	WITH_PATCHES=0 @bin/format.bash apply
	git commit -a --no-gpg-sign -m "patch"
	git revert --no-commit HEAD
	git commit -a --no-gpg-sign -m "patch revert"
	git diff HEAD~2..HEAD~1 > @bin/res/pre-format.patch
	git diff HEAD~1..HEAD > @bin/res/post-format.patch
	git reset HEAD~2
	\[ -f @bin/res/pre-format.patch \] && git add @bin/res/pre-format.patch
	\[ -f @bin/res/post-format.patch \] && git add @bin/res/post-format.patch
	git commit -m "ci: Update patches"
