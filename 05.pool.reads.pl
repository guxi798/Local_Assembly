#!/usr/bin/perl -w
use strict;

my $srcfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;

opendir(SRC, "$srcfolder") or die "Cannot open $srcfolder: $!";
my @all = readdir(SRC);
my @illfiles = sort(grep(/fasta$/, @all));
my @f5ffiles = sort(grep(/fna$/, @all));

print join("\n", @illfiles), "\n";
print join("\n", @f5ffiles), "\n";

system("mkdir -p $tgtfolder");

open(TGT1, ">$tgtfolder/trinity.left.fasta");
open(TGT2, ">$tgtfolder/trinity.right.fasta");
open(TGT3, ">$tgtfolder/cap3.single.fasta");
open(TGT4, ">$tgtfolder/newbler.single.fna");

while(my $illfile = shift @illfiles){
	my %hash1 = ();
	my %hash2 = ();
	
	open(ILL1, "$srcfolder/$illfile") or die "Cannot open $illfile: $!";
	if($illfile =~ /read1/){
		while (my $line = <ILL1>){
			chomp $line;
			if($line =~ /^>/){
				my $key = $line;
				$key =~ s/^>//;
				$key =~ s/1$//;
				$line = <ILL1>;
				chomp $line;
				$hash1{$key} = $line;
			}
		}
	}else{
		print "ERROR: The pair files don't match!\n";
	}
	close(ILL1);
	
	$illfile = shift @illfiles;
	open(ILL2, "$srcfolder/$illfile") or die "Cannot open $illfile: $!";
	if($illfile =~ /read2/){
		while (my $line = <ILL2>){
			chomp $line;
			if($line =~ /^>/){
				my $key = $line;
				$key =~ s/^>//;
				$key =~ s/2$//;
				$line = <ILL2>;
				chomp $line;
				$hash2{$key} = $line;
				if(exists $hash1{$key}){
					print TGT1 ">$key","1\n$hash1{$key}\n";
					print TGT2 ">$key","2\n$hash2{$key}\n";
				}else{
					print TGT3 ">$key","2\n$hash2{$key}\n";
				}
			}
		}
	}
	close(ILL2);
	
	foreach my $key (sort(keys %hash1)){
		if(not exists $hash2{$key}){
			print TGT3 ">$key","1\n$hash1{$key}\n";
		}
	}
}

close(TGT1);
close(TGT2);
close(TGT3);

foreach my $f5ffile (@f5ffiles){
	open(FOR, "$srcfolder/$f5ffile") or die "Cannot open $f5ffile: $!";
	foreach my $line (<FOR>){
		print TGT4 $line;
	}
	close(FOR);
}
close(TGT4);