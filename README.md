# GameGophers
## 目录
1. [README.md](README.md) -- 当前文档
2. [ROADMAP.md](ROADMAP.md) -- 开发计划
3. [TOOLCHAIN.md](TOOLCHAIN.md) -- 工具链

## 核心理念
> 关键词: 分布式，手游服务器，基于GO语言        

业务分离是游戏服务器架构的基本思路，通过职能划分，能够合理调配服务器资源。
资源的大分类包括，IO,CPU,MEM, 例如常见的服务：        

    IO: 如: 数据库，文件服务        
    CPU: 如: 游戏逻辑        
    MEM: 如: 分词，排名，pubsub     
    
玩家对每种服务的请求量有巨大的不同，比如逻辑请求100次，分词请求1次，所以，没有必要1:1配置资源。
当服务容量增长，如果在monolithic的架构上做(全部服务揉在一起成一个大进程），会严重浪费资源(大量资源闲置，性价比极低), 所以GameGophers架构也是基于microservice的一次尝试。

为了把所有的服务串起来，必须满足的条件有：    
1. 支持一元RPC调用 (一般性查询)      
2. 支持服务器推送（例如pubsub服务）        
3. 支持双向流传递 (网关透传stream到后端)        

我们暂不想自己设计RPC，一是目前RPC繁多，没必要重新发明一个轮子，二是作为开源项目，应充分融入社区，利用现有资源。我们发现目前http2(rfc7540)支持所有以上的要求，google推出的gRPC就是基于http2的RPC实现，当前架构中，所有的服务(microservice)全部通过gRPC连接在一起。 http2支持stream multiplex，即可以在单一tcp连接上，传输多个流，非常适合表达透传数据。

        +-----------------------------------------------+
        |                 Length (24)                   |
        +---------------+---------------+---------------+
        |   Type (8)    |   Flags (8)   |
        +-+-------------+---------------+-------------------------------+
        |R|                 Stream Identifier (31)                      |
        +=+=============================================================+
        |                   Frame Payload (0...)                      ...
        +---------------------------------------------------------------+
    
                              Figure 1: Frame Layout


## 游戏架构
进入每个服务阅读对应文档      
1. [agent](https://github.com/GameGophers/agent): 网关      
2. [game](https://github.com/GameGophers/game): 游戏逻辑     
3. [snowflake](https://github.com/GameGophers/snowflake): UUID发生器      
4. [chat](https://github.com/GameGophers/chat): 聊天服务      
5. [auth](https://github.com/GameGophers/auth): 鉴权，登陆环节     
6. [libs](https://github.com/GameGophers/libs): 公共组件包       
7. [rank](https://github.com/GameGophers/rank): 排名服务     
8. [geoip](https://github.com/GameGophers/geoip): IP归属查询         
9. [arch](https://github.com/GameGophers/arch): 归档服务          
10. [bgsave](https://github.com/GameGophers/bgsave): 与redis结合的存档服务          
11. [wordfilter](https://github.com/GameGophers/wordfilter): 脏词过滤服务            

# 基础设施
1. [nsq](http://nsq.io/)          
2. [etcd](https://github.com/coreos/etcd)  

基础设施是用于支撑整个架构的基石，选择nsq, etcd的理由是:            

1. 全部采用go实现，技术栈统一          
2. nsq在bitly商用效果很好，能支持大规模的，高可用(特别是发生网络分区)的分布式应用              
3. etcd是coreos出品的coordinator, 已经得到大面积的使用，有成功案例，配套完善。             

## 服务关系： 

                 +
                 |
                 +--------------> auth
                 |
                 +----> game1
                 |
    agent1+------>
                 |
                 +----> game2
                 |                +
    agent2+------>                +-----> snowflake
                 |                |
                 +----> game3+---->
                 |                |
                 |                +-----> chat
                 ++               |
                                  +-----> rank
                                  +        


具体的服务描述以及使用案例，请进入各个目录中阅读

所有服务都依赖的一个基础服务是nsqd，用来搜集日志，所有的服务会把日志发送到本地的nsqd收集，通过nsqlookupd管理nsqd拓扑，通过tailn工具或nsq_tail，可以集中收集格式化的日志(json)，消息主题为 : LOG。

游戏中的归档日志(REDOLOG)，也会通过nsqd发布，并通过arch服务自动归档，消息主题为REDOLOG。

nsqd部署的方式为： **每个服务器实例部署一个**
