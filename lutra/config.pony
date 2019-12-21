use "files"
use "ini"
use "collections"
use "debug"

type Host is (String val, String val, (String val|None)) // dest, port, [key]
type Node is (String val, Host)
type Nodes is Map[String val, Host]

primitive DefaultConfig
	fun apply(): String =>
		"""
		# Your hosts goes here
		# forms in 
		# [host_name]
		# host = "host.domain"
		# port = ssh-port
		"""

primitive NewNodeConfig
	fun apply(node: Node val, is_default: Bool val = false): String val=>
		"\n[" + node._1 + "]\n" +
		"host = "+node._2._1+"\n" +
		"port = "+node._2._2 +
		if is_default then
			"\ndefault = true\n"
		else
			"\n"
		end +
		match node._2._3
			| None => ""
			| let key: String => "key = " + key + "\n"
		end
		
class Config
	let _config: File
	let _out: OutStream
	let _nodes: Nodes ref
	var default_node : String val
	var ssh: SSH
	
	new ref create(config: File ref, out: OutStream)=>
		_config = consume config
		_out = out
		_nodes = recover Nodes end
		default_node = recover val String end
		ssh = recover SSH end

	fun default(): Node => (default_node, node(default_node))

	fun node(name: String val): Host val =>
		_nodes.get_or_else(name, ("","",""))

	fun exist(name: String val): Bool val =>
		_nodes.contains(name)
	
	fun print_nodes(): Array[String val] =>
		let print = recover Array[String val] end
		for node' in _nodes.keys() do
			try
				let detail = NodePrint((node', _nodes(node')?), node' == default_node)
				print.push(detail)
			end
		end
		print
		
	fun ref apply(name: String val, host: String val, port: String val = "22", key: (String val| None), is_default: Bool val = false, update: Bool = false): Bool =>
		if not update then
			if exist(name) then
				return false
			end
		end
		_nodes.insert(name, (host, port, key))
		if is_default then
			default_node = name
		end
		true
		
	fun ref remove(name: String val) =>
		try _nodes.remove(name)? end

	fun ref parse(): (Config|None) =>
		try
			let sections = IniParse(_config.lines())?
			if sections.size() == 0 then // If empty ini file, then don't parse
				return this
			end
			for section in sections.keys() do
				if section == "general" then // General configuration
					let ssh_command = try sections(section)?("ssh")?  else "/usr/bin/ssh" end
					ssh = SSH(ssh_command)
				else
					let host = sections(section)?("host")?
					let port = sections(section)?("port")?
					let key: (String|None) =  try sections(section)?("key")?.string() else None end
					let is_default = try sections(section)?("default")?.bool()? else false end
					apply(section, host, port, key, is_default)
				end
			
			end
			if (default_node.size() == 0) then
				default_node = _nodes.keys().next()?
			end
			Debug.out("Using default node as " + default_node)
			this
		else
			None
		end

	fun ref save() =>
		_config.seek_start(0)
		_config.write(DefaultConfig())
		for node' in _nodes.keys() do
			try
				_config.write(NewNodeConfig((node', _nodes(node')?), node' == default_node))
			end
		end
		_config.set_length(_config.position())
