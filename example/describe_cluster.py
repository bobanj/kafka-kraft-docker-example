# pip install kafka-python
from kafka import KafkaAdminClient

admin_client = KafkaAdminClient(
    bootstrap_servers="localhost:29091",
    security_protocol="SASL_SSL",
    sasl_mechanism="SCRAM-SHA-512",
    sasl_plain_username="root",
    sasl_plain_password="rootpassword",
    ssl_certfile="ca.pem",
)

try:
    print(admin_client.describe_cluster())
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    admin_client.close()
