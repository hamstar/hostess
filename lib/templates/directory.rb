module Hostess
  module Template
    class Directory
      def erb(options)
        domain, directory = options.domain, options.directory
<<-EOT
<VirtualHost *:80>
  ServerName <%= domain %>
  DocumentRoot "<%= directory %>"
  <Directory "<%= directory %>">
    Options FollowSymLinks
    AllowOverride All
    allow from all
  </Directory>
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