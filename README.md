# ssh-key-backdoor

This program generates a backdoor that hides inside an OpenSSH public key (e.g. `id_rsa.pub` or `authorized_keys`). The backdoor will execute when the user logs in next.

The objective is to use the ssh public key to move laterally within a target network. It exploits the fact that users copy they public ssh key `id_rsa.pub` to other servers without checking the content. Any server where their key is copied will get backdoored.

```shell
./ssh-key-backdoor.sh
```
