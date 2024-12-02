require 'rdkafka'

class AwsCloud
  attr_reader :topic
  attr_reader :kafka

  def initialize(config_hash)
    @config = config_hash
  end

  def topic
    "ruby-test-topic"
  end

  def admin
    @admin ||= rdkafka_admin_config.admin
  end

  def producer
    @producer ||= rdkafka_producer_config.producer
  end

  def consumer
    return @consumer unless @consumer.nil?

    @consumer = rdkafka_consumer_config.consumer
    at_exit do
      @consumer.close
    end
    @consumer
  end

  private

  def rdkafka_admin_config
    Rdkafka::Config.new(@config)
  end

  def rdkafka_consumer_config
    Rdkafka::Config.new(
      {
        :"auto.offset.reset" => "earliest",
      }.merge(@config)
    )
  end

  def rdkafka_producer_config
    Rdkafka::Config.new(
      {
        :"linger.ms" => 5,
      }.merge(@config)
    )
  end
end
