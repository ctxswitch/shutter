# Shutter

Shutter is a tool that gives system administrators the ability to manage 
iptables firewall settings through simple lists instead of complex iptables commands, making it
easier to define host and service firewall setting with configuration management tools.  Please note:
This application currently only works with Red Hat based distributions, as the need arises more 
distributions will be added.  

** Note: Shutter server is not yet complete**

## Installation

Instalation is through the gem package management program. 

    $ gem install shutter

## Upgrading from 0.0.6 to 0.0.7

Version 0.0.7 adds forwarding capabilities to shutter.  To upgrade the base template and add the new configuration files, use the following command:

    $ shutter --upgrade

** Note: I didn't realize that there was a maximum prefix length for iptables logging before I packaged the gem.  If you are installing from the gem, you will need to make a small change to the base.ipt file.  Change the log prefix for the FORWARD chain to something less than 29 characters.  It will be fixed the next time I push 0.0.8 to rubygems. (it's fixed in the master branch) **

## Usage

#### Install the gem.
    
    $ gem install shutter

#### Create the initial configuration files.

    $ shutter --init

#### Modify the files to meet your required settings.  

There are several files that you can modify:
* **base.ipt:**  The one file to rule them all.  Modifying this file is optional as
it is the template that is used to build the firewall. If you do modify the file,
just make sure you include the appropriate placeholder directives to allow
shutter to dynamically fill in the rules.  It is possible to leave out any unwanted
placeholders.  By default the files are will be found in the */etc/shutter.d* directory
* **iface.dmz:**  Enter any private interfaces that will be unprotected by the firewall.  One per line.
* **ip.allow:**  A list of IP addresses and ranges that are allowed to access the 'private' ports
* **ip.deny:**  A list of IP addresses and ranges that are denied access to both public and private ports. 
* **ports.private:**  A list of ports and protocols that are available to traffic that passes through the AllowIP chain
* **ports.public:**  A list of ports and protocols that are available publically to everyone except the 'Bastards' listed in ip.deny

Shutter was designed to work with the Fail2ban access monitoring/management tool.  It includes a 
special chain called 'Jail' which is used to insert the jump rules that fail2ban uses to deny 
access 'on-the-fly'.  To work correctly, you configure fail2ban to use the Jail chain instead of 
INPUT.  The dynamic rules that fail2ban has created in the jail chain remain persistant when 
shutter is 'restored' or reloaded.

Shutter can also run as a server to recieve requests from clients to populate the ip.allow and ip.deny files from a central location.  To use this feature, you will need to generate an encryption key on the system you plan on using as the server by running the command:
    
    server $ shutter --keygen

This will create the file validation.pem in the /etc/shutter.d (or the user defined) folder.  The validation key can then be distributed to the shutter clients to pull in lists.  On the shutter server, you will need to define the available lists in the server.json configuration file.  It could look like this:
    
    {
      'allow_lists': [
        'default.allow',
        'private.allow',
        'public.allow'
      ],
      'deny_lists': [
        'default.deny',
        'bastards.deny'
      ]
    }

To start the server run:

    server $ shutter --server start

To stop the server run:

    server $ shutter --server stop

To restart the server run:

    server $ shutter --server restart

The first time you run shutter-server, empty files will be created in /etc/shutter.d/lists.  Edit the files just like you would the ip.allow and ip.deny files.  Make sure you copy the validation.pem file to your client and then on the client run:

    client $ shutter --allow private --remote shutter.example.com

If the '--allow' is not specified it will grab default.allow file and if the file does not exist on the server it will return an error.  In this case, shutter will grab the private.allow file from the remote site and replace ip.allow with the contents if the contents have changed.

Under the hood:  A request is sent out to retrieve the MD5 sum of the file that lives on the server, if the md5sum of the file on the remote server is different than the one that is on the local server, the file is retrieved and updated on the client.


#### To check your firewall you can run:

    client $ shutter --save

This command mimics the 'iptables-save' command which prints the rules out to the screen.  
This does not modify the firewall settings.

#### To implement the changes, use:

    client $ shutter --restore

This command uses 'iptables-restore' under the hood to update the firewall.  You can use the '--persist' option
to make the changes permanent and survive reboots.

#### Useful environment variables:
**SHUTTER_CONFIG:** Use this variable to set the location to the configuration files.

**SHUTTER_PERSIST_FILE:** Use this variable to set the location of the 'persist' file.  i.e. /etc/sysconfig/iptables (default for Redhat)

**SHUTTER_MODE:** Sets the mode of operation.  Currently only used for testing, but in the future it will include a development mode for increased log output for automated runs

More documentation to come...


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
