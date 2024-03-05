#!/usr/bin/perl -w
use strict;

my (%h1, %h2);
$/ = "\>";
open(my $in1, $ARGV[0]) or die "Cannot open input file: $!";

while (<$in1>) {
    chomp;
    next unless my ($id, @fastq) = split /\n/;
    my @id = split(/\|/, $id); # To modify the regular expression based on the sequence name
#    my $tran = $id[0];
    my $gene = $id[0];
    $gene =~ s/\.\d+\z//;
    push @{$h2{$id}}, @fastq;
    $h1{$gene} ||= $id;
    $h1{$gene} = $id if length(join("", @{$h2{$h1{$gene}}})) < length(join("", @fastq));
}

$/ = "\n";
foreach my $gene (keys %h1) {
    print ">$gene\t$h1{$gene}\n";
    print join("\n", @{$h2{$h1{$gene}}});
    print $/;
}
