#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/fastx.nucl*");

foreach my $sub (@subs){
	opendir(SUB, "$srcfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fastq$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my $new = $file;
		$new =~ s/fastq/filter/;
		my $shell = "01.script/fastx.quality.$file.sh";
		open(SHL, ">$shell");
		
		print SHL "#!/bin/bash\n\n";
		print SHL "export PATH=\$PATH:/usr/local/fastx/latest/bin/\n\n";
		if($file =~ /OrAe52G/){
			print SHL "time fastq_quality_filter -i $srcfolder/$sub/$file -o $srcfolder/$sub/$new -q 28 -p 60 -Q33\n";			
		}else{
			print SHL "time fastq_quality_filter -i $srcfolder/$sub/$file -o $srcfolder/$sub/$new -q 28 -p 60\n";
		}
		close(SHL);
		
		system("chmod u+x $shell");
		system("qsub -q rcc-30d -e 01.script/fastx.quality.$file.e -o 01.script/fastx.quality.$file.o $shell");
	}
	
	close(SUB);
}


close(SRC);