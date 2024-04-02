.PHONY: deps _format_deps format format-check _lint_deps lint

deps:
	sosh fetch src/scripts/clone_git_repo.bash

_format_deps: @bin/format.bash
	sosh fetch @bin/format.bash

format-check: _format_deps
	\@bin/format.bash check

format: _format_deps
	\@bin/format.bash apply

_lint_deps: @bin/lint.bash
	sosh fetch @bin/lint.bash

lint: _format_deps _lint_deps deps
	\@bin/lint.bash
