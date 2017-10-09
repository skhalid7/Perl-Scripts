#!/usr/bin/perl -w
use warnings;
use strict;
use Data::Dumper;
#./exactMatches.pl file 1 file2 0 1 2
#Given 2 tsv files and specifed column numbers (zero based indices) prints out lines of file 2 that are the same in file 1 for the specified columns.
#Also creates a disjoint file of lines only present in file 2.
#Add d flag to print both intersection files

my $FS = "\t"; #Change Input Field Separator here

my ($ref, $compare_file) = ($ARGV[0], $ARGV[1]);
$ref =~ s/\r//;
$compare_file =~ s/\r//;
my $outComp = "temp_disjoint_".$compare_file; #the two outfiles
my $outFile3 = "intersection_".$ref."_".$compare_file;

my @columns;
my $d = 0;
if ($ARGV[2] eq "d") {
	$d = 1;
}
#Getting column numbers
for (my $i = (2 + $d); $i < scalar @ARGV; $i++) {
	push @columns, $ARGV[$i];
}

my %store = (); #key is the columns specified; #value is the actual filename<===>line
my (@iFile, @uFile1);

sub makeKey {
	my @array;
	foreach my $i (@columns) {
		push @array, $_[$i];
	}
	return join("\t", @array);
}
sub Add2Hash {
	push @{ $store{$_[0]} }, $_[1]; #adding an element into the array of the hash
}

sub Write2File {
	my $outfile = pop @_;
	open(my $ofh, ">", $outfile)
	or die "Could not open file $outfile";
	foreach my $x (@_) {
		print $ofh "$x\n";
	}
	close $ofh;
}

##Main
open(my $fh1, '<encoding(UTF-8)', $ref)
	or die "Could not open file $ref";
while (my $line = <$fh1>) {
	chomp $line;
	my @fields = split(/$FS/, $line);
	my $key = makeKey(@fields);
	$store{$key}++;
}

open(my $fh2, '<encoding(UTF-8)', $compare_file)
	or die "Could not open file $ref";
while (my $line = <$fh2>) {
	chomp $line;
	my @fields = split(/$FS/, $line);
	my $key = makeKey(@fields);
	if (exists $store{$key}) {
		push @iFile, join("\t", @fields);
	} else {
		push @uFile1, join("\t", @fields);
	}
}

Write2File(@iFile, $outFile3);
Write2File(@uFile1, $outComp);