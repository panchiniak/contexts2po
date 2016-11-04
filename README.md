# Context POgenerator
Generates PO files from english base and its arbitrary aligned translation.

# SYNOPSIS
perl -f C2PO.pm --base [FILE_NAME] --translation [FILE_NAME] --context [FILE_NAME] --lang [LANGUAGE_CODE|list]

### Options:
  * base - translated strings (msgid)
  * translations - translations aligned to base (msgstr)
  * context - POT (msgctxt, msgid)
  * lang - sufix for output file name

# DESCRIPTION

Context to PO (C2PO) generates a PO file from POT, base and translated files.
PO generated contains comments, msgctxt, msgid, msgstr.

# AUTHOR
Rodrigo Panchiniak Fernandes

# CAVEAT
Base file and its translantion need to be aligned line by line.
