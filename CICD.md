# gogos + drone 做持续部署
* [gogs](https://gogs.io/)
* [drone](https://github.com/drone/drone)

安装好以上的工具，下面以agent为例做持续部署:
```
$ cd gonet2/src/agent
$ cat .drone.yml
```

```yml
cache:
  mount:
    - .git
    - docker/image.tar

clone:
  depth: 50
  recursive: true
  path: agent

build:
  image: golang:1.7rc3
  commands:
    - export CGO_ENABLED=0
    - export GOOS=linux
    - export GOARCH=amd64
    - go build -o agent agent

publish:
  docker:
    registry: 192.168.1.220:5000
    repo: 192.168.1.220:5000/agent
    tag: latest
    insecure: true
    load: docker/image.tar
    save:
      destination: docker/image.tar
      tag: latest

deploy:
  ssh:
    host: 192.168.1.220
    user: ubuntu
    port: 22
    commands:
      - sudo docker pull 192.168.1.220:5000/agent
      - sudo docker rm -f agent1
      - sudo docker run --link etcd --link mongodb  --link statsd -e STATSD_HOST="statsd:8125" --name agent1 -h agent-dev -d -p 8888:8888 -p 8888:8888/udp -p 6060:6060 -e SERVICE_ID=agent1 -e ETCD_HOST="http://etcd:2379" -e MONGODB_URL="mongodb://mongodb/mydb" 192.168.1.220:5000/agent
      
notify:
  email:
    from: drone-notify@example.com
    host: smtp.exmail.qq.com
    port: 465
    username: drone-notify@example.com
    password: MYPASSWORD

```
