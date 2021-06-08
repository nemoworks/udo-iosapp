import paho.mqtt.client as mqclient


def on_connect(client: mqclient.Client, userdata, flags, rc):
    print('Connected with result code: {}'.format(rc))
    client.subscribe('topic/test')


def on_message(client: mqclient.Client, userdata, msg):
    print(msg.payload.decode())
    if msg.payload.decode() == 'Hello MQTT!':
        client.disconnect()


client = mqclient.Client(client_id='cn.edu.nju.czh.Receiver')
client.connect('test.mosquitto.org', port=1883, keepalive=60)
client.on_connect = on_connect
client.on_message = on_message
client.loop_forever()
