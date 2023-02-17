
#!/usr/bin/perl
use strict;
use warnings;

my %hash;
my @array;

while(<>){
    my @line=split;
    $hash{$line[0]} .= $_;
    push @array, $line[0];
}

my %uniq;
my @uniq=grep{++$uniq{$_}<2}@array;

foreach my $key (@uniq){
    if($key =~ /^#/){
        print "$hash{$key}";
    }else{
        my @data;
        my @input=split(/\n/, $hash{$key});
        foreach(@input){
            chomp;
            my @line=split/\t/,$_;
            for my $k(0 .. $#line){
                $data[$k][$.-1]=$line[$k]; 
            }
        }

        my @trans;
        my $j=0;
        for my $n (0..$#data){
            my @line = @{$data[$n]};
            if($n<=3){
                for my $k(0 .. $#line){
                    $trans[$k][$j]=$line[$k];
                }
                $j++;
            }elsif($n>3 and $n<$#data){
                my $count= $line[$n]=~s/(\w)/$1/g; #AT
                if($count>1){   ## 1 or 2?
                    $_=~s/\w/,/g for @line;
                    for my $k(0 .. $#line){
                        $trans[$k][$j]=$line[$k];
                    }
                    $j++;
                }else{
                    for my $k(0 .. $#line){
                        $trans[$k][$j]=$line[$k];
                    }
                    $j++;
                }
            }elsif($n==$#data){
                for my $k(0 .. $#line){
                    $trans[$k][$j]=$line[$k];
                }
                $j++;
            }
         }

        for (@trans){
            print join("\t", @{$_}), "\n";
        }
    }
}
