#!/usr/bin/perl
use strict;
use warnings;

while (<>) {
    if (/^#/) {
        next if /^##/;
        s/_.*?\t/\t/g;
        my @head = split;
        my $print = join("\t", @head[0,1,3,4,9..$#head]);
        print "$print\n";
    } else {
        my @line = split;
        next unless $line[6] eq "PASS";
        for (my $i=9; $i<=$#line; $i++) {
            $line[$i] =~ s/\|/\//;
            my @genotype = split(/:/, $line[$i]);
            $line[$i] = "./." unless $genotype[2];
            if ($genotype[0] =~ /0\/0|1\/1/ and $genotype[2] > 4) {
                $line[$i] = $genotype[0];
            } else {
                $line[$i] = "./.";
            }
        }
        my $print = join("\t", @line[0,1,3,4,9..$#line]);
        my $info = join("\t", @line[9..15]); 
        print "$print\n" if $info =~ /0\/0/ and $info =~ /1\/1/;
    }
}
