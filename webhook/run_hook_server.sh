#!/bin/bash

case "$1" in
	start)
		/usr/bin/ruby dev-webhook.rb
		;;
	stop)
		kill -9 $(lsof -i :6969 | awk 'NR==2 {print $2}')
		;;
	*)
		echo $"Usage: $0 {start|stop}"
		exit 1
esac
