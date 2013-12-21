import nake, os, osproc, htmlparser, xmltree, strtabs, times, awesome_rmdir,
  zipfiles

const name = "awesome_rmdir"
let
  rst_files = @["docs"/"CHANGES", "docs"/"release_steps",
    "LICENSE", "README", "docindex"]

proc change_rst_links_to_html(html_file: string) =
  ## Opens the file, iterates hrefs and changes them to .html if they are .rst.
  let html = loadHTML(html_file)
  var DID_CHANGE: bool

  for a in html.findAll("a"):
    let href = a.attrs["href"]
    if not href.isNil:
      let (dir, filename, ext) = splitFile(href)
      if cmpIgnoreCase(ext, ".rst") == 0:
        a.attrs["href"] = dir / filename & ".html"
        DID_CHANGE = true

  if DID_CHANGE:
    writeFile(html_file, $html)

proc needs_refresh(target: string, src: varargs[string]): bool =
  assert len(src) > 0, "Pass some parameters to check for"
  var TARGET_TIME: float
  try:
    TARGET_TIME = toSeconds(getLastModificationTime(target))
  except EOS:
    return true

  for s in src:
    let srcTime = toSeconds(getLastModificationTime(s))
    if srcTime > TARGET_TIME:
      return true


iterator all_rst_files(): tuple[src, dest: string] =
  for rst_name in rst_files:
    var R: tuple[src, dest: string]
    R.src = rst_name & ".rst"
    # Ignore files if they don't exist, babel version misses some.
    if not R.src.existsFile:
      echo "Ignoring missing ", R.src
      continue
    R.dest = rst_name & ".html"
    yield R

task "doc", "Generates HTML version of the documentation":
  # Generate html files from the rst docs.
  for rst_file, html_file in all_rst_files():
    if not html_file.needs_refresh(rst_file): continue
    if not shell("nimrod rst2html --verbosity:0", rst_file):
      quit("Could not generate html doc for " & rst_file)
    else:
      change_rst_links_to_html(html_file)
      echo rst_file & " -> " & html_file
  echo "All done"

task "check_doc", "Validates rst format for a subset of documentation":
  for rst_file, html_file in all_rst_files():
    echo "Testing ", rst_file
    let (output, exit) = execCmdEx("rst2html.py " & rst_file & " > /dev/null")
    if output.len > 0 or exit != 0:
      echo "Failed python processing of " & rst_file
      echo output

task "clean", "Removes temporal files, mainly":
  removeDir("nimcache")
  for rst_file, html_file in all_rst_files():
    echo "Removing ", html_file
    html_file.removeFile

template os_task(define_name): stmt {.immediate.} =
  task "dist_" & define_name, "Generate distribution binary for " & define_name:
    runTask "clean"
    runTask "doc"
    let
      dname = name & "-" & VERSION_STR & "-" & define_name
      zname = dname & ".zip"
    removeFile(name)
    removeFile(zname)
    direShell("nimrod c -d:release --out:" & name & " " & name & ".nim")
    var Z: TZipArchive
    if not Z.open(zname, fmWrite):
      quit("Couldn't open zip " & zname)
    try:
      Z.addFile(dname / name, name)
      for rst_file, html_file in all_rst_files():
        Z.addFile(dname / html_file, html_file)
    finally:
      Z.close
    echo "Built ", zname, " sized ", zname.getFileSize, " bytes."

when defined(macosx): os_task("macosx")
when defined(linux): os_task("linux")
