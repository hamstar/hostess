module Hostess
  module Template
    class SSLReverseProxy
      def erb(options)
        domain, path, url = options.domain, options.path, options.url
<<-EOT
<VirtualHost *:80>
  ServerName <%= domain %>
  ProxyPass <%= path %> <%= url %>
  ProxyPassReverse / <%= url %>
  <DirectoryMatch "^/.*/\.svn/">
    ErrorDocument 403 /404.html
    Order allow,deny
    Deny from all
    Satisfy All
  </DirectoryMatch>
  ErrorLog <%= File.join(apache_log_directory, 'error_log') %>
  CustomLog <%= File.join(apache_log_directory, 'access_log') %> common
  #RewriteLogLevel 3
  RewriteLog <%= File.join(apache_log_directory, 'rewrite_log') %>
</VirtualHost>
EOT
      end
    end
  end
end