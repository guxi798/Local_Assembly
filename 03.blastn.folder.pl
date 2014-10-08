#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $profolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/tblastn.*");

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fasta$|^OrAe.+fna$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/\.fasta|\.fna//;
		my $shell = "01.script/blastn.$file.sh";
		open(SHL, ">$shell");
		print SHL "#!/bin/bash\n\n";
		
		print SHL "mkdir -p 02.blast/02.blastn/$new";
		print SHL "time blastn -query $profolder/transcriptsOfInterest.fasta -db $srcfolder/$sub/$file -out 02.blast/02.blastn/$new/$new.blast.out -evalue 1e-10  -outfmt 6 -num_threads 4\n";
		
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -pe thread 4 -e 01.script/blastn.$file.e -o 01.script/blastn.$file.o $shell");
	}
	
	close(SUB);
}


close(SRC);