module Hostess
  class Options
    attr_reader :action, :domain, :directory, :path, :url, :type, :level
    def initialize(action=nil, domain=nil, directory=nil, path=nil)
      @action, @domain, @directory, @url, @level, @path = action, domain, directory, directory, directory, path
      @type = virtual_host_type
    end
    def directory
      File.expand_path(@directory) if @directory
    end
    def url
      @url =~ /^http:\/\//
    end
    def ssl_url
      @url =~ /^https:\/\//
    end
    def path
      @path ||= "/"
      @path = "/#{@path}" if @path !~ /^\//
      @path =~ /^\//
    end
    def level
      @level ||= "error"
      
      # allow single letter
      case @level
      when "e"
        @level = "error"
      when "a"
        @level = "access"
      when "r"
        @level = "rewrite"
      end

      @level =~ /access|error|rewrite/
    end

    def display_banner_and_return
      puts banner
      exit
    end
    def valid?
      valid_create_directory? or 
      valid_delete? or 
      valid_list? or 
      valid_help? or 
      valid_create_ssl_reverse_proxy? or 
      valid_create_reverse_proxy? or
      valid_log? or
      valid_show?
    end
    def virtual_host_type
      case
      when valid_create_reverse_proxy?
        :reverse_proxy
      when valid_create_ssl_reverse_proxy?
        :ssl_reverse_proxy
      when valid_create_directory?
        :directory
      end
    end
    private
      def valid_create_reverse_proxy?
        @action == 'create' and @domain and url and path
      end
      def valid_create_ssl_reverse_proxy?
        @action == 'create' and @domain and ssl_url and path
      end
      def valid_create_directory?
        @action == 'create' and @domain and directory
      end
      def valid_delete?
        @action == 'delete' and @domain
      end
      def valid_log?
        @action == 'log' and @domain and level
      end
      def valid_list?
        @action == 'list'
      end
      def valid_show?
        @action == "show" and @domain
      end
      def valid_help?
        @action == 'help'
      end
      def banner
<<EndBanner
  Usage: #{Hostess.script_name} <action> [<domain> <directory|url|level> [path]]
    #{Hostess.script_name} create domain directory - create a new virtual host
    #{Hostess.script_name} create domain url path  - create a new reverse proxy virtual host
    #{Hostess.script_name} delete domain           - delete a virtual host
    #{Hostess.script_name} log domain level        - show log file of level (error,access,rewrite) for domain
    #{Hostess.script_name} show domain             - dump the virtual host config
    #{Hostess.script_name} list                    - list #{Hostess.script_name} virtual hosts
    #{Hostess.script_name} help                    - this info
EndBanner
      end
  end
end