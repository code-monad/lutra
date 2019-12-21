use "files"
use "process"

class SSH
	let _command: String val
	
	new create(command': String val = "/usr/bin/ssh") =>
		_command = command'

	fun val base_command(): String val => _command

	// Building ssh command string
	fun command(host': Host, key': (None | FilePath) = None): (String val,  Array[String val] val)=>
		let args = recover Array[String val] end
		args.>push("-S").>push("-tt") // use stdin to read password
		args.>push("-p").push(host'._2)
			match key'
				| let path: FilePath =>
				if path.exists() then
					args.>push("-i").push(path.path)
				end
			end
		args.push(host'._1)
		(_command.string(), recover args end)


class SSHNotify is InputNotify

	let _pm: ProcessMonitor
	
	new iso create(pm: ProcessMonitor) =>
		_pm = pm

	fun ref apply(data: Array[U8 val] iso) : None val =>
		_pm.>write(consume data)
