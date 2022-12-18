#!/usr/bin/perl -w
while(<>){
  if(/\A#/){
    print;
  }else{
    my @line=split;
    next if (length($line[2])!= 1 or length($line[3])!=1);
    next unless ($line[2]=~/[GA]/ and $line[3]=~/[GA]/) or ($line[2]=~/[CT]/ and $line[3]=~/[CT]/);
    for(my $i=4; $i<=$#line; $i++){
      if ($line[$i] eq "0/0"){
        if ($line[2]=~/[AT]/){
          $line[$i]=$line[2];
        }else{
          $line[$i]="-";
        }
      }elsif ($line[$i] eq "1/1"){
        if ($line[3]=~/[AT]/){
          $line[$i]=$line[3];
        }else{
          $line[$i]="-";
        }
      }else{
        $line[$i]=".";
      }
    }

    my $count= join "\t", @line[4..$#line];
    my $i=$count=~s/([AT])/$1/g;
    if ($i<=2){
    print join "\t", @line;
    print "\n";}
  }
}
