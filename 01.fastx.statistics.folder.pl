#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $outfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fastq$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/fastq/stats.txt/;
		my $shell = "01.script/fastx.stats.$file.sh";
		open(SHL, ">$shell");
		
		print SHL "#!/bin/bash\n\n";
		print SHL "export PATH=\$PATH:/usr/local/fastx/latest/bin/\n\n";
		if($file =~ /OrAe52G/){
			print SHL "time fastx_quality_stats -Q33 -i $srcfolder/$sub/$file -o $outfolder/$new\n";
		}else{
			print SHL "time fastx_quality_stats -i $srcfolder/$sub/$file -o $outfolder/$new\n";
		}
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -e 01.script/fastx.stats.$file.e -o 01.script/fastx.stats.$file.o $shell");
		#system("rm $shell");
	}
	
	close(SUB);
}


close(SRC);