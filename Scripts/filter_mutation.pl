
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
        my $mutantions=$line=~s/(\w)/$1/g;
        #print "$mis:$unknown:$cluster:$mutations\n";
        next if $mis>=3;
        next if $mutantions<1;
        #next unless $mutations==1;
        print "$_\t$mis:$unknown:$cluster:$mutations\n";
    }
}
