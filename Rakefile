# This is free and unencumbered software released into the public domain.

require 'yaml'

def each_symbol
  metadata = YAML.load(File.read('etc/symbols.yaml'))
  File.open('etc/symbols.txt').each_line do |line|
    symbol = line.chomp.to_sym
    yield symbol, metadata[symbol.to_s]
  end
end

task default: %w(symbols)

task :symbols do
  each_symbol { |s, _| puts s }
end

file "README.md" => %w(etc/symbols.txt etc/symbols.yaml) do |t|
  head = File.read(t.name).split("### Supported Clarity features\n", 2).first
  File.open(t.name, 'w') do |file|
    file.puts head
    file.puts "### Supported Clarity features"
    file.puts
    file.puts ["Symbol", "Type", "JavaScript", "WebAssembly"].join(' | ')
    file.puts ["------", "----", "----------", "-----------"].join(' | ')
    each_symbol do |symbol_name, symbol_types|
      next if symbol_types.nil?
      symbol_types.each do |symbol_type, symbol_info|
        sworn = symbol_info['implementations']['sworn']
        sworn_js = sworn['js']
        sworn_wasm = sworn['wasm']
        file.puts [
          "`#{symbol_name}`",
          symbol_type,
          sworn_js ? "✅" : "",
          sworn_wasm ? "✅" : "",
        ].join(' | ').strip
      end
    end
  end
end
