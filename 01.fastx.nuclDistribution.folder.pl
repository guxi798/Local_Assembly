#!/usr/bin/perl -w

use strict;

my $srcfolder = shift @ARGV;
my $outfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @files = sort(grep(/^OrAe/, readdir(SRC)));

system("rm 01.script/fastx.plots*");

foreach my $file (@files){
	my $new = $file;
	$new =~ s/stats.txt/nucl.png/;
	my $shell = "01.script/fastx.nucl.$file.sh";
	open(SHL, ">$shell");
		
	print SHL "#!/bin/bash\n\n";
	print SHL "export PATH=/usr/local/gnuplot/4.6.0/:\$PATH:/usr/local/fastx/latest/bin/:\n\n";
	print SHL "time fastx_nucleotide_distribution_graph.sh -i $srcfolder/$file -o $outfolder/$new\n";
	close(SHL);
		
	system("chmod u+x $shell");
	system("qsub -q rcc-30d -e 01.script/fastx.nucl.$file.e -o 01.script/fastx.nucl.$file.o $shell");
}
	

close(SRC);