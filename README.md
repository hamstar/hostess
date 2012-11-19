# Hostess

**This code has been modified from the original and is as yet untested and should be considered beta code.**

A simple tool for adding local directories as virtual hosts in a local apache installation. It probably only works well on a Mac, but we're scratching our own itch here.

## Usage

    $ hostess help
    Usage: hostess <action> <domain> <directory|url> [path]
    hostess create domain directory - create a new virtual host
    hostess create domain url path  - create a new reverse proxy virtual host
    hostess delete domain           - delete a virtual host
    hostess list                    - list #{Hostess.script_name} virtual hosts
    hostess help                    - this info

### Directory virtual hosts

    $ hostess create mysite.local /Users/myuser/Sites/mysite

This will create a new virtual host in your Apache configuration, setup your Mac's DNS to respond to that domain name, and restart Apache to make the new virtual host live.

### Reverse proxy virtual hosts

    $ hostess create mysite.local http://www.startpage.com

This will make a new virtual host in Apache that will show StartPage.

    $ hostess create mysite.local http://www.startpage.com /start

This will make new virtual host at mysite.local/start that will show StartPage.

### Show virtual host logs

For viewing log files you can use the log command: `hostess log domain level`.

    $ hostess log my.site 				# shows the error log by default
    $ hostess log my.site.com error		# shows the error log
    $ hostess log my.site.com e 		# shows the error log
    $ hostess log my.site.com a 		# shows the access log
    $ hostess log my.site.com r 		# shows the rewrite log

The above commands make it easier to view virtual host logs.  Omitting the level arguments defaults to showing the error log.  Otherwise you can use rewrite/r, error/e or access/a.  Easy!

## TODO

* Get this working on debian.
