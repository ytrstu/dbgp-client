# Introduction #
The php debugger follows a client-server model, that allows for remote debugging. php with xdebug extension is the debug server (or the remote side), Vim with DBGpClient  plugin si the debug client (or local side). See [concept model](http://vim.wikia.com/wiki/User:Terminatorul/Vim_DBGp_client_for_debugging_php_with_XDebug_extension) for an introduction.

These instructions assume you are somewhat familiar with php and with Vim.

# Short version #
1. Download and install [XDebug](http://www.xdebug.org/download.php) php extension for your version of php.

2. Add
```
    zend_extension=/path/to/php/ext/dir/xdebug.so

    [XDebug]
    xdebug.remote_enable On
    xdebug.remote_connect_back On
```
to php.ini (or to one of your php.ini files).

3. Download and install [python2](http://www.python.org/download/), [Vim](http://www.vim.org/download.php) with +python and Vim [DBGpClient](http://www.vim.org/scripts/script.php?script_id=4009) plugin.

4. To start a debugging session pres F5 or Ctrl+Shift+F5 in Vim, and either:
  * run the php script with XDEBUG\_CONFIG=ide-key=vim in front of the php command line
  * browse to your php web page and add ?XDEBUG\_SESSION\_START=1 to the end of the page URL.

The long version is the rest of this document.

# Server setup #
To debug your scripts with php, you need the Xdebug extension installed and enabled in php. On Linux systems you can usually (but not always) use the package manager specific to your distribution to install it, like
```
     sudo apt-get install --install-suggests php5-xdebug
```
If you have such a command and package available for your system, it can save you from running through a few of the next steps from these instructions.

On Windows I believe you might also find some AMP (Apache-mysql-php) package that includes xdebug. In that case, you may skip the following download section. Notice that on Windows php installation directory is not normally added to PATH, so now would be a good time to add it there. Right click on Computer and go to Properties | System | Advanced | Environment Variables, than exit the currently open cmd.exe windows you might have.

## Download XDebug php extension ##

You can download [XDebug](http://www.xdebug.org/) from the [XDebug downloads](http://www.xdebug.org/download.php). Notice that XDebug is a "Zend extension" unlike the other regular "php extensions". On Linux systems you may even need to compile xdebug from sources, in which case you will need the php development headers, or the php5-dev package (or similar), especially for the `phpize` command. For Windows systems you can normally find binary packages already available, although compilation is of course still an option.

## Open php.ini file ##
After downloading the extension, you need to add it to php.ini file and enable it. Use a command like:
```
     php --ini
```
to see what ini file your current php installation is reading. If you use php for web pages, it is possible (but  unlikely) for php to read some other ini files when serving web pages, than when invoked from the command line. To be sure, you should create a `/phpinfo.php` file on your web server next to your other php sources, and check the resulting output. The content of that page should be:
```
<?php
     phpinfo();
?>
```
Either way, you should open the php.ini file that you find (or one of the files), or create a new one and make sure it the being included from the main php.ini file.
## Enable xdebug in php.ini ##
Make sure one of your php.ini files includes a line like:
```
zend_extension=/usr/lib/php5/20100525/xdebug.so
```
or simply add such a line. Replace the path name above with the path to the xdebug extension you downloaded or that you have installed.
That will make sure the extension is loaded by your php. Next to enable the extensions include the following settings in php.ini:
```
[xdebug]
xdebug.remote_enable = On
xdebug.remote_connect_back = On
```

_Warning_: Debugging should only be enabled on development computers and servers. Real web servers (production servers) should be restricted to offer only the access needed by your users and visitors.

## Display the new settings ##
You can now display the new extension in the list of modules loaded by php, and xdebug settings in the list of effective settings there read from the php.ini files, with the following commands:
```
adrian@adrian-OptiPlex-790:~/projects$ php -m | grep -i xdebug
xdebug
Xdebug
adrian@adrian-OptiPlex-790:~/projects$ php -ddate.timezone='GMT' -i | grep xdebug.remote_
xdebug.remote_autostart => Off => Off
xdebug.remote_connect_back => On => On
xdebug.remote_cookie_expire_time => 3600 => 3600
xdebug.remote_enable => On => On
xdebug.remote_handler => dbgp => dbgp
xdebug.remote_host => localhost => localhost
xdebug.remote_log => no value => no value
xdebug.remote_mode => req => req
xdebug.remote_port => 9000 => 9000
adrian@adrian-OptiPlex-790:~/projects$ 

```
For Windows you should replace the `grep` command with the equivalent `findstr` command.

For web pages you should just check your phpinfo page instead of using these commands, and search for xdebug.remote\_enable and xdebug.remote\_connect\_back.

# Client setup #
You need
  * python2,
  * Vim
  * DBGpClient plugin for Vim.
  * (optional) an web browser add-on to assist with starting a debugging session for your web page.
You can download these from:
  * http://www.python.org/download/
  * http://www.vim.org/download.php
  * http://www.vim.org/scripts/script.php?script_id=4009
On Linux, python and Vim can also be installed with the package manager for your system, and should normally be installed there by default.

For Vim you should have the +python feature enabled, for Vim to be able to load python. Most Vim distributions already have it, and you can see it with the vim `:version` or `:echo has('python')` commands. For some technical reasons if you use `'paste'` mode in Vim (like in your `~/.vimrc`) the debugger will not be able to evaluate expressions. In this case use `:set nopaste` in Vim.

The DBGpClient plugin for Vim can currenty support only local debugging, but that should change in the next version, to support remote debugging. To debug remote php servers, you may as a workaround ensure that the path to the php source files is the same on both client and server machines. You can use symlinks, on both Windows and Linux systems, to achieve that effect. But on Windows, for Windows 7 you need elevated privileges to use `mklink` commnad, and on Windows XP you need to install the [Link Shell Extension](http://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html) also and the symbolic link drivers found there.

You can also find some other Vim plugin that already supports remote debugging, or you can find another DBGpClient that supports it, unrelated to Vim. You can see a list of clients on [XDebug](http://www.xdebug.org/docs/remote) web site.

The plugin also has a number of other settings, see the downloaded plugin source file `plugin/DBGpClient.vim` for a list.

You might also need to open the debugging port, 9000, in your firewall, so that the server and the client can connect through it.

# Starting a debugging session #
You need two steps for a new debug session:
  * start listening for new connections in the debug client (Vim)
  * start a new debugging session with php.

Note that here the debug server (php) is the one that starts connection to the debug client (Vim), and not the other way around as you might expect in a client-server environment.

First, start a new Vim window and press `<F5>` to start a debug session.  The default key settings can be changed (recommended) to use for example `<C-S-F5>`.  Vim will display a message that it will listen for 5 seconds for new incoming connections.

To start a php script and have php connect to the debugging client, you should:
  * for command line scripts: set XDEBUG\_CONFIG on the command line before you start the php script
    * Windows:
```
               Set XDEBUG_CONFIG=ide-key=Vim
               php ./script-name.php args...
```
    * Linux
```
               XDEBUG_CONFIG=ide-key=Vim php ./script-name.php args...
```
> > You may keep xdebug installed but disabled in your normal php configuration, and only enable it when you want a new debugging session, with a command line like:
```
               XDEBUG_CONFIG=ide-key=Vim php -dxdebug.remote_enable=1 -dxdebug.remote_host=localhost ...
```
> > If you are connecting with ssh/PuTTY to your server in order to start and debug the php script there, use a command like:
```
	       XDEBUG_CONFIG=ide-key=Vim php -dxdebug.remote_enable=1 -dxdebug.remote_host="${SSH_CLIENT%% }" ...
```
  * for Web pages: Include XDEBUG\_SESSION\_START=1 as part of the URL query parameters on the page you want to debug, like:
```
        firefox http://localhost/site/index.php?XDEBUG_SESSION_START=1
```

Since Vim will listen for incoming connection from php for only 5s, you may want to have this command line ready when you start the debug session.

You can install the XDebug browser extension (for Firefox, Internet Explorer, Safari, Opera) to do the same thing, so you only press the 'XDebug' button on the toolbar to add this paramter. This will be needed to debug HTML from submissions.