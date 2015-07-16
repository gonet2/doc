#!/bin/bash -e

#start all base service.
#etcd default is localhost:4001,localhost:2379, it's can't forward port to host ip.
export ETCD_ADDR="172.17.42.1:2379"
case $1 in
	start)
		
		nsqlookupd --tcp-address=172.17.42.1:4160 --http-address=172.17.42.1:4161 &
		
		nsqd --lookupd-tcp-address=172.17.42.1:4160 --tcp-address=172.17.42.1:4150 --http-address=172.17.42.1:4151 &
		
		nsqadmin --lookupd-http-address=172.17.42.1:4161 --http-address=172.17.42.1:4171 &
		
		etcd &
		
		docker run -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="public_ip_that_all_services_can_access" etcd://172.17.42.1:2379/backends
		;;
	stop)
		killall nsqlookupd
		killall nsqd
		killall nsqadmin
		killall etcd
		docker stop $(docker ps |grep  gliderlabs/registrator|cut -b 1-12)
		;;
esac
