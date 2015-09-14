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

请预先安装好上述环境，并确保172.17.42.1是容器可访问地址，所有基础设施都应该监听这个地址， 如mongodb, nsq, etcd

## 框架
执行克隆:       

     $curl -s https://raw.githubusercontent.com/gonet2/tools/master/clone_all.sh | sh      


## 启动
### 基础设施
1. nsq        
docker启动(开发环境推荐):

        docker pull nsqio/nsq
        docker run --name lookupd -p 4160:4160 -p 4161:4161 nsqio/nsq /nsqlookupd
	
        docker run --name nsqd -p 4150:4150 -p 4151:4151 \
        nsqio/nsq /nsqd \
        --broadcast-address=172.17.42.1 \
        --lookupd-tcp-address=172.17.42.1:4160

本地运行(生产环节推荐):

        $nsqlookupd --tcp-address=172.17.42.1:4160 --http-address=172.17.42.1:4161 &       
        $nsqd --lookupd-tcp-address=172.17.42.1:4160 --tcp-address=172.17.42.1:4150 --http-address=172.17.42.1:4151 &
        $nsqadmin --lookupd-http-address=172.17.42.1:4161 --http-address=172.17.42.1:4171 &

2. etcd

        $etcd &

3. gliderlabs/registrator
 
         $docker run -d -v /var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -ip="172.17.42.1" etcd://172.17.42.1:2379/backends

4. docker-grafana-graphite

        docker run -d -p 80:80 -p 8125:8125/udp -p 8126:8126 --name kamon-grafana-dashboard kamon/grafana_graphite


PS: 参考启动脚本: [base_service.sh](base_service.sh)  
		
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
		$upload_numbers numbers --addr http://172.17.42.1:4001 --dir ~/gonet2/gamedata --pattern="/*.csv"
	
