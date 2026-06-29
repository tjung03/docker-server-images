#!/bin/bash
set -eu

BASHRC="$HOME/.bashrc"

touch "$BASHRC"

add_line() {
  grep -Fxq "$1" "$BASHRC" || printf '%s\n' "$1" >> "$BASHRC"
}

grep -Fxq "# docker-server-images configuration" "$BASHRC" || {
  printf '\n# docker-server-images configuration\n' >> "$BASHRC"
}

CONFIG_LINES=$(cat <<'CONFIG'
export PS1='\[\e[31;1m\][\u@\h\[\e[33;1m\] \w]\$ \[\e[m\]'
alias vi='/usr/bin/vim'
alias d='docker'
type __start_docker >/dev/null 2>&1 && complete -o default -F __start_docker d
alias irm='docker rmi -f $(docker images -aq)'
alias crm='docker rm -f $(docker ps -aq)'
alias vrm='docker volume rm -f $(docker volume ls -q)'
alias nrm='docker network rm $(docker network ls --filter type=custom --format "{{ .Name }}")'
CONFIG
)

printf '%s\n' "$CONFIG_LINES" | while IFS= read -r line; do
  add_line "$line"
done

echo "Done. Run: source ~/.bashrc"
