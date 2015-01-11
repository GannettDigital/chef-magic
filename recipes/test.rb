#
# Cookbook Name:: magic
# Recipe:: test
#
# Copyright (C) 2014 Blue Jeans Network
#

reify :gem_package, {
  name: 'kffpt'
}, [
  [ :touch, 'file[/tmp/expect/ini.conf]' ]
], :upgrade


directory '/tmp/expect'

raise 'Materialization failed!' unless \
  materialize(nil) == nil

raise 'Materialization failed!' unless \
  materialize('hello') == 'hello'

raise 'Materialization failed!' unless \
  materialize('hello %{world}', world: 'bob') \
    == 'hello bob'

raise 'Materialization failed!' unless \
  materialize_raw(%w[ %{one} %{two} %{three} ], one: 1, two: 2, three: 3) \
    == [ '1', '2', '3' ]

raise 'Materialization failed!' unless \
  materialize_raw(one: [ { one: '%{two}', two: 2 } ], two: '%{three}', three: 4) \
    == { one: [ { one: '2', two: 2 } ], two: '4', three: 4 }

reify :package, { name: 'htop' }

node.default['configurator']['test']['logstash']['input'] = {
  'test' => {
    'file' => {
      'path' => '/var/log/test.log'
    }
  }
}

node.default['configurator']['test']['logstash']['filter'] = {
  'test' => {
    'seq' => {}
  }
}

node.default['configurator']['test']['logstash']['output'] = {
  'test' => {
    'stdout' => {
      'codec' => 'rubydebug'
    }
  }
}

file '/tmp/expect/logstash.conf' do
  content logstash_config(node.default['configurator']['test']['logstash'])
end

file '/tmp/expect/logstash.conf.expect' do
  content %Q$
    input {
      file {
        path => "/var/log/test.log"
        type => "test"
      }
    }
    filter {
      if [type] == "test" {
        seq {
        }
      }
    }
    output {
      if [type] == "test" {
        stdout {
          codec => "rubydebug"
        }
      }
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['logstash_conditional_output'] = {
  'input' => {},
  'filter' => {},
  'output' => {
    "if 'test' in [tags]" => {
      'this' => {
        'is' => 'good'
      }
    }
  }
}

file '/tmp/expect/logstash_conditional_output.conf' do
  content logstash_config(node.default['configurator']['test']['logstash_conditional_output'])
end

file '/tmp/expect/logstash_conditional_output.conf.expect' do
  content %Q$
    input {
    }
    filter {
    }
    output {
      if 'test' in [tags] {
        this {
          is => "good"
        }
      }
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['json'] = {
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil,
    {} => [],
    'deal' => /really/
  }
}

file '/tmp/expect/json.conf' do
  content json_config(node.default['configurator']['test']['json'])
end

file '/tmp/expect/json.conf.expect' do
  content %Q$
    {
      "this": {
        "is": [
          "just",
          "a",
          "FREEFORM"
        ],
        "10": null,
        "{}": [

        ],
        "deal": "(?-mix:really)"
      }
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['java'] = {
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil
  }
}

file '/tmp/expect/java.conf' do
  content java_config(node.default['configurator']['test']['java'])
end

file '/tmp/expect/java.conf.expect' do
  content %Q$
    this {
      is = [ "just", a, "FREEFORM" ]
      10 = nil
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['exports'] = {
  'this' => nil,
  'is' => 10,
  'a' => :nother,
  'test' => 1234
}

file '/tmp/expect/exports.conf' do
  content exports_config(node.default['configurator']['test']['exports'])
end

file '/tmp/expect/exports.conf.expect' do
  content %Q$
    export this=''
    export is=10
    export a=nother
    export test=1234
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['ini'] = {
  'this' => {
    'is' => 'just',
    'a' => 'test'
  }
}

file '/tmp/expect/ini.conf' do
  content ini_config(node.default['configurator']['test']['ini'])
end

file '/tmp/expect/ini.conf.expect' do
  content %Q$
    [this]
    is=just
    a=test
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['yaml'] = {
  'this' => {
    'is' => 'just',
    'a' => 'test'
  }
}

file '/tmp/expect/yaml.conf' do
  content yaml_config(node.default['configurator']['test']['yaml'])
end

file '/tmp/expect/yaml.conf.expect' do
  content %Q$
    ---
    this:
      is: just
      a: test
  $.strip.gsub(/^    /, '')
end