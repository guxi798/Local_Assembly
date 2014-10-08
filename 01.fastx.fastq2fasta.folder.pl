#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $outfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/fastx.quality*");

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+filter$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/filter/fasta/;
		my $shell = "01.script/fastx.fastq2fasta.$file.sh";
		open(SHL, ">$shell");
		
		print SHL "#!/bin/bash\n\n";
		print SHL "export PATH=\$PATH:/usr/local/fastx/latest/bin/\n\n";
		print SHL "time /usr/local/fastx/latest/bin/fastq_to_fasta -i $srcfolder/$sub/$file -o $srcfolder/$sub/$new -n\n";
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -e 01.script/fastx.fastq2fasta.$file.e -o 01.script/fastx.fastq2fasta.$file.o $shell");
	}
	
	close(SUB);
}


close(SRC);