import argument_parser, os, tables, strutils

const
  PARAM_VERBOSE = @["-v", "--verbose"]
  PARAM_RECURSIVE = @["-r", "--recursive"]
  PARAM_HELP = @["-h", "--help"]


proc is_deletable(filename: string): bool =
  ## Returns true if the file has a patter which can be deleted.
  echo filename
  if filename == ".DS_Store":
    result = true
  elif filename == "Thumbs.db":
    result = true


proc process_commandline(): Tcommandline_results =
  ## Processes the commandline.
  ##
  ## Returns the positional parameters if they were specified, plus the
  ## optional switches specified by the user.
  var params: seq[Tparameter_specification] = @[]
  params.add(new_parameter_specification(names = PARAM_VERBOSE,
    help_text = "Be verbose about actions"))
  params.add(new_parameter_specification(names = PARAM_RECURSIVE,
    help_text = "Remove directories recursively"))
  params.add(new_parameter_specification(names = PARAM_HELP,
    help_text = "Displays commandline help and exits", consumes = PK_HELP))

  result = parse(params)

  if result.positional_parameters.len < 1:
    echo "Please specify directories to be removed"
    echo_help(params)
    quit()


proc process(path: string; verbose, recursive: bool) =
  ## Removes the specified directory, recursively if needed.
  if not existsDir(path):
    echo "Not a valid directory " & path
    return

  try:
    if verbose: echo "Removing dir " & path
    removeFile(path)
    echo "haya!"
  except EOS:
    if verbose: echo("Failed to remove $1 cleanly" % path)
    for kind, sub_path in walkDir(path):
      case kind
      of pcFile:
        if sub_path.extractFilename.is_deletable:
          if verbose: echo("Deleting $1" % sub_path)
          echo "Hey!"
          removeFile(sub_path)
        else:
          echo("Directory $1 contains non deletable file $2, aborting" %
            [path, sub_path])
          return
      else:
        echo("Directory $1 contains no deletable item $2, aborting" %
          [path, sub_path])
    # Ok, try again.
    try:
      echo "Hhhhh " & path
      removeFile(path)
      echo "Hey"
    except EOS:
      echo "Hey222"
      echo("Even though $1 is empty it can't be removed!" % path)


when isMainModule:
  let
    args = process_commandline()
    verbose = args.options.hasKey(PARAM_VERBOSE[0])
    recursive = args.options.hasKey(PARAM_RECURSIVE[0])

  for param in args.positional_parameters:
    process(param.str_val, verbose, recursive)
