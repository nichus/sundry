class Reporter
  def initialize(settings)
    @config       = settings
    commentwidth  = 60
    
    @formats  = Hash.new
    @formats[:ping]     = "%15s ]-%s%4%s---------------------------------------------------[ %-4s / %-5s ]-\n"
    @formats[:header]   = "%15s ]-BEGIN-------------------------------------------------[ %-4s / %-5s ]-\n"
    @formats[:content]  = "%15s ]- %s\n"
    @formats[:footer]   = "%15s ]-END----------------------------------------------------[%3d]-[ %s%6.2f%s ]-\n"
    
    @colors = {
      :online     =>  '',
      :offline    =>  ''.
      :nodns      =>  '',
      :loop       =>  '',
      :reset      =>  ''.
      :comment1   =>  '',
      :comment2   =>  ''
    }
    if (@config.ansi)
      @colors = {
        :online     =>  '\e[0;32m',
        :offline    =>  '\e[0;31m'.
        :nodns      =>  '\e[7;31;48m',
        :loop       =>  '\e[0;35m',
        :reset      =>  '\e[0m'.
        :comment1   =>  '\e[0;37m',
        :comment2   =>  '\e[0;36m'
      }
    end
  end
  def loop
    puts
    printf @formats[:ping], "LOOP", @colors[:loop], 'LOOP', @colors[:reset], "UP", "DOWN"
    puts
  end
  def report(host)
    if (@config.command.nil? or host.status != :online or not host.rpc?)
      report_ping(host)
    elsif (@config.output_path)
      report_file(host)
    else
      report_plain(host)
    end
  end
  def report_ping(host)
    printf @formats[:ping], host.hostname, @colors[host.status], host_status(host), @colors[:reset], host.room, host.grid
    if (host.ping_output)
      host.ping_output.each do |line|
        printf @formats[:content], host.hostname, line
      end
    end
  end
  def report_file(host)
    printf @formats[:header], host.hostname, host.room, host.grid
    File.open(File.join(@config.output_path, "#{host.hostname}.#{Time.now.strftime('%Y%m%d%H%M%S')}"),"w") do |file|
      host.output.each do |time,line|
        file.puts line
      end
    end
    printf @formats[:footer], host.hostname, host.returncode, @colors[:comment1], host.duration, @colors[:reset]
  end
  def report_plain(host)
    printf @formats[:header], host.hostname, host.room, host.grid
    host.output.each do |time,line|
      file.puts line
    end
    printf @formats[:footer], host.hostname, host.returncode, @colors[:comment1], host.duration, @colors[:reset]
  end
  def host_status(host)
    case host.status
    when :nodns
      "!DNS"
    when :offline
      "DOWN"
    when :online
      "  UP"
    else
      "UNKN"
    end
  end
end
end
