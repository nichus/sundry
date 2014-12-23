libs = %W(
            #{File.dirname(__FILE__)}/mrsh_settings.rb
            #{File.dirname(__FILE__)}/mrsh_reporter.rb
          )

libs.each {|lib| require lib}

require 'resolv'

class Machine
  def initialize(host,config)
    @host   = host
    @config = config
    
    @host.hostname = @host.hostname.gsub(/\..*$/,'') # This might not make sense in the general use case
  end
  def ==(b)
    return @host.hostname == b.hostname
  end
  def <=>(b)
    return @host.hostname <=> b.hostname
  end
  def process
    resolve or return
    
    ping?   or return
    
    execute if rpc?
  end
  def resolve
    @host.ip        = Resolv.getaddress @host.hostname
  rescue Resolv::ResolvError => e
    @host.ip        = nil
    @host.status    = :nodns
  ensure
    @host.resolved  = @host.ip.nil? ? false : true
  end
  def ping?
    @host.online  = false
    @host.status  = :offline
    
    command = sprintf @config.ping, @host.hostname
    output  = %x( #{command} ).chomp
    status  = ($?.exitstatus == 0)
    
    if (status)
      @host.online      = true
      @host.status      = :online
    elsif (output.match(/no answer from/) or output.match(/ 0( packets)? received,/))
      # Handled by default values
    elsif (output.match(/unknown host/)
      @host.resolved    = false
      @host.status      = :nodns
    else
      @host.ping_output = output.split.chomp
    end
    
    return @host.online
  end
  def execute
    @host.output  = Array.new
    flags         = '-T -o BatchMode=yes -nq'
    
    return unless @config.command
    
    begin
      Timeout::timeout(@config.timeout) do
        IO.popen(%Q{ssh #{flags} #{@host.hostname} "#{config.command}" 2>&1, "r") do |pipe|
          while (line = pipe.gets) do
            @host.output.push [ Time.now, line.chomp ]
          end
          pipe.close
          @host.returncode = $?.exitstatus
        end
      end
    rescue Timeout::Error
      @host.returncode = 999
      @host.output.push [ Time.now, "-- Timeout encountered, command did not return within #{@config.timeout} seconds -- " ]
    rescue Exception => e
      @host.returncode = 998
      @host.output.push [ Time.now, " Exception: #{ e }" ]
      e.backtrace.each do |line|
        @host.output.push [ Time.now, line ]
      end
    end
  end
  def rpc?
    not @host.os.match(/Windows/Firmware/ESXi/i)
  end
  def method_missing(func,*args,&block)
    @host.send(func,*args,&block)
  end
end
