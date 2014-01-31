#!/opt/chef/embedded/bin/ruby
#

require "cgi"
require "json"

def parse_json(filename)
  o = nil
  File.open(filename) do |f|
    o = JSON.parse(f.read)
  end
end
def find_host(opts,hostname)
  # Return a host object, formed from the json file in the first
  # matching machine configuration directory.
  host = nil
  machdir   = File.join(opts['machine_definitions'],hostname)
  machfile  = File.join(opts['machine_definitions'],hostname,hostname+'.json')

  if Dir.exists?(machdir)
    if File.exists?(machfile)
      host = parse_json(machfile)
    end
  end

  host
end

confdir = ".";
opts    = parse_json(confdir + '/ks.json')

cgi = CGI.new

clientip    = cgi.remote_addr
clientname  = cgi.remote_host
clientarch  = ENV['X-Anaconda-Architecture']

clientname  ||= 'temari'

host = find_host(opts,clientname)

puts cgi.header("text/plain")

node = parse_json(opts['machine_definitions']+'/'+clientname+'/'+clientname+'.json')
site = parse_json(opts['machine_definitions']+'/common/'+node['site']+'/site.json')

puts "node"
p node
puts "site"
p site

node = site.merge(node)
puts "updated node"
p node

rhel_oes    = node['run_list'].select(/RHEL/i)
server      = rhel_oes.select(/server/i)
workstation = rhel_oes.select(/workstation|desktop/i)

if cgi.has_key?('validate')
  puts "Running reprovision script, just validate the configuration and return if valid"
else
  puts "Someone is actually asking for the kickstart configuration file, fetch it"
end
