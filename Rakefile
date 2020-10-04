# This is free and unencumbered software released into the public domain.

require 'yaml'
require 'active_support/core_ext/hash'  # `gem install activesupport`

# @return [Hash<Symbol, Hash>]
def implemented_features
  YAML.load_file('etc/features.yaml').deep_symbolize_keys!
end

# @return [Array<Symbol>]
def standard_features
  File.open('etc/features.txt').each_line.map { |line| line.chomp.to_sym }.sort
end

# @return [Hash<Symbol, Hash>]
def status_of_features
  standard_features.inject({}) do |result, feature_name|
    result[feature_name] = implemented_features[feature_name]
    result
  end
end

# @param  [Object] status
# @return [String]
def status_icon(status)
  case status
    when true, 'runtime' then "✅"
    when 'wip' then "🚧"
    when false then "❎"
    else ''
  end
end

task default: %w(features:todo)

namespace :features do
  task :all do
    (implemented_features.keys + standard_features).uniq.each { |f| puts f }
  end
  task :std do
    standard_features.each { |f| puts f }
  end
  task :nonstd do
    (implemented_features.keys - standard_features).each { |f| puts f }
  end
  task :done do
    implemented_features.keys.each { |f| puts f }
  end
  task :todo do
    (standard_features - implemented_features.keys).each { |f| puts f }
  end
end

file "README.md" => %w(etc/features.txt etc/features.yaml) do |t|
  head = File.read(t.name).split("### Supported Clarity features\n", 2).first
  File.open(t.name, 'w') do |file|
    file.puts head
    file.puts "### Supported Clarity features"
    file.puts
    file.puts ["Feature", "Type", "JavaScript", "WebAssembly", "Notes"].join(' | ')
    file.puts ["-------", "----", "----------", "-----------", "-----"].join(' | ')
    status_of_features.each do |feature_name, feature_types|
      next if feature_types.nil?
      feature_types.each do |feature_type, feature_info|
        feature_link = feature_info[:link] || '#'
        sworn = feature_info[:implementations][:sworn]
        sworn_js = sworn[:js]
        sworn_wasm = sworn[:wasm]
        next if sworn_js.nil? && sworn_wasm.nil?
        file.puts [
          "[`#{feature_name}`](#{feature_link})",
          feature_type,
          status_icon(sworn_js),
          status_icon(sworn_wasm),
          case sworn_js
            when 'runtime' then "Requires Clarity.js."
            when false then "Not supported."
            else ""
          end
        ].join(' | ').strip
      end
    end
    file.puts
    file.puts "**Legend**: ❌ = not supported. 🚧 = work in progress. ✅ = supported."
  end
end
