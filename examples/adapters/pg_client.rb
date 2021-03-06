# frozen_string_literal: true

require 'bundler/setup'
require 'polyphony/adapters/postgres'

def get_records
  $db.query('select 1 as test')
  # puts "got #{res.ntuples} records: #{res.to_a}"
rescue StandardError => e
  puts "got error: #{e.inspect}"
  puts e.backtrace.join("\n")
end

time_printer = spin do
  last = Time.now
  throttled_loop(10) do
    now = Time.now
    puts now - last
    last = now
  end
end

$db = PG.connect(
  host:     '/tmp',
  user:     'reality',
  password: nil,
  dbname:   'reality',
  sslmode:  'require'
)

X = 10_000
t0 = Time.now
X.times { get_records }
puts "query rate: #{X / (Time.now - t0)} reqs/s"

time_printer.stop
