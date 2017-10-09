#!/usr/bin/perl -w
use warnings;
use strict;
use Data::Dumper;
##IMPORTANT sort | uniq output in the end
#run as ./mergeHAPwithShapeit.pl file.intermediate file.haplotype

my $FS = "\t";
my ($phasedFile, $hapsFile, $part) = ($ARGV[0], $ARGV[1], $ARGV[2]);
my @tempStore = ();
my %store = ();
my %output = ();
sub parseInput {
	chomp($_[0]);
	return (split(/$_[1]/, $_[0])); #Splitting line and returning the lines
}
sub callHaplotype {
	my ($haps, $invert) = @_;
	for (my $i = 0; $i < scalar @{ $haps }; $i++) {
		if ($invert == 0) {
			my @fields = parseInput(@{ $haps }[$i], "\t");
			$output{join("\t",@fields[0.. 3])}++;
			print join("\t", @fields, $part)."\n";
		} else {
			my @fields = parseInput(@{ $haps }[$i], "\t");
			my @genotypes = parseInput($fields[-1], "\|");
			$output{join("\t",@fields[0.. 3])}++;
			print join("\t", @fields[0.. 3], $genotypes[2]."|".$genotypes[0], $part)."\n";
		}
	}
}
open( my $fh1, '<encoding(UTF-8)', $phasedFile)
	or die "Could not open file $phasedFile";
while (my $line = <$fh1>) {
	chomp $line;
	my @fields = parseInput($line, $FS);
	$store{join("\t",@fields[0.. 3])} = $fields[4];
}
open( my $fh, '<encoding(UTF-8)', $hapsFile)
	or die "Could not open file $hapsFile";
while (my $line = <$fh>) {
	chomp $line;
	my @fields = parseInput($line, $FS);
	if (substr($line, 0, 1) ne "B" && length($line) >= 2 && substr($line, 0, 1) ne "*") {
		if ($fields[8] !~ /MEC/) {
			push @tempStore, join("\t",@fields[3.. 6], $fields[1]."|".$fields[2]);
		}
	} else {
		for (my $i = 0; $i < scalar @tempStore; $i++) {
			my @phase = parseInput($tempStore[$i], "\t");
			my $invert = 0;
			if (exists $store{join("\t", @phase[0.. 3])}) {
				if ($phase[-1] ne $store{join("\t", @phase[0.. 3])}) {
					$invert = 1;
				}
					callHaplotype(\@tempStore,$invert);
					last;
				}
			}
			@tempStore = ();
		}
}
while (my ( $key, $value) = each %store) {
	if (! exists $output{$key}) {
		print $key."\t".$value."\t".$part."\n";
	}
}