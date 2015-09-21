# 安装
## 环境
gonet2全部在linux + mac环境中开发，确保能在ubuntu 14.04 运行，理论上主流linux都能运行。      
开发工具链可以访问[TOOLCHAIN.md](TOOLCHAIN.md)     

## 基础设施
1. http://nsq.io/        
2. https://github.com/coreos/etcd       
3. https://www.docker.com/    
4. https://github.com/pote/gvp
5. https://github.com/pote/gpm

## 开发环境基础服务搭建(MAC OS X)

     安装 docker toolbox : https://www.docker.com/toolbox
     $docker-machine create --driver virtualbox default
     $docker-machine upgrade default
     $docker run --name etcd -d -p 2379:2379  quay.io/coreos/etcd -addr 172.17.42.1:2379
     $docker run --name mongodb -d -p 27017:27017  -v /data/db:/data/db -d mongo
     $docker run -d --name lookupd -p 4160:4160 -p 4161:4161 nsqio/nsq /nsqlookupd
     $docker run -d --name nsqd -p 4150:4150 -p 4151:4151  nsqio/nsq /nsqd   --broadcast-address=172.17.42.1   --lookupd-tcp-address=172.17.42.1:4160
     $docker run -d --name etcd-browser -p 0.0.0.0:8000:8000 --env ETCD_HOST=172.17.42.1 --env ETCD_PORT=2379  --env AUTH_USER=admin --env AUTH_PASS=admin etcd-browser
     注意: 进入docker-machine运行registrator
     $docker-machine ssh default
     $docker run --name registrator -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="172.17.42.1" etcd://172.17.42.1:2379/backends

## 开发环境基础服务搭建(ubuntu 14.04)

     sudo ip addr add 172.17.42.1/16 dev docker0
     sudo docker run --name etcd -d -p 2379:2379  quay.io/coreos/etcd -addr 172.17.42.1:2379
     sudo docker run --name registrator -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="172.17.42.1" etcd://172.17.42.1:2379/backends
     sudo docker run --name mongodb -d -p 27017:27017  -v /data/db:/data/db -d mongo
     sudo docker run -d --name lookupd -p 4160:4160 -p 4161:4161 nsqio/nsq /nsqlookupd
     sudo docker run -d --name nsqd -p 4150:4150 -p 4151:4151  nsqio/nsq /nsqd   --broadcast-address=172.17.42.1   --lookupd-tcp-address=172.17.42.1:4160
     sudo docker run -d --name statsd -p 80:80 -p 8125:8125/udp -p 8126:8126  kamon/grafana_graphite
     sudo docker run -d --name etcd-browser -p 0.0.0.0:8000:8000 --env ETCD_HOST=172.17.42.1 --env ETCD_PORT=2379  --env AUTH_USER=admin --env AUTH_PASS=admin etcd-browser
     sudo docker run -d --name registry -e SETTINGS_FLAVOR=dev -e STORAGE_PATH=/tmp/registry -v /data/registry:/tmp/registry  -p 5000:5000 registry
      
服务重启:

     sudo docker restart  etcd mongodb nsqd lookupd statsd etcd-browser registry registrator


PS: 参考生产环境启动脚本: [base_service.sh](base_service.sh)  

## 框架
执行克隆:       

     $curl -s https://raw.githubusercontent.com/gonet2/tools/master/clone_all.sh | sh      

### Docker启动服务(推荐)
docker中运行：所有服务运行在docker中，并通过registrator自动注册；            
如snowflake:  

         $cd snowflake
         $docker build -t snowflake
         $docker run -d --name snowflake -e SERVICE_ID=snowflake1 -P snowflake


### 普通启动服务
比如启动agent: 

         $cd agent
         $source gvp
         $gpm
         $go install agent
         $./startup.sh

### 服务注册
一般情况下， registrator 会自动注册通过docker启动的服务, 为了调试的方便，可以不通过docker启动，并且手动注册到etcd， etcd的服务注册地址为:

         /backends/SERVICE_NAME/SERVICE_ID 
         
例如:

         $etcdctl set /backends/snowflake/snowflake1 172.17.42.1:51006


## 工具安装
	1.tailn 查看所有服务的日志
		$go get https://github.com/gonet2/tools/tailn
		$tailn
	
	2. upload_numbers 上传配置文件到etcd(以逗号分割的csv文件)
		$go get https://github.com/gonet2/tools/upload_numbers
		$upload_numbers numbers --addr http://172.17.42.1:2379 --dir ~/gonet2/gamedata --pattern="/*.csv"
	
