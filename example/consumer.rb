require 'json'
require 'rdkafka'
config = {
  :"bootstrap.servers" => "localhost:29091",
  :"security.protocol" => "SASL_SSL",
  :"sasl.mechanisms" => "SCRAM-SHA-512",
  :"sasl.username" => "root",
  :"sasl.password" => "rootpassword",
  :"group.id" => "ruby-test",
  :"ssl.ca.location" => "ca.pem"
}
rdkafka = Rdkafka::Config.new(config)
topic = "rdkafka-test-topic"
consumer = rdkafka.consumer
consumer.subscribe(topic)

total_count = 0
puts "Consuming messages from #{topic}"
# Process messages
while true
  begin
    consumer.each do |message|
      record_key = message.key
      record_value = message.payload
      data = JSON.parse(record_value)
      total_count += data['count']

      puts "Consumed record with key #{record_key} and value #{record_value}, " \
         "and updated total count #{total_count}"
    end
  rescue Interrupt
    puts "Exiting"
  rescue => e
    puts "Consuming messages from #{topic} failed: #{e.message}"
  ensure
    consumer.close
    break
  end
end
