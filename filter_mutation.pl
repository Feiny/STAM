#!/usr/bin/perl -w
while(<>){
    if(/\A#/){
        print;
    }else{
        chomp;
        my @line=split;
        #next unless $line[11]=~/\w/;
        my $line= join "\t", @line[4..$#line];
        my $mis=$line=~s/\./\./g;
        my $unknown=$line=~s/-/-/g;
        my $cluster=$line=~s/,/,/g;
        my $mutants=$line=~s/(\w)/$1/g;
        #print "$mis:$unknown:$cluster:$mutants\n";
        next if $mis>=3;
        next if $mutants<1;
        #next unless $mutants==1;
        print "$_\t$mis:$unknown:$cluster:$mutants\n";
    }
}
