import paho.mqtt.client as mqtt
import json
import time


def publish():
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.134.32', port=1883)
    payload = {
        'sender': 'server',
        'name': 'XiaoMi Air Purifier',
        'id': 1234,
        'attributes': {
            'numerical': [{
                'name': 'Temperature',
                'value': 24.5,
            }, {
                'name': 'Humidity',
                'value': 0.5,
            }],
            'text': [{
                'name': 'Description',
                'content': 'Xiaomi air purifier can purify the air'
            }],
            'enum': [{
                'name': 'Speed',
                'options': ['low', 'mid', 'high'],
                'value': 'mid',
                'editable': True,
            }],
            'boolean': [{
                'name': 'On',
                'on': True,
                'editable': True,
            }]
        },
        'history': {
            'Temperature': [
                29.55, 25.4, 27.32, 21.93, 27.01, 15.22, 15.07, 20.73, 26.0,
                26.38, 28.9, 20.3, 27.23, 15.76, 21.62, 15.98, 22.22, 18.96,
                21.58, 24.5
            ],
            'Humidity': [
                0.27, 0.9, 0.23, 0.2, 0.59, 0.24, 0.54, 0.89, 0.19, 0.65, 0.9,
                0.77, 0.58, 0.62, 0.03, 0.05, 0.48, 0.49, 0.42, 0.5
            ]
        },
        'location': {
            'latitude': 32.12344,
            'longitude': 118.328759
        }
    }

    for i in range(5):
        payload['id'] += 1
        payload_json = json.dumps(payload, indent='  ')
        client.publish('topic/test', payload_json)
        time.sleep(1)
    client.disconnect()


publish()