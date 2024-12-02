#!/usr/bin/ruby
require 'rdkafka'
require 'json'

config = {
  :"bootstrap.servers" => "localhost:29091",
  :"security.protocol" => :sasl_ssl,
  :"sasl.mechanisms" => "SCRAM-SHA-512",
  :"sasl.username" => "root",
  :"sasl.password" => "rootpassword",
  :"ssl.ca.location" => "ca.pem"
}
rdkafka = Rdkafka::Config.new(config)
topic = "rdkafka-test-topic"
admin = rdkafka.admin
producer = rdkafka.producer
begin
  create_topic_handle = admin.create_topic(topic, 1, 1)
  create_topic_handle.wait(max_wait_timeout: 15.0)
  puts "Created topic #{topic}"
rescue => e
  puts "Failed to create topic #{topic}: #{e.message}"
end

produced_messages = 0
begin
  0.upto(9).each do |n|
    record_key = 'alice'
    record_value = JSON.dump(count: n)
    record = "#{record_key}\t#{record_value}"
    puts "Producing record: #{record}"

    begin
      producer.produce(
        topic: topic,
        payload: record_value,
        key: record_key
      )
      produced_messages += 1
    rescue => e
      puts "Failed to produce record #{record}: #{e.message}"
    end
  end
ensure
  # delivers any buffered messages and cleans up resources
  producer.close
end
puts "#{produced_messages} messages were successfully produced to topic #{topic}!"
