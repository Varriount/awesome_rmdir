import argument_parser, os, tables, strutils

const
  PARAM_VERBOSE = @["-v", "--verbose"]
  PARAM_RECURSIVE = @["-r", "--recursive"]
  PARAM_HELP = @["-h", "--help"]
  PARAM_VERSION = @["-V", "--version"]

  VERSION_STR* = "0.3.1" ## Program version as a string.
  VERSION_INT* = (major: 0, minor: 3, maintenance: 1) ## \
  ## Program version as an integer tuple.
  ##
  ## Major version changes mean significant new features or a break in
  ## commandline backwards compatibility, either through removal of switches or
  ## modification of their purpose.
  ##
  ## Minor version changes can add switches. Minor
  ## odd versions are development/git/unstable versions. Minor even versions
  ## are public stable releases.
  ##
  ## Maintenance version changes mean bugfixes or non commandline changes.


proc is_deletable(filename: string): bool =
  ## Returns true if the file has a pattern which can be deleted.
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
  #params.add(new_parameter_specification(names = PARAM_RECURSIVE,
  #  help_text = "Remove directories recursively"))
  params.add(new_parameter_specification(names = PARAM_HELP,
    help_text = "Displays commandline help and exits", consumes = PK_HELP))
  params.add(new_parameter_specification(names = PARAM_VERSION,
    help_text = "Displays the current version and exists"))

  result = parse(params)

  if result.options.hasKey(PARAM_VERSION[0]):
    echo "Version ", VERSION_STR
    quit()

  if result.positional_parameters.len < 1:
    echo "Please specify directories to be removed"
    echo_help(params)
    quit()


proc clean_recursively(path: string; verbose: bool): bool =
  ## Split method due to https://github.com/Araq/Nimrod/issues/391
  ##
  ## returs true if the parent should call return.
  for kind, sub_path in walkDir(path):
    case kind
    of pcFile:
      if sub_path.extractFilename.is_deletable:
        if verbose: echo("Deleting $1" % sub_path)
        removeFile(sub_path)
      else:
        echo("Directory $1 contains non deletable file $2, aborting" %
          [path, sub_path])
        result = true
        return
    else:
      echo("Directory $1 contains no deletable item $2, aborting" %
        [path, sub_path])
      result = true
      return


proc process(path: string; verbose, recursive: bool): bool =
  ## Removes the specified directory, recursively if needed.
  if not existsDir(path):
    echo "Not a valid directory " & path
    return

  try:
    if verbose: echo "Removing dir " & path
    removeFile(path)
    result = true
  except EOS:
    if verbose: echo("Failed to remove $1 cleanly, trying harder..." % path)
    if clean_recursively(path, verbose):
      if verbose: echo("...sorry, could not")
      return
    # Ok, try again.
    try:
      removeFile(path)
      result = true
      if verbose: echo("...and removed $1" % path)
    except EOS:
      quit("...even though $1 is empty it can't be removed!" % path)


when isMainModule:
  let
    args = process_commandline()
    verbose = args.options.hasKey(PARAM_VERBOSE[0])
    recursive = args.options.hasKey(PARAM_RECURSIVE[0])

  var count = 0
  for param in args.positional_parameters:
    if process(param.str_val, verbose, recursive):
      count += 1
  if count != args.positional_parameters.len:
    quit("Could not remove all input parameters.")
