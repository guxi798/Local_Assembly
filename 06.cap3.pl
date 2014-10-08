#!/usr/bin/perl -w
use strict;

my $srcfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;
my $tgtfile3 = "01.script/06.cap3.sh";

system("cat $tgtfolder/trinity/Trinity.fasta $tgtfolder/newbler/454AllContigs.fna $srcfolder/cap3.single.fasta > $tgtfolder/cap3.allseq.fasta");

open(TGT3, ">$tgtfile3") or die "Cannot open $tgtfile3: $!";

print TGT3 "#!/bin/bash\n";
print TGT3 "export PATH=/usr/local/trinity/latest/:/usr/local/rsem/latest/:\$PATH\n";
print TGT3 "cap3 $tgtfolder/cap3.allseq.fasta\n";

close(TGT3);

system("chmod u+x $tgtfile3");
system("qsub -q rcc-30d -e 01.script/cap3.e -o 01.script/cap3.o $tgtfile3");
