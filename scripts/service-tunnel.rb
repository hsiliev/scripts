#!/usr/bin/env ruby

require 'set'

app = ARGV[0] || 'abacus-housekeeper'
prefixed_app = "#{ENV['ABACUS_PREFIX']}#{app}"
puts "Using application #{prefixed_app}"

environment_variables = `cf env "#{prefixed_app}" | grep -E 'DB.*URI'`.split("\n")
raise "Cannot get environment for application #{prefixed_app}. Are you logged in Cloud Foundry?" unless $?.exitstatus.zero?

port = 27018

processed_uris = Set.new

def remove_trailing_and_leading(uri)
  uri.scan(/@.*\//).first[1..-2]
end

environment_variables.each do |variable|
  name, concatenated_uris = variable.split(': ')
  name = name[3..-5].downcase
  uris = concatenated_uris.split('|')

  puts "   Establishing tunnel #{name.empty? ? '' : "for #{name} "}..."

  uris.each do |uri|
    break if processed_uris.include?(uri)

    concatenated_addresses = remove_trailing_and_leading(uri)
    addresses = concatenated_addresses.split(',')

    addresses.each do |address|
      Process.spawn(%(cf ssh -N -T -L #{port}:#{address} "#{prefixed_app}"))
      sleep 10

      connection_string = "localhost:#{port}"
      master = `mongo #{connection_string} --quiet --eval "d=db.isMaster(); print( d['ismaster'] );"`.strip()
      port += 1

      next unless master == 'true'

      local_uri = uri.sub(concatenated_addresses, connection_string).split('?').first
      puts "      #{local_uri}"
      break
    end

    processed_uris << uri
  end
end
