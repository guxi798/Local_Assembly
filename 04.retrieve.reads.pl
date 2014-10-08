#!/usr/bin/perl -w

use strict;

my $qryfolder = shift @ARGV;
my $srcfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;

opendir(SRC, $srcfolder) or die "Cannot open $srcfolder: $!";
my @sbjfiles = sort(grep(/^OrAe/, readdir(SRC)));
close(SRC);

system("rm 01.script/tblastn*");
system("mkdir -p $tgtfolder");

my %hash = ();

foreach my $sbjfile (@sbjfiles){
	my $key = $sbjfile;
	$key =~ s/\.blast\.out//;
	
	open(SBJ, "$srcfolder/$sbjfile") or die "Cannot open $sbjfile: $!";
	foreach my $line (<SBJ>){
		chomp $line;
		my @lines = split(/\t/, $line);
		$hash{$key}{$lines[1]} = 0;
	}
	
	close(SBJ);
}

opendir(QRY, $qryfolder) or die "Cannot open $srcfolder: $!";
my @subs = sort(grep(/^OrAe/, readdir(QRY)));
close(QRY);

foreach my $sub (@subs){
	opendir(SUB, "$qryfolder/$sub") or die "Cannot open $sub: $!";
	my @files = sort(grep(/^OrAe.+fasta$|^OrAe.+fna$/, readdir(SUB)));
	
	if(!@files){next;}
	
	foreach my $file (@files){
		my @key = split(/\./, $file);
		my $new = $file;
		$new =~ s/fasta$/retrieve.fasta/;
		$new =~ s/fna$/retrieve.fna/;
		
		open(FIL, "$qryfolder/$sub/$file") or die "Cannot open $file: $!";
		open(TGT, ">$tgtfolder/$new") or die "Cannot open $new: $!";
		
		my $mark = 0;
		
		foreach my $line (<FIL>){
			if($line =~ /^>/){
				my $id = $line;
				chomp $id;
				if($new =~ /fna$/){
					my @ids = split(/\s+/, $id);
					$id = $ids[0];
				}
				$id =~ s/>//;
				
				if(exists $hash{$key[0]}{$id}){
					print TGT $line;
					$mark = 1;
				}
				else{
					$mark = 0;
					#print "No reads found in $key[0]\n";
				}
			}else{
				if($mark == 1){
					print TGT $line;
				}
			}
		}
		
		close(FIL);
		close(TGT);
	}
	
	close(SUB);
}
