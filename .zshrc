export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

export XDG_CONFIG_HOME="$HOME/.config"
export QT_STYLE_OVERRIDE=dark
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx


export EDITOR=/usr/bin/nvim
export TERMINAL=alacritty

export PATH="$PATH:$HOME/.dotnet/tools"

export LANG=en_US.UTF-8
export LANG_ALL=en_US.UTF-8
#export LC_ALL=ja_JP.UTF-8

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH=/usr/share/oh-my-zsh/
ZSH_CUSTOM=/usr/share/zsh

ZSH_THEME="../../zsh-theme-powerlevel10k/powerlevel10k"

if [[ -n "$TMUX" ]]; then
    export PROJECT_ROOT=$(tmux show-environment -t "$TMUX_PANE" PROJECT_ROOT 2>/dev/null | sed 's/^PROJECT_ROOT=//')
fi

if [[ -n "$PROJECT_ROOT" ]]; then
    init_file="/tmp/.tmux_project_init_$(echo "$PROJECT_ROOT" | md5sum | cut -d' ' -f1)"
    if [[ -f "$init_file" ]]; then
        source "$init_file"
    fi
fi


plugins=(
    git direnv git-auto-fetch
    gitfast
    #fd
    fzf
    zsh-syntax-highlighting
    zsh-autosuggestions

)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
    mkdir $ZSH_CACHE_DIR
fi

. $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || . ~/.p10k.zsh

# Functions
function scale(){
    if [ -z $1 ]; then
        echo "set a dpi"
        return 1
    fi

    factor=$1
    dpi=$((factor * 96))

    if [ ! -f ~/.Xresources ]; then
        echo "Creating .Xresources"
        touch ~/.Xresources
    fi

    if grep -q '^Xft.dpi:' ~/.Xresources; then
        sed -i "s/^Xft.dpi:.*/Xft.dpi: $dpi/" ~/.Xresources
    else
        echo "Xft.dpi: $dpi" >> ~/.Xresources
    fi

    xrdb $HOME/.Xresources
    i3-msg restart

    echo "xft.dpi set to $dpi"
}

