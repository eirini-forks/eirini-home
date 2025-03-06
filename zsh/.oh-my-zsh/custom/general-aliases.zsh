alias vim='nvim'
alias fd='fdfind'
alias flake-hunter='concourse-flake-hunter -c https://ci.korifi.cf-app.com -n main search'
alias eirinisay='cowsay -f $HOME/cows/eirini.cow'


flylogin() {
  local team
  team=${1:-"main"}
  fly -t korifi login --team-name "$team" --concourse-url https://ci.korifi.cf-app.com/ </dev/tty
}

urlenc() {
    printf %s "$*" | jq -sRr @uri
}

dockerlogin() {
    docker login -u "$(vault kv get -field=username concourse/main/release-pipeline/dockerhub-auth)" -p "$(vault kv get -field=password concourse/main/release-pipeline/dockerhub-auth)"
}
