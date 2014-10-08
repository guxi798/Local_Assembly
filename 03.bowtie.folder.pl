#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $profolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fasta$|^OrAe.+fna$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/fastq/fasta/;
		my $shell = "01.script/blastn.$file.sh";
		open(SHL, ">$shell");
		print SHL "#!/bin/bash\n\n";
		
		print SHL "cd 02.blast";
		print SHL "time bowtie blastn -query ../$profolder/transcriptsOfInterest.fasta -db ../$srcfolder/$sub/$file -outfmt 6 -size 1000 -queue rcc-30d\n";
		print SHL "cd ../";
		
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d $shell");
		system("rm $shell");
	}
	
	close(SUB);
}


close(SRC);