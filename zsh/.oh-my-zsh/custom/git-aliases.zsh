alias gpr='git pull --rebase'
alias gsu='git submodule update --init --recursive'
alias gdo='git branch | grep -ve "^*" | xargs --max-args=1 git branch --delete --force'

rel-log() {
  korifi_home="$HOME/workspace/korifi"
  latest_release="$(git -C $korifi_home for-each-ref --sort=creatordate --shell --format 'r=%(refname); echo ${r#refs/tags/}' refs/tags | xargs -I{} bash -c {} | tail -1)"
  git -C "$korifi_home" log ${latest_release}..HEAD --pretty=format:'https://github.com/cloudfoundry/korifi/commit/%H %s %C(bold blue)<%al>%Creset' --abbrev-commit | grep -v dependabot | grep -v "Merge pull" | grep -v Korifi-Bot
}
