require 'erb'
require 'fileutils'
require 'pathname'
require 'tempfile'

require 'hostess/templates/reverse_proxy'
require 'hostess/templates/directory'
require 'hostess/templates/ssl_reverse_proxy'

module Hostess
  
  autoload :Options,     'hostess/options'
  autoload :VirtualHost, 'hostess/virtual_host'
  
  class OptionsError < StandardError; end

  class << self
    
    attr_writer :apache_config_dir, :apache_log_dir
    
    def script_name
      'hostess'
    end
    
    def apache_config_dir
      @apache_config_dir || File.join('/', 'etc', 'apache2')
    end
    
    def apache_config
      File.join(apache_config_dir, 'httpd.conf')
    end
    
    def vhosts_dir
      on_debian? ?
        File.join('/', apache_config_dir, "sites-available") :
        File.join(apache_config_dir, "#{script_name}_vhosts")
    end
    
    def apache_log_dir
      @apache_log_dir || File.join('/', 'var', 'log', 'apache2')
    end
    
    def vhosts_log_dir(domain=nil)
      on_debian? ?
        File.join(apache_log_dir, domain) :
        File.join(apache_log_dir, "#{script_name}_vhosts")
    end

    def hosts_filename
      File.join('/', 'etc', 'hosts')
    end
    
    def disable_sudo!
      @disable_sudo = true
    end
    
    def use_sudo?
      @disable_sudo ? false : true
    end
    
    def on_debian?
      File.directory? File.join('/', apache_config_dir, "sites-available")
    end

  end
  
end