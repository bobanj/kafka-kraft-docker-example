# kafka-kraft-docker-example (sasl-ssl) 
Kafka Kraft Cluster using (sasl-ssl) 

# Using the `cp-kafka:7.7.1` image 
* [Confluentic](https://github.com/confluentinc/)  

# Inspired from and kudos to:  
* https://github.com/palkx/vault-plugin-secrets-kafka 
  * Changes: 
    * Kafka configuration in dockerfile 
    * Modified cert creation
* https://github.com/katyagorshkova/kafka-kraft
  * Changes: 
    * Dynamic clusterID to work with `cp-kafka:7.7.1`


## Pre-requisites
* Install [docker-compose](https://docs.docker.com/compose/install/)
* Install [ruby](https://www.ruby-lang.org/en/documentation/installation/) (for examples) 
* Install [python](https://www.python.org/downloads/) (for examples)

## Running the examples
* Start the kafka cluster:
  * `docker-compose up --build --force-recreate`
* Once the cluster is running, copy the `ca.pem` file to the `example` directory so that the producer and consumer can use it
as in this particular case the certificate is self-signed.
  *  `docker cp kafka-kraft-setup-kafka-1:/etc/kafka/secrets/ca.pem ./example`
* Test the producer and consumer:
  * `cd example && bundle install`
  * In separate terminals from the example directory run:
    * `ruby producer.rb` 
    * `ruby producer.rb`
  * To check connectivity with python:
    * `pip install kafka-python`
    * `python describe_cluster.py`
 
## Notes
* The scripts directory contains:
  * `kafka-setup.sh` - is run by the `kafka-provisioner` container, it sets up the clusterID, generates the certificates and the `kafka-storage` to use `scram`
  * `update-run.sh` - sets the `CLUSTER_ID` environmental variable before running the cluster
* For more information about the setup please see the `docker-compose.yaml` file.
