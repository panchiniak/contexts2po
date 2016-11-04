# Pogenerator
Generates PO files for supporting i18n of cucumber features/steps

# SYNOPSIS
perl -f PO.pm --step \[FILE_NAME\]  --lang \[LANGUAGE_CODE|list\]  --mode \[apply|reset\]

### Options:
  * list - lists supported codes of languages
  * apply - apply a .po file into choosen steps file/language
  * reset - restore in-use steps file back to its source state

# DESCRIPTION

This program will read given Cucumber steps file and write out a .po.

It also applies a selected language (filled .po) to a steps file (see option apply).

# AUTHOR
Rodrigo Panchiniak Fernandes - [http://toetec.com.br/](http://toetec.com.br/)

# CAVEAT
Some paths are hardocoded right now, and there is no init procedure for
adjusting them.
So, if you want to use the code as-is, your tree structure shoud follow this one:
[https://github.com/panchiniak/scaffolding](https://github.com/panchiniak/scaffolding)

#  ACKNOWLEDGMENTS

Kindly reviewed by integral, blue_sky, huf, pink_mist. All imperfections left are to be taken as reponsability of the author solely.
