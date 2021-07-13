#!/bin/bash

apt update
apt install sshpass -y

sshpass -p C1sco12345 ssh-copy-id -i .ssh/id_rsa.pub iacuser@20.194.42.125
sshpass -p C1sco12345 ssh-copy-id -i .ssh/id_rsa.pub iacuser@20.194.31.201
sshpass -p C1sco12345 ssh-copy-id -i .ssh/id_rsa.pub iacuser@20.194.41.201