#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;

system("mkdir -p $tgtfolder");

