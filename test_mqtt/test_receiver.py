import json
from typing import Dict
import paho.mqtt.client as mqtt
from termcolor import colored


def on_connect(client: mqtt.Client, userdata, flags, rc):
    print('Connected with result code: {}'.format(rc))
    # client.subscribe([('topic/register', 0), ('topic/office-409', 0),
    #                   ('topic/office-809', 0), ('topic/office-803', 0)])
    # client.subscribe('topic/sub')
    client.subscribe([('topic/会议安排-cedeb98f', 0)])

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
client.connect('210.28.132.168', port=30609)
client.on_connect = on_connect
client.on_message = on_message
client.loop_forever()
