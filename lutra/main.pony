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
				match GetHome(env.vars)
					| let home : String =>
					let config_dir: String = Path.join(home, ".config/lutra")
					try
						let config_dir_path = FilePath(env.root as AmbientAuth, config_dir)?
						if not config_dir_path.exists() then
							config_dir_path.mkdir()
							env.out.print("Create path " + config_dir)
						end
					else
						env.err.print("Filed to create " + config_dir)
					end
					Path.join(config_dir, "lutra.conf")
				else
					"lutra.conf"
				end
				
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

			let add: Bool val = command.option("add").bool()
			let update: Bool val = command.option("update").bool()
			let target: String val = command.arg("node").string()
			let user: String val = command.option("identify").string()
			let key: String val = command.option("key").string()
			
			if add or update then	
				if not config(target,command.arg("dest").string(), command.option("port").string(), if user.size() == 0 then None else user end, if key.size() == 0 then None else key end,command.option("default").bool(), update) then
					if add then
						env.err.print("Node [" + target + "] already existed. Use -u to update it.")
					else
						env.err.print("Node [" + target + "] not exists. Use -a to add it.")
					end
				end
				config.save()
				return
			end

			if config.empty() then
				env.err.>print("You currently did not have a named host!").print("Please add one use `lutra -a [name] [host] [-p port] [-k ssh_key]`")
				return
			end
			
			var node: String = if target == "" then config.default()._1 else target end
			
			if config.exist(node) == false then
				env.err.print(node+" does not exist, please check your configuration!")
				env.exitcode(-1)
				return 
			end
			
			if command.option("delete").bool() then
				env.out.print("Removing " + node + "...")
				config.remove(node)
				config.save()
				return
			end
			
			config.save()

			env.out.print("Connect to " + node + "...")

			let host_info: Host = config.node(node)
			let host: Host = (host_info._1, host_info._2, if user.size() != 0 then user else host_info._3 end, if key.size() != 0 then key else host_info._4 end)
			
			var cmd: Array[String] box = config.ssh.command(host)

			let exitcode : I32 = Shell.from_array(config.ssh.command(host))
			if (exitcode != 0) and (exitcode != 2) then // exitcode would be 2 if terminate password input
				env.err.print("Error occured while forking ssh:" + exitcode.string())
			end
		end
