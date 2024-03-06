#!/usr/bin/perl -w
use strict;

my %id;
open(my $in1_fh, "<", $ARGV[0]) or die "Cannot open input file '$ARGV[0]': $!";
while (my $line = <$in1_fh>) {
    chomp($line);
    $line =~ s/>//;
    $id{$line} = 1;
}
close($in1_fh);

open(my $in2_fh, "<", $ARGV[1]) or die "Cannot open input file '$ARGV[1]': $!";
while (my $line = <$in2_fh>) {
    chomp($line);
    $line =~ s/>//;
    $id{$line} = 1;
}
close($in2_fh);

$/ = "\>";
open(my $in3_fh, "<", $ARGV[2]) or die "Cannot open input file '$ARGV[2]': $!";
while (<$in3_fh>) {
    chomp;
    next unless my ($name, $sequence) = split /\n/;
    my @name = split(/\|/, $name);
    print ">$name\n$sequence\n" unless exists $id{$name[$#name]}; 
}
close($in3_fh);
