use "cli"
use "files"
use "debug"

actor Main
	new create(env: Env) =>
		let command =
			match recover val CLI.parse(env.args, env.vars) end
				| let c: Command val => c
				| (let exit_code: U8, let msg: String) =>
				if exit_code == 0 then
					env.out.print(msg)
				else
					env.out.print(CLI.help())
					env.exitcode(exit_code.i32())
				end
				return
			end

		let config_dest =
			match command.option("apply").string()
				| "" =>
				"lutra.conf"
				| let f: String =>
				f
			end
			

		let config_path =
			match try FilePath(env.root as AmbientAuth, config_dest)? else None end
				| let path: FilePath =>
				if path.exists() then
					Debug.out("Using" + path.path)
					path
				else
					env.out.print("Config file " + path.path + " not exist, creating a new one...")
					match CreateFile(path)
						| let f: File =>
						env.out.print("Default config file " + path.path + " created.")
						f.write(DefaultConfig())
						path
						| let f: FileOK =>
						env.out.print("Default config file located in " + path.path + ".")
						path
					else	
						env.out.print("Faild to create file.")
						env.exitcode(-1)
						return
					end
				end
				
				| None =>
				env.out.print("Error while loading config" + config_dest + ", exit...")
				return
			end			

		let config_file = File(config_path)
		match Config(consume config_file, env.out).parse()
			| None =>
			env.out.print("Failed to parse " + config_path.path + ", maybe a syntax error.")
			env.exitcode(-1)
			return
			| let config: Config =>
			
			// listing nodes
			if command.option("list").bool() then
				env.out.print("Listing existing hosts...")
				for info in config.print_nodes().values() do
					env.out.print(info)
				end
				return
			end

			if command.option("add").bool() then
				config(command.arg("node").string(),command.arg("dest").string())
				config.save()
				return
			end

			let node: String = command.arg("node").string()

			if config.exist(node) == false then
				env.err.print(node+" does not exist, please your configuration!")
				env.exitcode(-1)
				return 
			end
			
			if command.option("delete").bool() then
				env.out.print("Removing " + command.arg("node").string() + "...")
				config.remove(command.arg("node").string())
				config.save()
				return
			end
			
			config.save()

			let host = config.node(node)
			env.out.print("Host is " + host._1 + " " + host._2)
			let ssh: SSH = config.ssh
			(let ssh_command, let args) = ssh.command(host)
			try
				let pm = Invoke(env.out, env.err, env.input, env.root as AmbientAuth, ssh_command, recover args.clone() end, env.vars)?
				let ssh_notify = SSHNotify(pm)
				env.input(consume ssh_notify)
				//let pm = Invoke(env.out, env.err, env.root as AmbientAuth, ssh_command, [], env.vars)?
			else
				env.err.print("Failed to invoke " + ssh_command + ", maybe it is not exist.")
			end
			
		end
