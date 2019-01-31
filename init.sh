#!/bin/bash

if [ -z "$(ls /data)" ]; then
	cp -a /dist/* /data/
	chmod 777 /data
	chmod 777 /data/cache -R
	chmod 777 /data/feed-icons -R
	chmod 777 /data/lock -R
fi

/usr/bin/supervisord
