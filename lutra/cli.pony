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
		  OptionSpec.bool(
		  "list", "List all nodes", 'l', false)
		  OptionSpec.bool(
		  "add", "Adding a new node", 'a', false)
		  OptionSpec.bool(
		  "delete", "Deleting a node", 'd', false)
		  OptionSpec.string(
		  "apply", "Applying a new config file", 'f', "")
		],
		[ ArgSpec.string(
		  "node", "The node name", "")
		  ArgSpec.string(
		  "dest", "Destination of the host", "")
		]
		)?.>add_help("help", "Get this page.")?


primitive HostPrint
	fun apply(host: Host): String =>
		"Host: " + host._1 + ", Port:" + host._2

primitive NodePrint
	fun apply(node: Node, default: Bool = false): String =>
		"["+ if default then "*" else "" end + node._1 + "]  " + HostPrint(node._2)
