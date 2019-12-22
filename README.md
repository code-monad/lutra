# Lutra - A Simple CommandLine Security-Shell Manager written in Pony 🐴

(中文说明)[./README.zh]

## Installation

### Dependency

You'll need `ponyc` to build this program. Check [ponyc](https://github.com/ponylang/ponyc) if you don't know what it is.

### Install

Run `make && sudo make install` to install lutra. Default install destination is `/usr/bin/lutra`

## Usage

The default config path is `${HOME}/.config/lutra/lutra.conf`, if not exist the program would automaticly create an empty one.

### Add A Named Host

`lutra -a NAME HOST [-p PORT] [-k SSH_KEY_FILE]`

### Connect to A Exist Named Host

`lutra NAME`

### Delete A Named Host

`lutra -d NAME`

### Set A Host as Default

`lutra -u test -s`

After this command, lutra will use `test` as default host.

*If no default host was set, program will choose the first one in the config.*

`lutra # connet to test now!！`


### Parameters

**usage: lutra [<options>] <node> <dest>**

#### Options:

	-l, --list=false       List all nodes
	
	-h, --help=false       Get this page.
	
	-a, --add=false        Adding a new node
	
	-s, --default=false    Set a node as default
	
	-f, --apply=           Applying a new config file
	
	-d, --delete=false     Deleting a node
	
	-k, --key=             Which ssh key to use
	
	-u, --update=false     Update a node
	
	-p, --port=22          Connection port, default to be 22
	
Args:
   <node>    Given host name
   <dest>    Destination of the host
