# UDO-iOS-Client

## TODO

- implement history data chart
- implement map view

## test

1. Install dependency
``` shell
$ pod install
```

2. Open `UDO Client.xcworkspace`, build and run the  XCode Project


3. Run commands below in terminal

``` shell
$ pip install paho-mqtt==1.5.1
$ python test_publisher.py
```

![image](./doc/result.gif)



## 问题

应用在后台无法接受MQTT，原因是苹果不允许在后台的应用保持一个TCP连接，而MQTT协议构建在TCP之上，因此如果想进行后台的推送，需要适用APNS