source "$HOME/google-cloud-sdk/completion.zsh.inc"
source "$HOME/google-cloud-sdk/path.zsh.inc"

alias gcloudlogin='gcloud auth login'
alias gcloudclustereirini='gcloud container clusters get-credentials --zone europe-west1-b --project cff-eirini-peace-pods'
alias gcloudcluster='gcloud container clusters get-credentials --zone europe-west1-b --project cf-on-k8s-wg'
