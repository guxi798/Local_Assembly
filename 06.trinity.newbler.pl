#!/usr/bin/perl -w
use strict;

my $srcfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;
my $tgtfile1 = "01.script/06.trinity.sh";

system("mkdir -p $srcfolder");

open(TGT1, ">$tgtfile1") or die "Cannot open $tgtfile1: $!";

print TGT1 "#!/bin/bash\n";
print TGT1 "export PATH=/usr/local/trinity/latest/:/usr/local/rsem/latest/:\$PATH\n";
print TGT1 "export LD_LIBRARY_PATH=/usr/local/gcc/4.7.1/lib:/usr/local/gcc/4.7.1/lib64:\${LD_LIBRARY_PATH}\n\n";
print TGT1 "Trinity --seqType fa --JM 10G --left $srcfolder/trinity.left.fasta --right $srcfolder/trinity.right.fasta --CPU 1 --output $tgtfolder/trinity --min_contig_length 100 \n";

close(TGT1);

system("chmod u+x $tgtfile1");
system("qsub -q rcc-30d -e 01.script/trinity.e -o 01.script/trinity.o $tgtfile1");

######################################################
my $tgtfile2 = "01.script/06.newbler.sh";

open(TGT2, ">$tgtfile2") or die "Cannot open $tgtfile2: $!";

print TGT2 "#!/bin/bash\n";
print TGT2 "export PATH=/usr/local/454/latest/bin/:\$PATH\n";
print TGT2 "runAssembly -o $tgtfolder/newbler -notrim -cdna $srcfolder/newbler.single.fna\n";

close(TGT2);

system("chmod u+x $tgtfile2");
system("qsub -q rcc-30d -e 01.script/newbler.e -o 01.script/newbler.o $tgtfile2");

