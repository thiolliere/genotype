#!/bin/bash

love server &
love client
pkill -9 love
