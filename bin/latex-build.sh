#! /bin/sh
# =================================================================================================
# Script to build a LaTeX document
# 
# Colin Perkins
# https://csperkins.org/
#
# Copyright (C) 2003-2017 University of Glasgow
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions 
# are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, 
#    this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# =================================================================================================

REGEX_CITE=".*Warning: Citation.*undefined"
REGEX_LABL=".*Warning: Label(s) may have changed. Rerun to get cross-references right."
REGEX_BOOK="Package rerunfilecheck Warning: File .*out. has changed"

# Function to display a separator:
blank_line () {
  COLS=`tput cols`
  BLANK_LINE=""

  i=0
  while [ $i -lt $COLS ]; 
  do
    BLANK_LINE="$BLANK_LINE="
    i=`expr $i + 1`
  done

  tput setaf 2 || true
  echo $BLANK_LINE
  tput sgr0    || true
}

# Function to display the usage message:
usage() {
  echo "Usage: latex-build.sh <mode> <basename> <directory>"
  echo "where <mode> is either \"pdf\" to build a PDF"
  echo "                    or \"clean\" to clean up"
}

# Function to build a PDF:
build_pdf () {
  blank_line

  tput setaf 2 || true
  echo "== Building LaTeX document: $DIR_NAME/$TEX_BASE.tex"
  tput sgr0    || true

  done_bib=0
  do_bib=0
  do_tex=1

  while [ $do_tex = 1 ]; do
    blank_line

    TEXINPUTS=$DIR_NAME:lib/tex/inputs: pdflatex -output-directory $DIR_NAME -recorder -interaction=nonstopmode -halt-on-error -file-line-error $TEX_BASE.tex
    if [ $? = 1 ]; then
      exit 1
    fi
    do_bib=0
    do_tex=0

    # Rerun LaTeX if the labels have changed
    labl_changed=`grep -c "$REGEX_LABL" $DIR_NAME/$TEX_BASE.log`
    if [ $labl_changed != 0 ]; then
      do_tex=1
    fi

    # Rerun LaTeX if PDF bookmarks have changed
    book_changed=`grep -c "$REGEX_BOOK" $DIR_NAME/$TEX_BASE.log`
    if [ $book_changed != 0 ]; then
      do_tex=1
    fi

    # Check if there are undefined citations, request a run of BibTeX if necessary
    undef_cite=`grep -c "$REGEX_CITE" $DIR_NAME/$TEX_BASE.log`
    if [ $undef_cite != 0 ]; then
      if [ $done_bib = 0 ]; then 
        do_bib=1
      fi
      if [ $done_bib = 1 ]; then
        done_bib=2
        do_tex=1
      fi
    fi

    # Check if any of the *.bib files includes have been modified since
    # BibTeX was last run; if so, request a new run of BibTeX
    for f in `grep '\\\\bibdata{' $DIR_NAME/$TEX_BASE.aux | sed 's/\\\bibdata{//' | sed 's/}//' | sed 's/,/ /' `
    do
      if [ $f.bib -nt $TEX_BASE.bbl ]; then
        do_bib=1
      fi
    done

    if [ $do_bib = 1 ]; then 
      num_citations=`grep -c \\\\citation $DIR_NAME/$TEX_BASE.aux`
      if [ $num_citations -gt 0 -a $done_bib = 0 ]; then
        # BibTeX has been requested and has not run already, and there are citations...
        blank_line
        (cd $DIR_NAME && BSTINPUTS=.:../lib/tex/inputs: bibtex $TEX_BASE)
        if [ $? = 1 ]; then
          exit 1
        fi
        do_tex=1;
        do_bib=0;
        done_bib=1;
      fi
    fi
  done

  # Generate dependencies file for make:
  DEPENDS=""
  for dep in `cat $DIR_NAME/$TEX_BASE.fls | sort | uniq | awk '/^INPUT/ {print $2}'`
  do
    DEPENDS="$DEPENDS $dep"
  done

  # FIXME: this assumes the name of the .bib file. It should really parse
  # the .tex files, to find the \bibliography{} lines
  if [ -f $DIR_NAME/$TEX_BASE.bib ]; then
    DEPENDS="$DEPENDS $DIR_NAME/$TEX_BASE.bib"
  fi

  echo "$DIR_NAME/$TEX_BASE.pdf: $DEPENDS" > $DIR_NAME/$TEX_BASE.dep

  # # Call gs to embed all fonts. 
  # blank_line
  # tput setaf 2
  # echo "Post-processing PDF file..."
  # tput sgr0
  # 
  # gs -q -dSAFER -dNOPAUSE -dBATCH -dCompatibilityLevel=1.4 -dDetectDuplicateImages=true \
  #    -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -dSubsetFonts=false \
  #    -sDEVICE=pdfwrite -sOutputFile=$TEX_BASE.tmp.pdf \
  #    -f $TEX_BASE.pdf
  # 
  # cat $TEX_BASE.tmp.pdf > $TEX_BASE.pdf
  # rm  -f $TEX_BASE.tmp.pdf 

  blank_line

  # The pdfinfo tool is part of Xpdf (http://www.foolabs.com/xpdf/).
  pdfinfo  $DIR_NAME/$TEX_BASE.pdf

  echo ""
  echo "PDF Fonts:"
  pdffonts $DIR_NAME/$TEX_BASE.pdf > $DIR_NAME/$TEX_BASE.fonts
  cat $DIR_NAME/$TEX_BASE.fonts

  nmf=`cat $DIR_NAME/$TEX_BASE.fonts | tail -n +3 | awk '{if ($(NF-4) != "yes") print $0}' | wc -l`

  if [ $nmf -gt 0 ]; then \
    tput setaf 1 || true
    tput bold    || true
    echo ""
    echo "WARNING: Some fonts are not embedded"
    echo "Try running \"updmap --edit\" and setting \"pdftexDownloadBase14 true\""
    tput sgr0    || true
  fi

  echo ""
  shasum -a   1 $DIR_NAME/$TEX_BASE.pdf | awk '{print "SHA1  ", $2, $1}'
  shasum -a 256 $DIR_NAME/$TEX_BASE.pdf | awk '{print "SHA256", $2, $1}'
  echo ""

  blank_line
}

# Function to cleanup after a LaTex run:
clean_tex() {
  for f in $DIR_NAME/$TEX_BASE.aux \
           $DIR_NAME/$TEX_BASE.bbl \
           $DIR_NAME/$TEX_BASE.blg \
           $DIR_NAME/$TEX_BASE.dep \
           $DIR_NAME/$TEX_BASE.dvi \
           $DIR_NAME/$TEX_BASE.fls \
           $DIR_NAME/$TEX_BASE.fonts \
           $DIR_NAME/$TEX_BASE.log \
           $DIR_NAME/$TEX_BASE.out \
           $DIR_NAME/$TEX_BASE.pdf
  do
    if [ -f $f ]; then
      echo "  remove $f" && rm -f $f
    fi
  done
}

# =================================================================================================
# Check and parse command line arguments:

if [ $# != 3 ]; then
  usage
  exit 1
fi

TEX_MODE=$1
TEX_BASE=$2
DIR_NAME=`echo $3 | sed 's/\/$//'`

# Build or clean the LaTeX file:
case $TEX_MODE in
  pdf )
    build_pdf
    ;;
  dvi )
    echo "support for building DVI file not yet implemented"
    exit 1
    ;;
  clean )
    clean_tex
    ;;
  * )
    usage
    exit 1
    ;;
esac

# =================================================================================================
