use @system[I32](command: Pointer[U8] tag)

primitive Shell
  fun tag apply(
    command: String) : I32
  =>
    var rc = @system(command.cstring())
    if (rc < 0) or (rc > 255) then rc = 1 end // clip out-of-bounds exit codes
	rc

  fun tag from_array(
    command_args: Array[String] box
    ) : I32
  =>
    var command = recover trn String end
    for arg in command_args.values() do
      command.append(escape_arg(arg))
      command.push(' ')
    end
    apply(consume command)

  fun tag escape_arg(arg: String): String =>
    "'" + arg.clone() .> replace("'", "'\\''") + "'"
