# =================================================================================================
# Generic Makefile for a research paper
# Colin Perkins <csp@csperkins.org>
#
# Copyright (C) 2016-2017 University of Glasgow
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
#
# =================================================================================================
# Configuration for make itself:

# Warn if the Makefile references undefined variables and remove built-in rules:
MAKEFLAGS += --warn-undefined-variables --no-builtin-rules --no-builtin-variables

# Remove output of failed commands, to avoid confusing later runs of make:
.DELETE_ON_ERROR:

# Remove obsolete old-style default suffix rules:
.SUFFIXES:

# List of targets that don't represent files:
.PHONY: all clean

# =================================================================================================

# The PDF files to build, each should have a corresponding .tex file:
PDF_FILES = improving-protocol-standards.pdf quic-example.pdf

# Tools to build before the PDF files. This is a list of executable files in
# the bin/ directory:
TOOLS = 

# Master build rule:
all: $(TOOLS) $(PDF_FILES)

# Pattern rules to build a PDF file. The assumption is that each PDF file 
# is built from the corresponding .tex file.
%.pdf: %.tex 
	@bin/latex-build.sh pdf $(notdir $(basename $<)) $(dir $<)
	@bin/check-for-duplicate-words.perl $<
	@bin/check-for-todo.sh              $<

# Include dependency information for PDF files, if it exists:
-include $(PDF_FILES:%.pdf=%.dep)

# Pattern rules to build plots using gnuplot. These require the data
# to be plotted be in figures/%.dat, while the script to control the
# plot is in figures/%.gnuplot. The script figures/%.gnuplot-pdf (or
# figures/%.gnuplot-svg) is loaded before the main gnuplot script,
# and should call "set terminal ..." and "set output ..." to set the
# appropriate format and output file. This allows the main gnuplot 
# script to be terminal independent.
figures/%.pdf: figures/%.gnuplot-pdf figures/%.gnuplot figures/%.dat
	gnuplot figures/$*.gnuplot-pdf figures/$*.gnuplot

figures/%.svg: figures/%.gnuplot-svg figures/%.gnuplot figures/%.dat
	gnuplot figures/$*.gnuplot-svg figures/$*.gnuplot

# Pattern rules to build C programs comprising a single file:
CC     = clang
CFLAGS = -W -Wall -Wextra -O2 -g -std=c99

bin/%: src/%.c
	$(CC) $(CFLAGS) -o $@ $^

define xargs
$(if $(2),$(1) $(wordlist 1,1000,$(2)))
$(if $(word 1001,$(2)),$(call xargs,$(1),$(wordlist 1001,$(words $(2)),$(2))))
endef

define rm
$(call xargs,rm -f ,$(1))
endef

define rmdir
$(call xargs,rm -fr ,$(1))
endef

define pdfclean
	bin/latex-build.sh clean $(notdir $(basename $(firstword $(1)))) $(dir $(firstword $(1)))
	$(if $(wordlist 2,$(words $(1)),$(1)),$(call pdfclean,$(wordlist 2,$(words $(1)),$(1))))
endef

clean:
	$(call rm,$(TOOLS))
	$(call rmdir,$(TOOLS:%=%.dSYM))
	$(call pdfclean,$(PDF_FILES))

# =================================================================================================
# vim: set ts=2 sw=2 tw=0 ai:
