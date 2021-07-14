import paho.mqtt.client as mqtt
import json
import time


def publish():
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.134.32', port=1883)
    payload = {
        'name': 'XiaoMi Air Purifier',
        'id': "1e2w3awdAWd2",
        'avatarUrl': 'http://test.org',
        'attributes': {
            'Temperature': {
                'value': 24.5,
                'category': 'numerical'
            },
            'Humidity': {
                'value': 0.5,
                'category': 'numerical'
            },
            'Description': {
                'value': 'Xiaomi air purifier can purify the air',
                'category': 'text'
            },
            'Speed': {
                'value': 'mid',
                'options': {
                    "option1": 'low',
                    "option2": 'mid',
                    "option3": 'high'
                },
                'category': 'enum',
                'editable': True
            },
            'On': {
                'value': True,
                'category': 'boolean',
                'editable': True
            }
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
            'latitude': 32.11088,
            'longitude': 118.9701
        },
        'uri': '123456'
    }

    for i in range(1):
        payload['id'] += "1"
        payload_json = json.dumps(payload, indent='  ')
        print(payload_json)
        client.publish('topic/sub/test@udo.com', payload_json)
        time.sleep(1)
    client.disconnect()


publish()