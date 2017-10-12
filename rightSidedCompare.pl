#!/usr/bin/perl -w
use warnings;
use strict;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
#Usage: rightSidedCompare.pl -a refFile -b compareFile [-d] col1 col2 col3..
#Given 2 tsv files and specifed column numbers (zero based indices) prints out lines of file 2 that are the same in file 1 for the specified columns.
#Also creates a disjoint file of lines only present in file 2.
#Add d flag to print both intersection files

my $FS = "\t"; #Change Input Field Separator here
#Getting File Names and input Args
my %options = ();
GetOptions("d" => \my $d,
			"a=s" => \my $ref,
			"b=s" => \my $compare_file,) #flag
	or die("Error in command line arguments\n");

#Getting column numbers
my @columns;
foreach my $i (@ARGV) {
	push @columns, $i;
}

#Ensuring all arguments are present
if (! (defined $ref && defined $compare_file && (scalar @columns >= 1))) {
	die("Usage: rightSidedCompare.pl -a refFile -b compareFile [-d] columns")
}

my $outComp = "disjoint_".$compare_file; #the two outfiles
my %store = (); #key is the columns specified; #value is the an array of lines corresponding to the hash.
my @uFile1;

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
	push @{ $store{$key} }, join("\t", @fields);
}

open(my $fh2, '<encoding(UTF-8)', $compare_file)
	or die "Could not open file $compare_file";
while (my $line = <$fh2>) {
	chomp $line;
	my @fields = split(/$FS/, $line);
	my $key = makeKey(@fields);
	if (exists $store{$key}) {
		if (defined $d) {
			for (my $i = 0; $i < scalar @{ $store{$key} }; $i++) {
				print join("\t", @fields)."\t".$store{$key}->[$i]."\n";
			}
		} else {
			print join("\t", @fields)."\n";
		}
	} else {
		push @uFile1, join("\t", @fields);
	}
}
Write2File(@uFile1, $outComp);
