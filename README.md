# GameGophers
## 目录
1. [README.md](README.md) -- 当前文档
2. [ROADMAP.md](ROADMAP.md) -- 开发计划
3. [TOOLCHAIN.md](TOOLCHAIN.md) -- 工具链

## 核心理念
> 关键词: 分布式，手游服务器，基于GO语言        

业务分离是游戏服务器架构的基本思路，通过职能划分，能够合理调配服务器资源。
资源的大分类包括，IO,CPU,MEM, 例如常见的服务：        

    IO: 数据库，文件服务        
    CPU: 游戏逻辑        
    MEM: 分词，geoip，pubsub     
    
玩家对每种服务的请求量有巨大的不同，比如逻辑请求100次，分词请求1次，所以，没有必要1:1配置资源。
当服务容量增长，如果在monolithic的架构上做(全部服务揉在一起成一个大进程），会严重浪费资源(大量资源闲置，性价比极低), 所以GameGophers架构也是基于microservice的一次尝试。

把所有的服务串起来，必须满足的条件有：    
1. 支持一元RPC调用 (一般性查询)      
2. 支持服务器推送（例如pubsub服务）        
3. 支持双向流传递 (透传stream到后端)        

我们暂不想自己设计RPC，一是目前RPC繁多，没必要继续发明一个轮子，二是作为开源项目，尽量充分融入社区，利用现有资源。我们发现目前http2支持所有以上的要求，google推出的gRPC就是基于http2的RPC实现，当前架构中，所有的服务(microservice)全部通过gRPC连接在一起。

## 游戏架构
1. agent: 网关      
2. game: 游戏逻辑     
3. snowflake: UUID发生器      
4. chat: 聊天服务      
5. auth: 鉴权，登陆环节     
6. libs: 公共组件包       
7. rank: 排名服务     

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
