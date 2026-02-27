# Set Pure ZSH theme
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

# Configure prompt to remove pure theme state (user@hostname) from prompt
# the code below is adapted version of from https://github.com/sindresorhus/pure/blob/dbefd0dcafaa3ac7d7222ca50890d9d0c97f7ca2/pure.zsh#L865-L881
prompt_pure_state=()
PROMPT='%(12V.%F{$prompt_pure_colors[suspended_jobs]}%12v%f .)'
PROMPT+='%F{${prompt_pure_colors[path]}}%~%f'
PROMPT+='%(14V. %F{${prompt_pure_git_branch_color}}%14v%(15V.%F{$prompt_pure_colors[git:dirty]}%15v.)%f.)'
PROMPT+='%(16V. %F{$prompt_pure_colors[git:action]}%16v%f.)'
PROMPT+='%(17V. %F{$prompt_pure_colors[git:arrow]}%17v%f.)'
PROMPT+='%(18V. %F{$prompt_pure_colors[git:stash]}${PURE_GIT_STASH_SYMBOL:-≡}%f.)'
PROMPT+='%(19V. %F{$prompt_pure_colors[execution_time]}%19v%f.)'

# Newline separating preprompt from prompt.
PROMPT+='${prompt_newline}'


# Show exit code of last command as a separate prompt character
PROMPT+='%(?.%F{#32CD32}.%F{red}❯%F{red})❯%f '

# Show exit status before prompt
PROMPT='%F{red}$(precmd_pipestatus)'$PROMPT
