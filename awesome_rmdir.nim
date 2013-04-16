import argument_parser, os, tables

const
  PARAM_VERBOSE = @["-v", "--verbose"]
  PARAM_RECURSIVE = @["-r", "--recursive"]
  PARAM_HELP = @["-h", "--help"]


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


proc process(filename: string, verbose, recursive: bool) =
  ## Removes the specified directory, recursively if needed.
  echo "hey!"


when isMainModule:
  let
    args = process_commandline()
    verbose = args.options.hasKey(PARAM_VERBOSE[0])
    recursive = args.options.hasKey(PARAM_RECURSIVE[0])

  for param in args.positional_parameters:
    process(param.str_val, verbose, recursive)
