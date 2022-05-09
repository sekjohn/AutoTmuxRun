#!/bin/bash
function Help {
    echo "? help"
    echo "-n new create session"
    echo "-t attach session"
    echo "-i command list josn file"
    exit 0
}

function CheckInstallation {
    CHECK_OS="`uname -s`"
    case "$CHECK_OS" in     
        Darwin*) OS="MAC";;    
        Linux*) OS="LIN";;     
        MINGW32*) OS="WIN";; 
        MINGW64*) OS="WIN";; 
        CYGWIN*) OS="WIN";; 
    esac

    if ! command -v tmux &> /dev/null; then
        echo "[*] tmux not install not found!"
        read -p "[-] (yes/y OR no/n) input: " INSTALLRESULT
        if [[ $INSTALLRESULT == "yes" ]] || [[ $INSTALLRESULT == "y" ]]; then
            if [$OS == "MAC"]; then
                brew install tmux
            elif [$OS == "LIN"]; then
                apt-get install tmux
            elif [$OS == "WIN"]; then
                echo "[*] Not support"
            fi
        else
            echo "[*] Not use shell script"
            exit 0
        fi
    fi
    if ! command -v jq &> /dev/null; then
        echo "[*] jq not install not found!"
        read -p "[-] ((yes/y OR no/n) input: " INSTALLRESULT
        if [[ $INSTALLRESULT == "yes" ]] || [[ $INSTALLRESULT == "y" ]]; then
            if [$OS == "MAC"]; then
                brew install jq
            elif [$OS == "LIN"]; then
                curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq
                chmod a+x /usr/local/bin/jq
            elif [$OS == "WIN"]; then
                echo "[*] Not support"
            fi
        else
            echo "[*] Not use shell script"
            exit 0
        fi
    fi
}

function Run {
    if [ -n "${CommandListFile}" ]; then
        FILEDATAS=($(jq -r '.command' ${CommandListFile} | tr -d '[], "'))
        FILESESSIONDATAS=$(jq -r '.session' ${CommandListFile})
    fi
    
    if [ -n "$1" ]; then
        session=$1
    elif [ -n "${FILESESSIONDATAS}" ]; then
        session="${FILESESSIONDATAS}"
    else
        echo "[*] Error: use attach session or new session"
        exit 0
    fi
    echo "[*] Session: ${session}"
    PanesNum=( $(tmux list-panes -F '#{window_index}.#{pane_index}' -t ${session}) )
    for i in ${PanesNum[*]}; do
        tmux send-keys -t ${session}:$i C-c
    done
    if [ "${#PanesNum[*]}" -lt "${#FILEDATAS[*]}" ]; then
        echo "[*] ERROR: Commands is greater than Panes"
        exit 0
    fi 
    for index in ${!PanesNum[*]} ; do
        COMMANDDATAS=$(jq -r ".command[${index}]" ${CommandListFile})
        if [ "$COMMANDDATAS" != "null" ]; then
            tmux send-keys -t ${session}:${PanesNum[$index]} "${COMMANDDATAS}" Enter
        fi
    done
    echo "[*] Restart or Start complete!"
}

CheckInstallation

while getopts ":n:t:i:" opt; do
    case $opt in
        n ) NewSessionName=$OPTARG;;
        t ) AttachSessionName=$OPTARG;;
        i ) CommandListFile=$OPTARG;;
        ? ) Help;;
    esac
done

if [ -z "$CommandListFile" ]; then
    echo "[*] ERROR: not found command.json"
    exit 0 
fi

if [ -z "$AttachSessionName" ] && [ -n "$CommandListFile" ]; then
    Run
else
    if [ -n "$AttachSessionName" ]; then
        Run $AttachSessionName
    elif [ -z "$NewSessionName" ]; then
        read -p "[-] new session: " NewSessionName
        tmux new -d -t $NewSessionName
        Run $NewSessionName
    fi
fi