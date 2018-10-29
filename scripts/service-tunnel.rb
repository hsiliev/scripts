#!/usr/bin/env ruby

require 'set'

app = ARGV[0] || 'abacus-housekeeper'
puts "Using application #{ENV['ABACUS_PREFIX']}#{app}"

environment_variables = %x[ cf env "#{ENV['ABACUS_PREFIX']}#{app}" | grep -E 'DB_.*_URI' ].split("\n")

port = 27018

processed_uris = Set.new

environment_variables.each { |variable|
  name, concatenated_uris = variable.split(": ")
  name = name[3..-5].downcase
  uris = concatenated_uris.split("|")

  puts "   Establishing tunnel for #{name} ..."

  uris.each { |uri|
    if processed_uris.include?(uri)
      break
    end

    concatenated_addresses = uri.scan(/@.*\//).first[1..-2] # remove leading and trailing chars
    addresses = concatenated_addresses.split(',')

    addresses.each { |address|
      Process.spawn(%Q(cf ssh -N -T -L #{port}:#{address} "#{ENV['ABACUS_PREFIX']}#{app}"))
      sleep 10

      connection_string = "localhost:#{port}"
      master = %x[ mongo #{connection_string} --quiet --eval "d=db.isMaster(); print( d['ismaster'] );" ].strip()
      port += 1

      if master == 'true'
        local_uri = uri.sub(concatenated_addresses, connection_string).split('?').first
        puts "      #{local_uri}"
        break
      end
    }

    processed_uris << uri
  }
}
