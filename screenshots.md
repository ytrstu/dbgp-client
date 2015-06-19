# Introduction #

DBGpClient v0.55 running in Vim 7.2 on debian lenny 64-bit (running under QEMU).
![http://wiki.dbgp-client.googlecode.com/git/EvalResult.png](http://wiki.dbgp-client.googlecode.com/git/EvalResult.png)

DBGpClient v0.55 in Vim 7.3 on Slackware 14.0 32-bit, with :colorscheme darkblue
<div><img src='http://wiki.dbgp-client.googlecode.com/git/slack-dbgp.png' alt='DBGpClient screenshot on Vim 7.3, Slackware 32-bit' width='1020' /></div>

# Check for Xdebug enabled in php #
Here is a short command to check if Xdebug is enabled in php. This is for command line scripts only.
![http://wiki.dbgp-client.googlecode.com/git/php-cli-xdebug-check.png](http://wiki.dbgp-client.googlecode.com/git/php-cli-xdebug-check.png)
The image is for a Linux system. Only the output from the first command is significat here. You can
debug command line php scripts even without the settings in the second command, if you set the right
values on the command line.


For php web pages you will need a phpinfo page on your site in order to check
Xdebug is enabled in php. On that page look for the following:
![http://wiki.dbgp-client.googlecode.com/git/php-mod-xdebug-check1.png](http://wiki.dbgp-client.googlecode.com/git/php-mod-xdebug-check1.png)
![http://wiki.dbgp-client.googlecode.com/git/php-mod-xdebug-check2.png](http://wiki.dbgp-client.googlecode.com/git/php-mod-xdebug-check2.png)