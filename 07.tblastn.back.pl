#!/usr/bin/perl -w
use strict;

my $profolder = shift @ARGV;
my $tgtfolder = shift @ARGV;

system("mkdir -p $tgtfolder");
system("ln -sf ../../06.assembly/01.tblastn/cap3.allseq.fasta.cap.contigs $tgtfolder/final.contigs.fasta");
system("makeblastdb -in $tgtfolder/final.contigs.fasta -dbtype 'nucl'\n");

my $shell = "01.script/07.tblastn.back.sh";
open(SHL, ">$shell");
print SHL "#!/bin/bash\n\n";
print SHL "time tblastn -query $profolder/proteinsOfInterest.fasta -db $tgtfolder/final.contigs.fasta -out $tgtfolder/contigs.blast.out -evalue 1e-5  -outfmt 0 -num_threads 1 -num_alignments 100 -num_descriptions 100\n";
		
close(SHL);
		
system("chmod u+x $shell");
system("qsub -q rcc-30d -pe thread 1 -e 01.script/07.tblastn.back.e -o 01.script/07.tblastn.back.o $shell");