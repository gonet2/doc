#!/bin/bash -e

#start all base service.
#default is localhost:4001,localhost:2379, it's can't forward port to host ip.
export ETCD_ADDR="172.17.42.1:2379"
case $1 in
	start)
		#1. mongodb listen : 27017
		sudo service mongod start
		#2. redis listen : 6379
		#/usr/local/bin/redis-server /go/redis/conf/redis.conf &
		#3. nsq
		#nsqlookup tcp: 0.0.0.0:4160, http: 0.0.0.0:4161
		$GOBIN/nsqlookupd --tcp-address=172.17.42.1:4160 --http-address=172.17.42.1:4161 &
		#nsqd tcp: 0.0.0.0:4150, http: 0.0.0.0:4151
		$GOBIN/nsqd --lookupd-tcp-address=172.17.42.1:4160 --tcp-address=172.17.42.1:4150 --http-address=172.17.42.1:4151 &
		#nsqadmin http: 0.0.0.0:4171
		$GOBIN/nsqadmin --lookupd-http-address=172.17.42.1:4161 --http-address=172.17.42.1:4171 &
		#4. etcd 4001 for client 
		$GOBIN/etcd &
		#5. gliderlabs/registrator
		docker run -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="public_ip_that_all_services_can_access" etcd://172.17.42.1:2379/backends
		;;
	stop)
		sudo service mongod stop
		#killall redis-server
		killall nsqlookupd
		killall nsqd
		killall nsqadmin
		killall etcd
		docker stop $(docker ps |grep  gliderlabs/registrator|cut -b 1-12)
		;;
esac
