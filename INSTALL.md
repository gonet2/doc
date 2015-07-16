# 安装
## 基础设施
1. http://nsq.io/        
2. https://github.com/coreos/etcd       
3. docker             

请预先安装好上述环境，并确保172.17.42.1是容器可访问地址     

启动命令:

     $ ./etcd --listen-client-urls 'http://0.0.0.0:2379,http://0.0.0.0:4001' --advertise-client-urls 'http://0.0.0.0:2379,http://0.0.0.0:4001'
     $ ./nsqd -broadcast-address="172.17.42.1" -lookupd-tcp-address="127.0.0.1:4160"

## 框架
执行克隆:       

     curl -s https://raw.githubusercontent.com/gonet2/tools/master/clone_all.sh | sh      


## 启动agent
     $cd agent
     $source gvp
     $gpm
     $go install agent
     $./startup.sh
