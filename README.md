# Shutter

Shutter is a tool that gives system administrators the ability to manage 
iptables firewall settings through simple lists instead of complex iptables commands, making it
easier to define host and service firewall setting with configuration management tools.  Please note:
This application is currently only tested with Red Hat based distributions.  Ubuntu and Debian should 
work but are not supported.

** Note: Shutter server is not yet complete**

## Installation

Instalation is through the gem package management program. 

    $ gem install shutter

## Upgrading from <= 0.0.7 to 0.1.0

Version 0.0.7 added forwarding capabilities to shutter so the base.ipt changed and needs to be upgraded.  Version 0.1.0 was a complete rewrite which fixed multiple
bugs as well as the problem with the maximum prefix length for iptables logging in base.ipt.  Support for ubuntu and debian was added but not tested well and 
requires the iptables-persistant package.  To upgrade the base template and add the new configuration files, use the following command:

    $ shutter --upgrade

## Usage

#### Install the gem.
    
    $ gem install shutter

#### OPTIONAL: Create the initial configuration files.
Shutter automatically creates any missing configuration files anytime it is run, but you can create them prior to 

    $ shutter --init

#### Modify the files to meet your required settings.  

There are several files that you can modify:
* **base.ipt:**  The one file to rule them all.  Modifying this file is optional as
it is the template that is used to build the firewall. If you do modify the file,
just make sure you include the appropriate placeholder directives to allow
shutter to dynamically fill in the rules.  It is possible to leave out any unwanted
placeholders.  By default the files are will be found in the */etc/shutter.d* directory
* **iface.dmz:**  Enter any private interfaces that will be unprotected by the firewall.  One per line.
* **iface.forward:**  Enter any source and destination interfaces that forwarding will occur.
* **ip.allow:**  A list of IP addresses and ranges that are allowed to access the 'private' ports
* **ip.deny:**  A list of IP addresses and ranges that are denied access to both public and private ports. 
* **ports.private:**  A list of ports and protocols that are available to traffic that passes through the AllowIP chain
* **ports.public:**  A list of ports and protocols that are available publically to everyone except the 'Bastards' listed in ip.deny

Shutter was designed to work with the Fail2ban access monitoring/management tool.  It includes a 
special chain called 'Jail' which is used to insert the jump rules that fail2ban uses to deny 
access 'on-the-fly'.  To work correctly, you configure fail2ban to use the Jail chain instead of 
INPUT.  The dynamic rules that fail2ban has created in the jail chain remain persistant when 
shutter is 'restored' or reloaded.

#### To check your firewall you can run:

    $ shutter --save

This command mimics the 'iptables-save' command which prints the rules out to the screen.  
This does not modify the firewall settings.

#### To implement the changes, use:

    $ shutter --restore

This command uses 'iptables-restore' under the hood to update the firewall.  You can use the '--persist' option
to make the changes permanent and survive reboots.  Persist can optionally take an argument which defines the location of the
persist file if it is in a non-standard location.

#### Command line options
Usage: shutter [options]
        --init                       Create the initial configuration files.
        --reinit                     Rereate the initial configuration files.
        --upgrade                    Upgrade the configuration files that have changes with a new version.
    -s, --save                       Output the firewall to stdout. This is the default behavior.
    -r, --restore                    Restore the firewall through iptables-restore.
    -p, --persist [FILE]             Write the firewall to the persistance file.  If an argument is given, it will be used as the persistance file
    -d, --dir DIR                    Set the directory for configuration files.  Default is /etc/shutter.d.
        --debug                      Turn on debugging for extra output.
    -h, --help                       Display help and exit.
        --version                    Display version and exit.

More documentation to come...


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
