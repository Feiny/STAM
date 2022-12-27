
#!/usr/bin/perl -w
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
    if($key=~/^#/){
        print "$hash{$key}";
    }else{
        my $i=0;
        my @data;
        my @input=split(/\n/, $hash{$key});
        foreach(@input){
            chomp;
            my @line=split/\t/,$_;
            for my $k(0 .. $#line){
                $data[$k][$i]=$line[$k];
            }
            $i++;
        }
        my $j=0;
        my @trans;
        for(my $n=0;$n<=$#data;$n++){
             my @line = @{$data[$n]};
             if($n<=3){
                  for my $k(0 .. $#line){
                      $trans[$k][$j]=$line[$k];
                  }
                  $j++;
             }elsif($n>3 and $n<$#data){
                  my $line=join "\t", @line;
                  my $count=$line=~s/(\w)/$1/g; #AT
                  if($count>1){   ## 1 or 2?
                      foreach(@line){
                          $_=~s/\w/,/g
                      }
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
        foreach (@trans){
            print join("\t", @{$_}), "\n";
        }
    }
}
