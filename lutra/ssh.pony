use "files"
use "process"

class SSH
	let _command: String val
	
	new create(command': String val = "/usr/bin/ssh") =>
		_command = command'

	fun val base_command(): String val => _command

	// Building ssh command string
	fun command(host': Host): Array[String val] val=>
		let command_str = recover Array[String val] end
		command_str.push(_command.string())
		command_str.>push("-p").push(host'._2)
		match host'._3
			| let identity: String =>
			command_str.>push("-l").push(identity)
		end
		match host'._4
			| let key: String =>
			command_str.>push("-i").push(key)
		end
		command_str.push(host'._1)
		command_str
