#!/usr/bin/env ruby
# A_ruby.rb - Ruby Step A
# This script reads an input file, performs a transformation, and writes an
# intermediate JSON output to be consumed by MATLAB Step B.
#
# USAGE:
#   ruby A_ruby.rb --input path/to/input.ext --output path/to/output_dir \
#       --threshold 0.5 --max_iter 100 --seed 42
#
# NOTE:
#   - Do NOT hardcode any file paths or parameters here.
#   - All user-adjustable values must come from CLI options.

require 'optparse'
require 'json'
require 'fileutils'
require 'securerandom'

options = {
  input: nil,
  output: nil,
  threshold: 0.5,
  max_iter: 100,
  seed: 42
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby A_ruby.rb --input INPUT --output OUTDIR [options]"

  opts.on("--input PATH", String, "Path to input file (required)") { |v| options[:input] = v }
  opts.on("--output DIR", String, "Output directory (required)") { |v| options[:output] = v }

  opts.on("--threshold FLOAT", Float, "Threshold parameter (default: 0.5)") { |v| options[:threshold] = v }
  opts.on("--max_iter INT", Integer, "Max iteration parameter (default: 100)") { |v| options[:max_iter] = v }
  opts.on("--seed INT", Integer, "Random seed (default: 42)") { |v| options[:seed] = v }

  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  warn e.message
  warn parser
  exit 1
end

# Validate required options
abort("ERROR: --input is required") if options[:input].nil? || options[:input].empty?
abort("ERROR: --output is required") if options[:output].nil? || options[:output].empty?

abort("ERROR: Input file not found: #{options[:input]}") unless File.file?(options[:input])
FileUtils.mkdir_p(options[:output])

# --- Your algorithm here ---
# Example placeholder: produce a small JSON object derived from inputs.
srand(options[:seed])
example_metrics = {
  "threshold" => options[:threshold],
  "max_iter"  => options[:max_iter],
  "seed"      => options[:seed],
  "random_id" => SecureRandom.hex(8),
  "note"      => "Replace this block with the real computation."
}

# Write intermediate JSON for MATLAB step B to consume
out_path = File.join(options[:output], "ruby_output.json")
File.write(out_path, JSON.pretty_generate(example_metrics))
puts "[A_ruby] Wrote: #{out_path}"
