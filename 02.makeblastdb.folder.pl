#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/fastq2fasta.*sh");

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fasta$|^OrAe.+fna$/, readdir(SUB)));
	
	foreach my $file (@files){
		my $shell = "01.script/makeblastdb.$file.sh";
		open(SHL, ">$shell");
		print SHL "#!/bin/bash\n\n";
		print SHL "time makeblastdb -in $srcfolder/$sub/$file -dbtype 'nucl'\n";
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -e 01.script/makeblastdb.$file.e -o 01.script/makeblastdb.$file.o $shell");
		#system("rm $shell");
	}
	
	close(SUB);
}


close(SRC);