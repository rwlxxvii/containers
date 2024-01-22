#!/bin/bash

echo '[+] ---------------------- Initializing postgres'
msfdb init

echo '[+] ---------------------- Initializing tor'
service tor start

echo '[+] ---------------------- loading shell'
tmux new-session "msfconsole"
