#!/usr/bin/env bash
set -e

# Also set up gitconfig
echo 'Installing git config...'
git config --global log.date iso
git config --global grep.lineNumber true
git config --global core.editor /usr/bin/nvim
git config --global diff.algorithm patience
git config --global diff.renames copies
git config --global diff.noprefix true
git config --global diff.wsErrorHighlight all
git config --global difftool.prompt false
git config --global difftool.trustExitCode true
git config --global difftool.pdiff.cmd "pdiff -- \"\$LOCAL\" \"\$REMOTE\" | less -R"
git config --global fetch.prune true
git config --global pull.rebase true
git config --global push.default current
git config --global commit.gpgsign false
git config --global advice.statusHints false
git config --global advice.detachedHead false
git config --global color.status.branch cyan
git config --global pretty.compact "%C(auto)%h %C(blue)%ad %C(magenta)%aN%C(auto)%d %C(reset)%s"
git config --global alias.st status
git config --global alias.sts "status --short --branch"
git config --global alias.rp rev-parse
git config --global alias.rpa "rev-parse --abbrev-ref"
git config --global alias.br "branch"
git config --global alias.brv "branch --verbose --verbose"
git config --global alias.bra "branch --all"
git config --global alias.brav "branch --all --verbose --verbose"
git config --global alias.brm "branch --move"
git config --global alias.brmf "branch --move --force"
git config --global alias.brd "branch --delete"
git config --global alias.brdf "branch --delete --force"
git config --global alias.sb show-branch
git config --global alias.sba "show-branch --all"
git config --global alias.lg "log --pretty=compact --graph"
git config --global alias.lgo "log --pretty=compact --graph -n 1"
git config --global alias.lgm '!'"sh -c 'git log --pretty=compact --graph ^master \"\${@:-HEAD}\"' -"
git config --global alias.lgs "log --pretty=compact --graph --branches --simplify-by-decoration"
git config --global alias.lf "log --pretty=fuller --decorate"
git config --global alias.lfo "log --pretty=fuller --decorate -n 1"
git config --global alias.lfm '!'"sh -c 'git log --pretty=fuller --decorate ^master \"\${@:-HEAD}\"' -"
git config --global alias.rmc "rm --cached"
git config --global alias.rmcf "rm --cached --force"
git config --global alias.sh stash
git config --global alias.shl "stash list"
git config --global alias.shs "stash save"
git config --global alias.shw "stash show --patch"
git config --global alias.sha "stash apply"
git config --global alias.shp "stash pop"
git config --global alias.shd "stash drop"
git config --global alias.shc "stash clear"
git config --global alias.ci "commit"
git config --global alias.cia "commit --amend"
git config --global alias.ciar "commit --amend --reset-author"
git config --global alias.cian "commit --amend --no-edit"
git config --global alias.cianr "commit --amend --no-edit --reset-author"
git config --global alias.co checkout
# Checks out in a branch from the current HEAD
git config --global alias.cob "checkout -b"
git config --global alias.cobf "checkout -B"
git config --global alias.cod "checkout --detach"
git config --global alias.com "checkout master"
git config --global alias.cor '!'"sh -c 'git checkout -B \"\${1:?unset}\" \"origin/$1\"' -"
git config --global alias.corm "checkout -B master origin/master"
git config --global alias.hard '!'"sh -c 'git reset --hard \"\${@:-HEAD}\"' -"
git config --global alias.soft '!'"sh -c 'git reset --soft \"\${@:-HEAD}\"' -"
git config --global alias.cp cherry-pick
git config --global alias.cpc "cherry-pick --continue"
git config --global alias.cpa "cherry-pick --abort"
git config --global alias.fe fetch
git config --global alias.fet "fetch --tags"
git config --global alias.fea "fetch --all"
git config --global alias.feat "fetch --all --tags"
git config --global alias.rb rebase
git config --global alias.rbm "rebase master"
git config --global alias.rbi "rebase --interactive"
git config --global alias.rbim "rebase --interactive master"
git config --global alias.rbc "rebase --continue"
git config --global alias.rbs "rebase --skip"
git config --global alias.rba "rebase --abort"
git config --global alias.df diff
git config --global alias.dfc "diff --cached"
git config --global alias.dfo '!'"sh -c 'git diff \"\${1:-HEAD}\"~ \"\${@:-HEAD}\"' -"
git config --global alias.dfs "diff --stat"
git config --global alias.dfsc "diff --stat --cached"
git config --global alias.dfso '!'"sh -c 'git diff --stat \"\${1:-HEAD}\"~ \"\${@:-HEAD}\"' -"
git config --global alias.dfsm '!'"sh -c 'git diff --stat \"\$(git merge-base master \"\${1:-HEAD}\")\" \"\${@:-HEAD}\"' -"
git config --global alias.dfp "difftool --tool=pdiff"
git config --global alias.dfpc "difftool --tool=pdiff --cached"
git config --global alias.dfpo '!'"sh -c 'git difftool --tool=pdiff \"\${1:-HEAD}\"~ \"\${@:-HEAD}\"' -"
git config --global alias.dfpm '!'"sh -c 'git difftool --tool=pdiff \$(git merge-base master \"\${1:-HEAD}\")\" \"\${@:-HEAD}\"' -"
git config --global alias.fadd '!'"sh -c 'git fzf status-unstaged git add \"\$@\" --' -"
git config --global alias.fco '!'"sh -c 'git fzf status-unstaged git checkout \"\$@\" --' -"
git config --global alias.freset '!'"sh -c 'git fzf status git reset \"\$@\" --' -"
git config --global alias.fbco '!'"sh -c 'git fzf branch git checkout \"\$@\"' -"
git config --global alias.trace '!'"sh -c 'GIT_TRACE=1 git \"\$@\"' -"
git config --global alias.prum 'pull --rebase upstream master'
git config --global alias.cleanup '!'"sh -c 'git co master >&2 && git pull && git branch --merged | grep -v master | xargs -n 1 git branch -d && git remote prune origin || git remote prune origin'"
git config --global alias.sno "show --name-only"
git config --global alias.dc "diff --cached"
git config --global alias.ad "add -u"
git config --global user.email "diogo.monica@gmail.com"


git config --global alias.prs '!'"sh -c 'hub pr list -f \"%i %au (updated: %ur) %Creset %t% l%n\"'"
git config --global alias.prs-by '!'"sh -c 'unbuffer git prs' | grep"
git config --global alias.pr-info "!f(){ hub pr show -f \"%pC%i(%pS)%Creset  %t%  l%n%B <- %H (url: %U) %nbody:%n%b\" \$1; }; f"
