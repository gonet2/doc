# 安装
## 环境
gonet2全部在linux + mac环境中开发，确保能在ubuntu 14.04 运行，理论上主流linux都能运行。      
开发工具链可以访问[TOOLCHAIN.md](TOOLCHAIN.md)     

## 基础设施
1. http://nsq.io/        
2. https://github.com/coreos/etcd       
3. https://www.docker.com/             

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
