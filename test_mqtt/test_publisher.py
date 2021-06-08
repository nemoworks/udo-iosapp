import paho.mqtt.client as mqtt

client = mqtt.Client(client_id='cn.edu.nju.czh.Publisher')
client.connect('test.mosquitto.org', port=1883)
client.publish('topic/udo-test', 'Hello MQTT!')
client.disconnect()