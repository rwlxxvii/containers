#!/bin/bash

echo '[+] ---------------------- Initializing postgres'
service msfdb init

echo '[+] ---------------------- Initializing tor'
service tor start

echo '[+] ---------------------- loading shell'
tmux new-session "msfdb run"
