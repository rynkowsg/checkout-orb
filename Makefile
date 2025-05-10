.PHONY: deps _format_shell_deps format_shell_check format_shell format_yaml_check format_yaml _lint_deps lint gen validate

deps:
	sosh fetch src/scripts/clone_git_repo.bash

_format_shell_deps: @bin/format.bash
	sosh fetch @bin/format.bash

format_shell_check: _format_shell_deps
	\@bin/format.bash check

format_shell: _format_shell_deps
	\@bin/format.bash apply

format_yaml_check:
	yamlfmt --lint .

format_yaml:
	yamlfmt .

_lint_deps: @bin/lint.bash
	sosh fetch @bin/lint.bash

lint: _format_shell_deps _lint_deps deps
	\@bin/lint.bash

gen: deps
	sosh pack -i src/scripts/clone_git_repo.bash -o src/scripts/gen/clone_git_repo.bash

validate:
	circleci orb pack ./src > /tmp/orb
	circleci orb validate /tmp/orb
