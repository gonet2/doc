# doc
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
