require "helper"
require "fluent/plugin/out_tag_normaliser.rb"

class TagNormaliserOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "simple_test" do
    config = %[
      format cluster.${namespace_name}.${pod_name}.${labels.app}
    ]
    record = {
        "log" => "Example",
        "kubernetes" => {
            "pod_name" => "understood-butterfly-nginx-logging-demo-7dcdcfdcd7-h7p9n",
            "namespace_name" => "default",
            "labels" => {"app" => "nginx"}
        }
    }
    d = create_driver(config)
    d.run(default_tag: 'test') do
      d.feed("tag1", event_time, record.dup)
      d.feed("tag1", event_time, record.dup)
    end
    events = d.events
    puts events
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::TagNormaliserOutput).configure(conf)
  end
end
