use "cli"

primitive CLI
	fun parse(
		args: Array[String] box,
		envs: (Array[String] box | None)
		) : (Command | (U8, String))
	=>
	try
		match CommandParser(_spec()?).parse(args, envs)
			|let c: Command => c
			|let h: CommandHelp => (0, h.help_string())
			|let e: SyntaxError => (1, e.string())
		end
	else
		(-1, "unable to parse command")
	end


	fun help(): String =>
		try Help.general(_spec()?).help_string() else "" end

	fun _spec(): CommandSpec ? =>
		CommandSpec.leaf(
		"lutra",
		"A minimal Secure-Shell manager",
		[
		  OptionSpec.string(
		  "port", "Connection port, default to be 22", 'p', "22")
		  OptionSpec.string(
		  "key", "Which ssh key to use", 'k', "")
		  OptionSpec.bool(
		  "list", "List all nodes", 'l', false)
		  OptionSpec.bool(
		  "add", "Adding a new node", 'a', false)
		  OptionSpec.bool(
		  "delete", "Deleting a node", 'd', false)
		  OptionSpec.bool(
		  "update", "Update a node", 'u', false)
		  OptionSpec.string(
		  "apply", "Applying a new config file", 'f', "")
		  OptionSpec.bool(
		  "default", "Set a node as default", 's', false)
		],
		[ ArgSpec.string(
		  "node", "Given host name", "")
		  ArgSpec.string(
		  "dest", "Destination of the host", "")
		]
		)?.>add_help("help", "Get this page.")?


primitive HostPrint
	fun apply(host: Host): String =>
		"Host: " + host._1 + ", Port:" + host._2 +
		match host._3
			| None => ""
			| let key: String => ", Key:" + key
		end

primitive NodePrint
	fun apply(node: Node, default: Bool = false): String =>
		"["+ if default then "*" else "" end + node._1 + "]  " + HostPrint(node._2)


// Get user's home path from Env.vars
primitive GetHome
	fun apply(vars: Array[String val] val): (String|None) =>
		try EnvVars(vars)("HOME")? end
