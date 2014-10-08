#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $profolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/makeblastdb*");
system("mkdir -p 03.blast/01.tblastn");

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fasta$|^OrAe.+fna$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/\.fasta|\.fna//;
		my $shell = "01.script/tblastn.$file.sh";
		open(SHL, ">$shell");
		print SHL "#!/bin/bash\n\n";
		
#		print SHL "mkdir -p 03.blast/01.tblastn/$new";
#		print SHL "cd 03.blast/01.tblastn/$new";
#		print SHL "ln -sf proteinsOfInterest.fasta ../../../$profolder/proteinsOfInterest.fasta";
#		print SHL "ln -sf $file ../../../$srcfolder/$sub/$file";
		print SHL "time tblastn -query $profolder/proteinsOfInterest.fasta -db $srcfolder/$sub/$file -out 03.blast/01.tblastn/$new.blast.out -evalue 1e-5  -outfmt 6 -num_threads 4 -max_target_seqs 100000\n";
#		print SHL "cd ../../../";
		
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -pe thread 4 -e 01.script/tblastn.$file.e -o 01.script/tblastn.$file.o $shell");
	}
	
	close(SUB);
}


close(SRC);