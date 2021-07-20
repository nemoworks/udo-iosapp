from io import UnsupportedOperation
import paho.mqtt.client as mqtt
import json
import time
from argparse import ArgumentParser
import random
import math

parser: ArgumentParser = ArgumentParser("MQTT publisher argument parser")
parser.add_argument(
    "--type",
    "-t",
    required=True,
    choices=['register', 'update', 'delete'],
    help="publish to register topic",
)

opts = parser.parse_args()


def publish_register(context: str):
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.134.32', port=1883)
    payload = {'name': 'test-user'}

    message = {
        'source': 'backend',
        'destination': 'test@udo.com',
        'category': 'update',
        'context': context,
        'payload': payload
    }

    message_json = json.dumps(message, indent='  ')
    client.publish(topic='topic/register', payload=message_json, qos=1)
    client.disconnect()


def publish_device(category: str, context: str, uri: str):
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.134.32', port=1883)
    payload = {
        'name': 'XiaoMi Air Purifier',
        'avatarUrl': 'http://test.org',
        'uri': uri,
        'attributes': {
            'Temperature': {
                'value': round(random.random() * 10 + 20, 2),
                'category': 'numerical'
            },
            'Humidity': {
                'value': round(random.random(), 2),
                'category': 'numerical'
            },
            'Description': {
                'value': 'Xiaomi air purifier can purify the air',
                'category': 'text'
            },
            'Speed': {
                'value': 'high',
                'options': {
                    "option1": 'low',
                    "option2": 'mid',
                    "option3": 'high'
                },
                'category': 'enum',
                'editable': True
            },
            'Speed2': {
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
            },
            'On2': {
                'value': True,
                'category': 'boolean',
                'editable': False
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
    }

    message = {
        'source': 'backend',
        'destination': 'all',
        'category': category,
        'context': context,
        'payload': payload
    }
    message_json = json.dumps(message, indent='  ')
    client.publish(topic='topic/' + context, payload=message_json, qos=1)
    client.disconnect()


if __name__ == '__main__':
    device_uris = ['1q2w3e', '1q2w3f', '1q2w3g']
    if opts.type == 'register':
        for context in ['office-409', 'office-809', 'office-803']:
            publish_register(context=context)
            time.sleep(0.5)
    if opts.type == 'update':
        for context in ['office-409', 'office-809', 'office-803']:
            for device_uri in device_uris:
                publish_device(category='update',
                               context=context,
                               uri=device_uri)
                time.sleep(0.5)

    if opts.type == 'delete':
        publish_device(category='delete')