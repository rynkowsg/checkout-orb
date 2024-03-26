.PHONY: deps _format_deps format format-check _lint_deps lint

deps:
	shellpack fetch src/scripts/clone_git_repo.bash

_format_deps: @bin/format.bash
	shellpack fetch @bin/format.bash

format-check: _format_deps
	\@bin/format.bash check

format: _format_deps
	\@bin/format.bash apply

_lint_deps: @bin/lint.bash
	shellpack fetch @bin/lint.bash

lint: _format_deps _lint_deps deps
	\@bin/lint.bash
