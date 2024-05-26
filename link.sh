# This script is for setting up my personal use environment
# it allows immediatiate pushing and pulling  in the specified git repo
# it specifies custom commands for your bash. VIEW using <mention>
# sets up vim for immediate use

# if [ "$(id -u)" -ne 0 ]; then
#    echo "Please run with sudo"
#   exit 1
# fi
    if [ $# -lt 3 ]; then
     echo "USAGE: ./link.sh <username> <repository> <personal token>" 
     exit 1
    fi
    
    echo "Starting Git setup [0%]"
    sudo apt-get -y install expect > /dev/null
    echo "Progress [25%]  [======                  ]"

    git config --global user.email findtamilore
    git config --global user.name tami-cp0
    git config --global credential.helper store

    username="$1"
    repository="$2"
    personal_token="$3"
    
    git clone "https://github.com/$username/$repository.git" > /dev/null 2>&1 && wait
    echo "Progress [50%]  [============            ]"

# set up vim
vimrc="$HOME/.vimrc"

if grep -Fxq "set hls" $vimrc; then
    echo "vim has already been configured"
else
echo "
set hls
set ignorecase
set smartcase
set nu
set incsearch
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set visualbell
set title
set background=dark
set termguicolors
set cursorline
set encoding=utf8
set laststatus=2
" >> "$vimrc"

source "$vimrc"
fi

# custom commands in bashrc
bashrc="$HOME/.bashrc"

if grep -Fxq "function pushall() {" "$bashrc"; then
    echo "bashrc already has the functions"
else
echo '
function pushall() {
    if [ $# -lt 1 ]; then
        echo "        --------GIT SHORTCUT---------
        USAGE: push <commit_message>"
    else
        git add . && git commit -a -m "$1" && git push
    fi
}

function push() {
    if [ $# -lt 2 ]; then
        echo "        -------------GIT SHORTCUT--------------
        USAGE: push <filename> <commit_message>"
    else
        git add "$1" && git commit -a -m "$2" && git push
    fi
}

function exe() {
    if [ $# -lt 1 ]; then
        echo "USAGE: exe <filename>"
    else
        touch "$1" && chmod +x "$1"
        echo "[100%] Executable file created Successfully..."
    fi
}

function mention() {
    echo "
    List of custom commands
    1. push     - git push a single file
    2. pushall  - git push all files in current directory
    3. exe      - creates a file with executable permissions and opens the file
    "
}
' >> "$bashrc"

source $bashrc

fi
source "$bashrc"
echo "Progress [75%]  [==================      ]"
touch "$repository/test" && wait

cd "$repository" && wait
# Run expect script
expect << SCRIPT > /dev/null
    spawn bash
    expect "$ "
    send "push 'test' 'testing'\r"
    expect "Username:"
    send "$username\r"
    expect "Password:"
    send "$personal_token\r"
    expect "$ "
    send "rm test\r"
    send "push 'test' 'remove test file'\r"
    send "exit\r"
    expect eof
SCRIPT

echo "Progress [100%] [========================]"
