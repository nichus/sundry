require 'net/http'
require 'json'
require 'csv'

hwdb_online_url = "http://localhost/mrsh/online.json"

class Settings
  attr_reader :max_threads, :timeout, :ping, :ansi, :repeat, :command, :output_path
  def initialize
    @max_threads  = 10
    @timeout      = 10
    @ping         = determinePing
    @ansi         = true
    @repeat       = false
    @hwdb_online  = JSON.parse(Net::HTTP.get(URI(hwdb_online_url)))['status']
    
    help          = nil
    short_help    = true
    time          = Time.now
    revision      = File.ctime(__FILE__).strftime('%Y%m%d.%H%M%S')
    
    @audit_file   = findAuditFile
    @organization = DCS
    
    opts  = GetoptLong.new(
                            [ "--block-filter",     "-B",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--command",          "-c",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--help",             "-e",   GetoptLong::NO_ARGUMENT ],
                            [ "--audit_file",       "-f",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--force",                    GetoptLong::NO_ARGUMENT ],
                            [ "--function-filter",  "-F",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--organization",     "-g",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--host-filter",      "-h",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--loop",             "-l",   GetoptLong::NO_ARGUMENT ],
                            [ "--machines",         "-m",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--os-filter",        "-o",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--output-path",      "-O",   GetoptLong::OPTIONAL_ARGUMENT ],
                            [ "--ping-only",        "-p",   GetoptLong::NO_ARGUMENT ],
                            [ "--room-filter",      "-R",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--scripted",         "-s",   GetoptLong::NO_ARGUMENT ],
                            [ "--max-threads",      "-t",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--timeout",          "-T",   GetoptLong::REQUIRED_ARGUMENT ],
                            [ "--exclude-quiet",    "-x",   GetoptLong::NO_ARGUMENT ],
                            [ "--command-file",     "-z",   GetoptLong::REQUIRED_ARGUMENT ]
                          )
    
    opts.each do |opt,arg|
      case opt
      when '--command'
        @command            = arg
        short_help          = false
      when '--command-file'
        @command_file       = arg
        short_help          = false
      when '--machines'
        @machine_list       = arg.split(/,/)
      when '--host-filter'
        @host_filter        = arg
      when '--os-filter'
        @os_filter          = arg
      when '--organization'
        @organization       = arg
      when '--block-filter'
        @block_filter       = arg
      when '--function-filter'
        @function_filter    = arg
      when '--room-filer'
        @room_filter        = arg
      when '--audit-file'
        @force_audit_fie    = File.expand_path(arg)
      when '--max-threads'
        @max_threads        = arg.to_i
      when '--timeout'
        @timeout            = arg.to_i
      when '--loop'
        @repeat             = true
      when '--force'
        @data.force         = true
      when '--ping-only'
        @command            = nil
        short_help          = false
      when '--scripted'
        @ansi               = false
      when '--exclude-quiet'
        @data.exclude_quiet = true
      when '--output-path'
        if arg.empty? then
          @output_path = "/tmp/mrsh.%s.%d" % [ time.strftime("%Y%m%d"), Process.pid ]
        else
          @output_path = File.expand_path(arg)
        end
      when '--help'
        help                = true
        short_help          = false
      else
        puts "Invalid argument #{opt}, shutting down"
        display_shorthelp
        exit
      end
    end
    
    if @command.nil? and @command_file then
      File.open(@command_file, "r") do |input|
        while line = input.gets
          line = line.chomp
          line = line.gsub(/\s*#.*$/,'')
          line = line.gsub(/\$/, '\$')
          line = line.gsub(/\`/) {|s| "\\#{s}"}
          next if line.empty?
          
          line = line.gsub(/"/,'\"')
          
          if @command.nil? then
            @command = line
          else
            @command = @command + ';' + line
          end
        end
      end
    end
    if help
      display_longhelp
      exit
    elsif short_help
      display_shorthelp
      exit
    end
    
    puts "mrsh (r#{revision}) run started at #{time}"
    if @output_path then
      puts "- Sending all output to files under: #{@output_path}/"
    end
  end
end
