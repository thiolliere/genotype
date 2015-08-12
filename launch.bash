#!/bin/bash

if [ "$1" = "delay" ] 
then
       	sudo tc qdisc add dev lo root netem delay 50ms 5ms distribution normal
fi

love source server > slog &
love source > clog 

if [ "$1" = "delay" ] 
then
	sudo tc qdisc del dev lo root
fi
sleep 1
pkill -9 love
