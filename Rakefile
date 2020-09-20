# This is free and unencumbered software released into the public domain.

require 'yaml'

def each_feature
  metadata = YAML.load(File.read('etc/features.yaml'))
  File.open('etc/features.txt').each_line do |line|
    feature = line.chomp.to_sym
    yield feature, metadata[feature.to_s]
  end
end

task default: %w(features)

task :features do
  each_feature { |s, _| puts s }
end

file "README.md" => %w(etc/features.txt etc/features.yaml) do |t|
  head = File.read(t.name).split("### Supported Clarity features\n", 2).first
  File.open(t.name, 'w') do |file|
    file.puts head
    file.puts "### Supported Clarity features"
    file.puts
    file.puts ["Feature", "Type", "JavaScript", "WebAssembly"].join(' | ')
    file.puts ["-------", "----", "----------", "-----------"].join(' | ')
    each_feature do |feature_name, feature_types|
      next if feature_types.nil?
      feature_types.each do |feature_type, feature_info|
        sworn = feature_info['implementations']['sworn']
        sworn_js = sworn['js']
        sworn_wasm = sworn['wasm']
        next if !sworn_js && !sworn_wasm
        file.puts [
          "`#{feature_name}`",
          feature_type,
          sworn_js ? "✅" : "",
          sworn_wasm ? "✅" : "",
        ].join(' | ').strip
      end
    end
  end
end
