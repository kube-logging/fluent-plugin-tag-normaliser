#
# Copyright 2019- Banzai Cloud
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
      desc "Sticky tags will match only one record from an event stream. The same tag will be treated the same way"
      config_param :sticky_tags, :bool, default: true
      def configure(conf)
        super
        @key_accessors = get_key_accessors
        @tag_map = Hash.new { |k, v| k[v] = "" }
      end

      def multi_workers_ready?
        true
      end

      def process(tag, es)
        if @sticky_tags
          if @tag_map.has_key?(tag)
            router.emit_stream(@tag_map[tag], es)
            return
          end
        end
        new_tag = ""
        es.each do |time, record|
          new_tag = render_tag(record)
          router.emit(new_tag, time, record)
        end
        if @sticky_tags
          @tag_map[tag] = new_tag
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
        keywords = @format.scan(/\$\{([\w\.\/\-\\]+)}/)
        keywords.each do |key|
          placeholder = "${#{key[0]}}"
          if contains_escaped_period?(key[0])
            path = create_path_with_bracket_notation(key[0])
          else
            path = create_path(key[0])
          end
          key_accessors[placeholder] = record_accessor_create(path)
        end
        return key_accessors
      end

      private

      def contains_escaped_period?(key)
        key.include?('\.')
      end

      def create_path(key)
        if @key_prefix != ""
          path = @key_prefix + "." + key
        else
          path = key
        end
        path = "$." + path
      end

      # Produces the output in bracket notation, e.g. $['kubernetes']['labels']['app.tier']"
      def create_path_with_bracket_notation(key)
        path = split_by_unescaped_dots(key)
                .map { |elem| "['#{elem}']" }
                .join("")
        if @key_prefix != ""
          path = "['#{@key_prefix}']" + path
        end
        path = "$" + path
      end

      # Splits the input string by the . character if it is not escaped by \
      def split_by_unescaped_dots(text)
        result = []
        current_part = ""
        escaped = false

        text.each_char do |char|
          if char == "\\" && !escaped
            escaped = true
          elsif char == "." && !escaped
            result << current_part
            current_part = ""
          else
            current_part += char
            escaped = false
          end
        end

        result << current_part
        result
      end

    end
  end
end
