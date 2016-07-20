# 安装
## 环境
gonet2全部在linux + mac环境中开发，确保能在ubuntu 14.04 运行，理论上主流linux都能运行。      
开发工具链可以访问[TOOLCHAIN.md](TOOLCHAIN.md)     

## etcd
https://coreos.com/etcd/docs/2.0.8/docker_guide.html#running-etcd-in-standalone-mode

## Mongodb
https://hub.docker.com/_/mongo/

## 性能监控
https://hub.docker.com/r/kamon/grafana_graphite/

## 日志ELK
https://hub.docker.com/r/sebp/elk/

## stdout汇聚
https://hub.docker.com/r/gliderlabs/logspout/

## Registrator
https://hub.docker.com/r/gliderlabs/registrator/

## 框架
执行克隆:       

     $curl -s https://raw.githubusercontent.com/gonet2/tools/master/clone_all.sh | sh      

### Docker启动服务(推荐)
docker中运行：所有服务运行在docker中，并通过registrator自动注册；            
比如启动agent: 

         $cd agent
         $docker build -t agent .
         $docker run -d -p 8888:8888 --name agent -e SERVICE_ID=agent1 agent


### 普通启动服务
比如启动agent: 

         $cd agent
         $go install agent
         $agent

### 服务注册
一般情况下， registrator 会自动注册通过docker启动的服务, 为了调试的方便，可以不通过docker启动，并且手动注册到etcd， etcd的服务注册地址为:

         /backends/SERVICE_NAME/SERVICE_ID 
         
例如:

         $etcdctl set /backends/snowflake/snowflake1 172.17.42.1:51006
         
## 客户端与服务器的对接

参考 https://github.com/en/unity-lib


## 工具安装
	1.tailn 查看所有服务的日志
		$go get https://github.com/gonet2/tools/tailn
		$tailn
	
	2. 协议生成
		$cd /github.com/gonet2/tools/proto_scripts
		$./gen_proto.sh
	
