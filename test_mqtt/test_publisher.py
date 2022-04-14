from io import UnsupportedOperation
import paho.mqtt.client as mqtt
import json
import time
from argparse import ArgumentParser
import random
import math
import string
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
    client.connect('210.28.132.168', port=31768)
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


def publish_airpurifier(category: str, context: str, uri: str):
    payload = {
        "last_updated": "2021-07-22T09:18:54.147029+00:00",
        "avatarUrl": "no",
        "context": {
            "id": "7a8aff0beadf69de2e50e3e991d6bba4"
        },
        "attributes": {
            "led_brightness": 0.0,
            "friendly_name": "zhimi.airpurifier.m1",
            "extra_features": 0.0,
            "buzzer": True,
            "percentage_step": 25.0,
            "filter_life_remaining": 2.0,
            "use_time": 1.2121525E7,
            "learn_mode": False,
            "led": True,
            "filter_hours_used": 3423.0,
            "child_lock": False,
            "purify_volume": 137271.0,
            "mode": "idle",
            "favorite_level": 10.0,
            "preset_modes": ["Auto", "Silent", "Favorite", "Idle"],
            "average_aqi": 8.0,
            "motor_speed": 0.0,
            "supported_features": 9.0,
            "temperature": 24.5,
            "aqi": 10.0,
            "humidity": 68.0,
            "speed_list": ["Auto", "Silent", "Favorite", "Idle"],
            "model": "zhimi.airpurifier.m1",
            "turbo_mode_supported": False
        },
        "location": {
            "latitude": 20.9,
            "longitude": 11.1
        },
        "state": "off",
        "entity_id": "fan.zhimi_airpurifier_m1",
        "last_changed": "2021-07-22T09:02:53.245852+00:00",
        "uri": uri
    }

    message = dict()
    message['payload'] = payload
    message['source'] = 'backend'
    message['category'] = category
    message['context'] = context
    message['destination'] = 'all'
    message_json = json.dumps(message, indent='  ')
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.132.168', port=31768)
    client.publish(topic='topic/' + context, payload=message_json, qos=1)
    client.disconnect()


def publish_device(category: str, context: str, uri: str):
    client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
    client.username_pw_set(username='udo-user', password='123456')
    client.connect('210.28.132.168', port=31768)
    payload = {
        'name': 'Bus',
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
            'On': {
                'value': True,
                'category': 'boolean',
                'editable': True
            },
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
    device_uris = []
    for i in range(20):
        device_uri = ''.join(
            random.choices(string.ascii_uppercase + string.digits, k=8))
        device_uris.append(device_uri)

    if opts.type == 'register':
        for context in ['office-409', 'office-809', 'office-803']:
            publish_register(context=context)
            time.sleep(0.5)
        publish_register(context='智慧城管')
    if opts.type == 'update':
        # for context in ['office-409', 'office-809', 'office-803']:
        #     for device_uri in device_uris:
        #         publish_device(category='update',
        #                        context=context,
        #                        uri=device_uri)
        #         time.sleep(0.5)
        publish_airpurifier(
            category='update',
            context='office-409',
            uri="http://192.168.1.103:8123/api/states/fan.zhimi_airpurifier_m1"
        )
        time.sleep(0.5)

        publish_device(category="update", context="智慧城管", uri="123123")
        # for device_uri in device_uris:
        #     publish_device(category='update', context='智慧城管', uri=device_uri)
        #     time.sleep(0.5)

    if opts.type == 'delete':
        publish_device(category='delete')
