#!/bin/bash -e

#start all base service.
case $1 in
	start)
		#1. mongodb listen : 27017
		sudo service mongod start
		#2. redis listen : 6379
		/usr/local/bin/redis-server &
		#3. nsq
		#nsqlookup tcp: 0.0.0.0:4160, http: 0.0.0.0:4161
		$GOBIN/nsqlookupd &
		#nsqd tcp: 0.0.0.0:4150, http: 0.0.0.0:4151
		$GOBIN/nsqd --lookupd-tcp-address=127.0.0.1:4160 &
		#nsqadmin http: 0.0.0.0:4171
		$GOBIN/nsqadmin --lookupd-http-address=127.0.0.1:4161 &
		#4. etcd
		$GOBIN/etcd &
		#5. gliderlabs/registrator
		docker run -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="127.0.0.1" etcd://127.0.0.1:4001/backends
		;;
	stop)
		sudo service mongod stop
		killall redis-server
		killall nsqlookupd
		killall nsqd
		killall nsqadmin
		killall etcd
		docker stop $(docker ps |grep  gliderlabs/registrator|cut -b 1-12)
		;;
esac


