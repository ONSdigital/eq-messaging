import pika
import pika.credentials

credentials = pika.credentials.PlainCredentials('admin', 'admin')

connection = pika.BlockingConnection(pika.ConnectionParameters(host='rabbitmq2.eq.ons.digital', credentials=credentials))

channel = connection.channel()

channel.queue_declare(queue='hello')

channel.basic_publish(exchange='', routing_key='hello', body='Hello World!')
print(" [x] Sent 'Hello World!'")

connection.close()
