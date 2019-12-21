use "files"
use "process"

// Invokes a program
primitive Invoke	
	fun apply(out: OutStream, err: OutStream, input: DisposableActor, auth: AmbientAuth, command: String val, args: Array[String val] val, vars: Array[String val] val): ProcessMonitor ?=>
		let command_path = FilePath(auth, command)?
		let notify = InvokeNotify(out, err, input)
		ProcessMonitor(auth, auth, consume notify, command_path, args, vars)

class InvokeNotify  is ProcessNotify
	let _out: OutStream
	let _err: OutStream
	let _close_stdin: {(): box->None }
	new iso create(out: OutStream, err: OutStream, input: DisposableActor) =>
		_out = out
		_err = err
		_close_stdin = {()(input = input) => input.dispose()}

	fun ref stdout(
		process: ProcessMonitor ref,
		data: Array[U8 val] iso
		) : None val =>
		_out.>write(consume data).flush()

	fun ref stderr(
		process: ProcessMonitor ref,
		data: Array[U8 val] iso
		) : None val =>
		_err.>write(consume data).flush()


	fun ref failed(
		process: ProcessMonitor ref,
		err: (ExecveError val | ForkError val | KillError val | 
		PipeError val | Unsupported val | WaitpidError val | 
		WriteError val | CapError val)) : None val =>
		match err
			| ExecveError => _err.print("ProcessError: ExecveError")
			| PipeError => _err.print("ProcessError: PipeError")
			| ForkError => _err.print("ProcessError: ForkError")
			| WaitpidError => _err.print("ProcessError: WaitpidError")
			| WriteError => _err.print("ProcessError: WriteError")
			| KillError => _err.print("ProcessError: KillError")
			| CapError => _err.print("ProcessError: CapError")
			| Unsupported => _err.print("ProcessError: Unsupported")
		end
		
	fun ref dispose(
		process: ProcessMonitor ref,
		child_exit_code: I32 val) : None val =>
		let code: I32 = consume child_exit_code
		if code != 0 then
			_err.print("Process exited in a error status. " + code.string())
		end
		_close_stdin()
