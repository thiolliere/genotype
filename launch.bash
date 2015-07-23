#!/bin/bash

#sudo tc qdisc add dev lo root netem delay 50ms 5ms distribution normal
love server > slog &
love client > clog 
#sudo tc qdisc del dev lo root
sleep 1
pkill -9 love
