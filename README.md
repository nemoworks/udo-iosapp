# UDO-iOS-Client

## TODO

- 如何将设备接入到UDO：假定每个用户都有一个账号，用电子邮箱绑定，那么可以将电子邮箱的编码当作用户的ID，并且使用这个ID来指定topic。服务端使用这个ID来映射到UDO到object

## Test

1. Open the project. Build and run the app in simulator
2. Run commands below in terminal

``` shell
$ pip install paho-mqtt==1.5.1
$ python test_publisher.py
```

<img src="./doc/result2.gif" alt="image" style="zoom:50%;" />

<img src="./doc/result.gif" alt="image" style="zoom:50%;" />
