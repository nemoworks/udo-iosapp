import paho.mqtt.client as mqtt
import json


def publish():
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.connect('test.mosquitto.org', port=1883)
    payload = {
        'name': 'XiaoMi Air Purifier',
        'id': 1234,
        'attributes': {
            'numerical': [{
                'name': 'temperature',
                'value': 24.5
            }, {
                'name': 'humidity',
                'value': 0.5
            }],
            'text': [{
                'name': 'description',
                'content': 'Xiaomi air purifier can purify the air'
            }],
            'enum': [{
                'name': 'speed',
                'options': ['low', 'mid', 'high'],
                'value': 2,
                'editable': True,
            }],
            'switch': [{
                'name': 'On',
                'on': True,
                'editable': True,
            }]
        }
    }

    payload = json.dumps(payload, indent='  ')

    client.publish('topic/udo-test', payload)
    client.disconnect()


publish()