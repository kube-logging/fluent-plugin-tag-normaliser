#
# Copyright 2019- tarokkk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

module Fluent
  module Plugin
    class TagNormaliserOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("tag_normaliser", self)

      helpers :event_emitter, :record_accessor

      # Define configuration
      desc 'Format to rewrite tag to.'
      config_param :format, :string
      desc 'Prefix accessors. Default: .kubernetes'
      config_param :key_prefix, :string, :default => "kubernetes"
      desc 'Default fallback value'
      config_param :unknown, :string, :default => "unknown"

      def configure(conf)
        super
        @key_accessors = get_key_accessors
      end

      def process(tag, es)
        es.each do |time, record|
          new_tag = render_tag(record)
          router.emit(new_tag, time, record)
        end
      end

      def render_tag(record)
        new_tag = @format.dup
        @key_accessors.each do |placeholder, accessor|
          value = accessor.call(record).to_s
          if value.empty?
            value = @unknown
          end
          new_tag = new_tag.gsub(placeholder, value)
        end
        return new_tag
      end

      def get_key_accessors
        key_accessors = {}
        keywords = @format.scan(/\$\{([\w\.\/\-]+)}/)
        keywords.each do |key|
          placeholder = "${#{key[0]}}"
          if @key_prefix != ""
            path = @key_prefix + "." + key[0]
          else
            path = key[0]
          end
          path = "$." + path
          key_accessors[placeholder] = record_accessor_create(path)
        end
        return key_accessors
      end

    end
  end
end
