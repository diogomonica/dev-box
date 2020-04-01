# Return if not an interactive shell
[[ "$-" != *i* ]] && return

[ -f $HOME/.bashrc ] && . $HOME/.bashrc


