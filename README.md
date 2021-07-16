# UDO-iOS-Client

## TODO

- 修改发送到信息的格式： {Header: ..., Body:...}

- 流程：

  - Register： 人向 `topic/register`里发送信息，包括自己的uri和自己的ac，ac初始化为空，后端通过订阅`topic/register`是可以知道目前有哪些人，每个人所处的ac
  - Register-Accept: 后端向`topic/register`中发送信息，告诉某个人应该被添加到什么ac上，然后人会切换到`topic/ac`下来进行交互
  - Update： 人向`topic/ac`下发送自己的信息，同步自己的状态，或者ac中其余设备的状态

- 区分：

  - 通过在每条信息中加入source和destination来判定信息的发送者和接受者
  - 不处理source是自己的消息，不处理destination不是自己的消息
  - 人更新空气净化器，那么source是人，destination是空气净化器； 人更新自己，那么source是人，destination也是人
  - 特殊： 后端发出的信息source是backend，如果是广播，那么destination是all

- 在Header里增加update还是delete的字段，根据行为来进行操作

  

## Test

1. Open the project. Build and run the app in simulator
2. Run commands below in terminal

``` shell
$ pip install paho-mqtt==1.5.1
$ python test_publisher.py
```

<img src="./doc/result2.gif" alt="image" style="zoom:50%;" />

<img src="./doc/result.gif" alt="image" style="zoom:50%;" />
