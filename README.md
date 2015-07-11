# GameGophers
## 目录
1. [README.md](README.md) -- 当前文档
2. [ROADMAP.md](ROADMAP.md) -- 开发计划
3. [TOOLCHAIN.md](TOOLCHAIN.md) -- 工具链

## 核心理念
关键词: 分布式，手游服务器，基于GO语言        
分布式架构是游戏服务器资源合理配置的基本思路，通过职能划分，能够充分调配服务器资源。
资源的大分类包括，IO,CPU,MEM, 例如常见的服务：       
IO: 数据库，文件服务        
CPU: 游戏逻辑        
MEM: 分词，geoip，pubsub     
每种服务的请求量不同，比如逻辑请求100次，分词请求1次。
当服务容量增长，如果在monolithic的架构上做，会极大的浪费资源(大量资源闲置，调配不合理), 所以GameGophers架构是基于microservice的一次尝试。

把所有的服务串起来，必须满足的条件有：    
1. 支持一元RPC调用 (一般性查询)      
2. 支持服务器推送（例如pubsub服务）        
3. 支持双向流传递 (透传stream到后端)        

我们暂不想自己设计RPC，一是目前RPC繁多，没必要继续发明一个轮子，二是作为开源项目，尽量充分融入社区，利用现有资源。我们发现目前http2支持所有以上的要求，google推出的gRPC就是基于http2的RPC实现，当前架构中，所有的服务(microservice)全部通过gRPC连接在一起。

## 游戏架构
1. agent 前端连接管理服务，与客户端建立连接，转发客户端消息     
2. game 游戏逻辑处理服务，游戏逻辑处理，     
3. snowflake 分布式ID生成服务, 自增ID， UUID。      
4. chat 游戏聊天服务      
5. auth 帐号验证服务，游戏登录时验证帐号。相当于登录服务     
6. libs 游戏公共组件包       
7. rank 排名服务     

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
游戏服为小服结构，即一个game服务，对应游戏中的一个服务器。       
agent只保持连接， 不做具体游戏逻辑处理。只处理保留的协议号（0-1000）， 其它全部转发         
agent <==> game  之间为grpc双向流, 直接转发agent协议包到game       
game <==> game 之间不互通。       
chat, rank等服务中的部份接口， 可以直接在agent中处理， 提高效率。        
chat 为grpc server side stream.        
