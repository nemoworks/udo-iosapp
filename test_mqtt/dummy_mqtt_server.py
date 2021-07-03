from typing import Dict, List
import paho.mqtt.client as mqtt
import json
from random import random
import threading


class XiaoMiAirPurifier(object):
    def __init__(self, device_id: int, device_name: str) -> None:
        super().__init__()
        self.device_id = device_id
        self.device_name = device_name
        self.temperature = 25
        self.humidity = 0.5
        self.description = 'Xiaomi air purifier can purify the air'
        self.speed = 'mid'
        self.on = True
        self.temperature_history = [25]
        self.humidity_history = [0.5]

    @property
    def attributes(self) -> Dict:
        attrs = dict()
        attrs['numerical'] = [{
            'name': 'Temperature',
            'value': self.temperature
        }, {
            'name': 'Humidity',
            'value': self.humidity
        }]

        attrs['text'] = [{'name': 'Description', 'content': self.description}]

        attrs['enum'] = [{
            'name': 'Speed',
            'options': ['low', 'mid', 'high'],
            'value': ['low', 'mid', 'high'].index(self.speed),
            'editable': True
        }]

        attrs['switch'] = [{'name': 'On', 'on': self.on, 'editable': True}]

        attrs['history'] = {
            'Temperature': self.temperature_history,
            'Humidity': self.humidity_history
        }

        return json.dumps(attrs, indent='  ')

    def sample(self):
        self.temperature = int((random() * 15 + 15) * 100) / 100
        self.temperature_history.append(self.temperature)
        self.humidity = int(random() * 100) / 100
        self.humidity_history.append(self.humidity)


class DummyMQTTServer(object):
    def __init__(self) -> None:
        self.devices: List[XiaoMiAirPurifier] = [
            XiaoMiAirPurifier(device_id=12345,
                              device_name='XiaoMi AirPurifier 1'),
            XiaoMiAirPurifier(device_id=54321,
                              device_name='XiaoMi AirPurifier 2'),
        ]

        self.publish_client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
        self.receive_client = mqtt.Client(client_id='cn.edu.nju.czh.Receiver')

    def publish_periodically(self):
        self.publish_client.connect('test.mosquitto.org', port=1883)
        for device in self.devices:
            device.sample()
            payload = {
                'sender': 'server',
                'name': device.device_name,
                'id': device.device_id,
                'attributes': device.attributes
            }
            self.publish_client.publish('topic/udo-test', payload)
        self.publish_client.disconnect()

    def on_connect(client: mqtt.Client, userdata, flags, rc):
        print('Connected with result code: {}'.format(rc))
        client.subscribe('topic/udo-test')

    def on_message(client: mqtt.Client, userdata, msg):
        print(msg.payload.decode())

    def receive(self):
        self.receive_client.connect('test.mosquitto.org', port=1883)
        self.receive_client.on_connect = self.on_connect
        self.receive_client.on_message = self.on_message
        self.receive_client.connect('test.mosquitto.org',
                                    port=1883,
                                    keepalive=60)
        self.receive_client.loop_forever()


def main():
    mqtt_server = DummyMQTTServer()


if __name__ == '__main__':
    main()