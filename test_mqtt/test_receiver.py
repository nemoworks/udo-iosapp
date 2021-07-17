import json
from typing import Dict
import paho.mqtt.client as mqtt
from termcolor import colored


def on_connect(client: mqtt.Client, userdata, flags, rc):
    print('Connected with result code: {}'.format(rc))
    client.subscribe([('topic/register', 0), ('topic/office-409', 0)])
    # client.subscribe('topic/sub')


def on_message(client: mqtt.Client, userdata, msg: mqtt.MQTTMessage):
    payload = msg.payload.decode()
    try:
        content_dict = json.loads(s=payload)
        print(
            colored('[Topic:{}]'.format(msg.topic), 'red', attrs=['bold']) +
            '{}'.format(content_dict))
    except:
        print(
            colored('[Topic:{}]'.format(msg.topic), 'red', attrs=['bold']) +
            str(payload))


client = mqtt.Client(client_id='cn.edu.nju.czh.Receiver')
client.username_pw_set(username='udo-user', password='123456')
client.connect('210.28.134.32', port=1883)
client.on_connect = on_connect
client.on_message = on_message
client.loop_forever()