function evdev(){
    input_devices=$(ls /dev/input/by-id/*event* | grep -v if)

    for device in $input_devices
    do
        if [[ $device == *"kbd"* && $device == *"Keyboard"* ]]; then
            echo "<input type='evdev'>
            <source dev='$device' grab='all' repeat='on' grabToggle='ctrl-ctrl'/>
            </input>"
        else
            echo "<input type='evdev'>
            <source dev='$device'/>
            </input>"
        fi
    done | xclip -sel c
}

function google() {
    local IFS=+
    xdg-open "http://google.com/search?q=${*}"
}

function pkgSync(){
    cd $HOME
    git pull
    #command systemctl restart --user daemon-reload

    local package
    local packages
    local depends
    eval $(sed -n "/#startPackages/,/#endPackages/p" $HOME/config/PKGBUILD | rg -v '#')
    packages=$depends

    local targetPackages
    targetPackages=$(<<< $packages | tr ' ' '\n')
    local originalPackages=$targetPackages


    local newPackages
    newPackages=$(paru -Qeq | rg -xv $(<<< $targetPackages | tr '\n' '|'))

    if [ ! -z $newPackages ]; then
        echo "$(<<< $newPackages | grep -v linux-config | wc -l) new Packages"
        while read -r package; do
            if [[ "$package" == "linux-config" ]]; then
                continue
            fi
            paru -Qi $package
            read -k 1 "choice?[A]dd, [r]emove, [d]epends or [s]kip $package"
            case $choice in;
                [Aa])
                    echo "====================="
                    echo
                    targetPackages="$targetPackages\\n$package"
                    paru -D --asdeps $package
                    ;;
                [Rr])
                    echo "====================="
                    echo
                    paru -R --noconfirm $package
                    ;;
                [Dd])
                    echo "====================="
                    echo
                    paru -D --asdeps $package
                    ;;
                *)
                    :
                    ;;
            esac
            echo
            echo "============"
            echo
        done <<<"$newPackages"
    else
        echo "No new Packages"
    fi

    local missingPackages
    missingPackages=$(echo $targetPackages | rg -xv $(paru -Qqd | tr '\n' '|'))

    if [ ! -z $missingPackages ]; then
        echo "$(wc -l <<< $missingPackages) missing Packages"
        while read -r package; do
            if paru -Qi $package >/dev/null; then
                paru -D --asdeps $package
                continue
            fi
            paru -Si $package
            paru -Qi $package
            read -k 1 "choice?[I]nstall, [R]emove $package"
            case $choice in;
                [Ii])
                    echo "====================="
                    echo
                    paru -S --noconfirm $package
                    ;;
                [Rr])
                    echo "====================="
                    echo
                    targetPackages=$(echo $targetPackages | rg -xv "$packages")
                    ;;
                *)
                    :
                    ;;
            esac
            echo
            echo "============"
            echo
        done <<<"$missingPackages"
    else
        echo "No missing Packages"
    fi

    newPackages=$( (
        echo '  #startPackages'
        echo 'depends=('
        echo $targetPackages | sort | uniq | sed 's#^#    #g'
        echo '  )'
        echo '  #endPackages'
        ) | sed -r 's#$#\\n#g' | tr -d '\n' | sed -r 's#\\n$##g')


        sed -i -e "/#endPackages/a ${newPackages}" -e '/#startPackages/,/#endPackages/d' $HOME/config/PKGBUILD

        cd $HOME/config && makepkg -fsi --noconfirm &> /dev/null

        local orphanedPackages
        orphanedPackages=$(paru -Qqtd)

        if [ ! -z $orphanedPackages ]; then
            echo "===================="
            echo $orphanedPackages
            echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
            if read -q "?Remove orphaned packages? "; then
                while [ ! -z $orphanedPackages ]; do
                    echo "$(wc -l <<<$orphanedPackages) orphaned Packages"
                    paru -R --noconfirm $(tr '\n' ' ' <<<$orphanedPackages)
                    echo
                    orphanedPackages=$(paru -Qqtd)
                done
            fi
        else
            echo "No orphaned Packages"
        fi
        diff <(echo $originalPackages | sort) <(echo $targetPackages | sort)
        if ! /usr/bin/diff <(echo $originalPackages) <(echo $targetPackages) &> /dev/null; then
            if read -q "?Commit? "; then
                local pkgrel
                eval "$(grep pkgrel $HOME/config/PKGBUILD)"
                sed -i -e "s/pkgrel=$pkgrel/pkgrel=$(( $pkgrel + 1 ))/" $HOME/config/PKGBUILD #increase pkgrel
                # Commit the changes
                cd $HOME/config
                git add PKGBUILD
                git commit -m "Update packages: pkgrel=$(( pkgrel + 1 ))"
                git push
            fi
            cd $HOME/config && makepkg -fsi --noconfirm &> /dev/null
        else
            echo "No changes to commit"
        fi
}

declare -a tmpPackages
function tmpPackage() {
  paru "${@}"
  tmpPackages+=( $(grep installed /var/log/pacman.log | awk '{print $4}' | tail -5 | tac | awk '!x[$0]++' | fzf --prompt='Choose package to be uninstalled on exit' -m) )
}
compdef _paru tmpPackage

function _cleanTmpPackages() {
  if [[ "${#tmpPackages}" -gt 0 ]]; then
    paru -Rs --noconfirm "${tmpPackages[@]}"
  fi
}

function TRAPEXIT() {
  _cleanTmpPackages
}

function () :r(){
  _cleanTmpPackages
  exec zsh
}

function convertAudio(){
	originalDir="./original"
	if [ ! -d "$originalDir" ]; then
		echo "creating original directory"
		mkdir $originalDir
	fi
	for video in *.mp4; do
		noExt=${video%.mp4}
		ffmpeg -i $video -acodec pcm_s16le -vcodec copy "${noExt}.mov"
		mv "$video" "$originalDir"
	done
    for video in *.mov; do
		noExt=${video%.mov}
		ffmpeg -i $video -acodec pcm_s16le -vcodec copy "${noExt}.mov"
		mv "$video" "$originalDir"
	done

	echo $noExt
}

function extractAudio(){
}

function lsg() {
  local tracked untracked item

  local tracked_top=($(glsf))
  local untracked_top=($(gluf))

  local tracked_all=($(gls))
  local untracked_all=($(glu))

  for item in *; do
    if [[ -d "$item" ]]; then
      local has_untracked=false
      for u in "${untracked_all[@]}"; do
        [[ "$u" == "$item/"* ]] && has_untracked=true && break
      done
      if $has_untracked; then
        echo -e "\e[31m$item/\e[0m"  # Rot: Ordner enthält untracked Dateien
      elif [[ " ${tracked_top[@]} " =~ " $item " ]]; then
        echo -e "\e[32m$item/\e[0m"  # Grün: Ordner ist getrackt
      else
        echo "$item/"
      fi
    else
      # Datei ist einzeln untracked oder tracked
      if [[ " ${untracked_all[@]} " =~ " $item" ]]; then
        echo -e "\e[31m$item\e[0m"  # Rot: untracked Datei
      elif [[ " ${tracked_all[@]} " =~ " $item" ]]; then
        echo -e "\e[32m$item\e[0m"  # Grün: tracked Datei
      else
        echo "$item"
      fi
    fi
  done
}

function wlcp(){
    cat $1 | wl-copy
}


bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^b "books\n"
bindkey -s ^t "tmux kill-server\n"

systemctl --user import-environment 2> /dev/null

alias backup="pushd ~/; dconf-save; ga -u; gcd; gp; popd"
alias b="backup"
alias cal="cal -wm"
alias chrome="google-chrome-stable"
alias dconf-load="pushd ~/.config; dconf load / < dconf-settings; popd"
alias dconf-reset="dconf reset -f /"
alias dconf-save="pushd ~/.config; dconf dump / > dconf-settings; popd"
alias edit="vim ~/config/PKGBUILD"
alias ga="git add"
alias groot='cd "$(git rev-parse --show-toplevel)"'
alias wip='
  if [[ "$(git rev-parse --show-toplevel)" != "$HOME" && "$(git rev-parse --show-toplevel)" != "$HOME/." ]]; then
    groot && git add . && git commit -m "wip" && git push && cd -;
  else
    echo "Repo is in the home directory root (~/). Skipping operations to prevent dotfile commits.";
    cd -;
  fi'
alias gb="git branch -a"
alias gc="git commit -m"
alias gcd="git commit -m '$(date)'"
alias gco="git checkout"
alias gl="git log --graph --pretty=format:'%C(auto)%h %d %s %C(blue)(%cr) %C(green)<%an>' --abbrev-commit --all --decorate"
alias gls="git ls-files" # git list files
alias glu="git ls-files --others --exclude-standard" #git lists untracked files
alias glsf="git ls-files | awk -F'/' '{print \$1}' | sort | uniq" 
alias gluf="git ls-files --others --exclude-standard | awk -F'/' '{print \$1}' | sort | uniq"
alias gp="git push"
alias gpl="git pull"
alias gpr="git pull --rebase"
alias gs="git status"
alias ra="ranger"
alias ra="ranger"
alias rb="backup; reboot"
alias sd="backup; shutdown now"
alias sudo="sudo "
alias update="pushd ~/config; PACMAN='paru' PACMAN_AUTH='eval' makepkg -fsi; popd"
alias u="pushd ~/config; PACMAN='paru' PACMAN_AUTH='eval' makepkg -fsi --noconfirm; systemctl daemon-reload && systemctl --user daemon-reload && systemctl preset-all; popd"
alias vi="nvim"
alias vim="nvim"
alias nc="--noconfirm"
alias zshrc="vim ~/.zshrc"
alias rs="systemctl --user restart i3-session.target"
alias n="nvim"
alias t="tmux"
alias zsh="vim ~/.zshrc"
alias ps2pdf="ps2pdf -dPDFSETTINGS=/ebook"
alias a="ani-cli"
alias ceserver="/opt/ceserver/ceserver"
alias cengine="/opt/cheat-engine-zh/Cheat\ Engine.exe"
alias py=python

pokemon-colorscripts -r

if [ -f "/opt/miniforge/etc/profile.d/conda.sh" ]; then
    . "/opt/miniforge/etc/profile.d/conda.sh"
else
    export PATH="/opt/miniforge/bin:$PATH"
fi

export MAMBA_EXE='/opt/miniforge/bin/mamba';
export MAMBA_ROOT_PREFIX='/opt/miniforge';
alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate


# Load Angular CLI autocompletion.
source <(ng completion script)
