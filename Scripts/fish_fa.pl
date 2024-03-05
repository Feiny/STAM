#!/usr/bin/perl -w
use strict;

my %id;
open(my $in1_fh, "<", $ARGV[0]) or die "Cannot open input file '$ARGV[0]': $!";
while (my $line = <$in1_fh>) {
    chomp($line);
    my @fields = split(/\s+/, $line);
    $id{$fields[0]} = 1;
}
close($in1_fh);

$/ = ">";
open(my $in2_fh, "gzip -dc $ARGV[1]|") or die "Cannot open input file '$ARGV[1]': $!";
while (my $block = <$in2_fh>) {
    chomp($block);
    $block =~ s/^>//;
    next unless my ($id, $seq) = split(/\n/, $block, 2);
    my @id_fields = split(/\s+/, $id);
    print ">$id\n$seq" if exists $id{$id_fields[0]};
}
close($in2_fh);
