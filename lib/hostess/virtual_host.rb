module Hostess
  class VirtualHost
    def initialize(options, debug=false)
      @options, @debug = options, debug
    end
    def execute!
      __send__(@options.action)
    end
    def create
      setup_apache_config
      create_vhost_directory
      create_vhost_log_directory
      create_dns_entry
      create_vhost
      restart_apache
    end
    def delete
      delete_dns_entry
      delete_vhost
      delete_vhost_log_directory
      restart_apache
    end
    def log
      log_file = File.join(vhost_log_directory, '#{@options.level}_log')
      system "less #{log_file}"
    end
    def list
      Dir[File.join(Hostess.vhosts_dir, '*.conf')].each do |config_file|
        puts File.basename(config_file, '.conf')
      end
    end
    def show
      puts File.read(config_filename)
    end
    def help
      @options.display_banner_and_return
    end
    private
      def dscl_works?
        `sw_vers -productVersion`.strip < '10.7'
      end
      def create_dns_entry
        if dscl_works?
          run "dscl localhost -create /Local/Default/Hosts/#{@options.domain} IPAddress 127.0.0.1"
        else
          hosts_filename = Hostess.hosts_filename
          run "echo '127.0.0.1 #{@options.domain}' >> #{hosts_filename}"
        end
      end
      def delete_dns_entry
        if dscl_works?
          run "dscl localhost -delete /Local/Default/Hosts/#{@options.domain}"
        else
          hosts_filename = Hostess.hosts_filename
          run "perl -pi -e 's/127.0.0.1 #{@options.domain}\\n//g' #{hosts_filename}"
        end
      end
      def create_vhost
        tempfile = Tempfile.new('vhost')
        tempfile.puts(vhost_config)
        tempfile.close
        run "mv #{tempfile.path} #{config_filename}"
      end
      def delete_vhost
        run "rm #{config_filename}"
      end
      def vhost_log_directory
        Hostess.vhosts_log_dir @options.domain
      end
      def create_vhost_log_directory
        run "mkdir -p #{vhost_log_directory}" unless File.directory? vhost_log_directory
      end
      def delete_vhost_log_directory
        run "rm -r #{vhost_log_directory}" if File.directory? vhost_log_directory
      end
      def vhost_config
        template = case @options.type
          when :ssl_reverse_proxy
            Template::SSLReverseProxy.erb(@options)
          when :reverse_proxy
            Template::ReverseProxy.erb(@options)
          when :directory
            Template::Directory.erb(@options)
          else
            raise OptionsError, "Could not determine VirtualHost type"
          end
        ERB.new(template).result(binding)
      end
      def config_filename
        File.join(Hostess.vhosts_dir, "#{@options.domain}.conf")
      end
      def setup_apache_config
        unless File.read(Hostess.apache_config).include?("Include #{File.join(Hostess.vhosts_dir, '*.conf')}")
          run "echo '' >> #{Hostess.apache_config}"
          run "echo '' >> #{Hostess.apache_config}"
          run "echo '# Line added by #{Hostess.script_name}' >> #{Hostess.apache_config}"
          run "echo 'NameVirtualHost *:80' >> #{Hostess.apache_config}"
          run "echo 'Include #{File.join(Hostess.vhosts_dir, '*.conf')}' >> #{Hostess.apache_config}"
        end
      end
      def create_vhost_directory
        run "mkdir -p #{Hostess.vhosts_dir}" unless File.directory? Hostess.vhosts_dir
      end
      def restart_apache
        run "apachectl restart"
      end
      def run(cmd)
        cmd = sudo(cmd) if Hostess.use_sudo?
        puts cmd if @debug
        system cmd
      end
      def sudo(cmd)
         "sudo -s \"#{cmd}\""
      end
  end
end
