#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fastq$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/fastq/fasta/;
		my $shell = "01.script/fastq2fasta.$file.sh";
		open(SHL, ">$shell");
		print SHL "#!/bin/bash\n\n";
		print SHL "time awk '1 == (NR) % 4 || 2 == (NR) % 4' $srcfolder/$sub/$file | awk '{gsub(\"^@\", \">\", \$0); print \$0}' > $srcfolder/$sub/$new\n";
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d $shell");
		#system("rm $shell");
	}
	
	close(SUB);
}


close(SRC);