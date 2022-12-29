
#!/usr/bin/perl -w
open (IN1, "<$ARGV[0]") or die; # clustered.collapsed.group.id 
my %good;
while(<IN1>){
    my @line=split(/\s|,/, $_);
    for(my $i=1;$i<=$#line;$i++){
        $good{$line[$i]}=1;
    }
}
close IN1;

$/=">";
open (IN2, "<$ARGV[1]") or die; # hq.fasta
while(<IN2>){
  s/>//;
  next unless my ($id, $seq)=split(/\n/, $_, 2);
  my @id=split(/\s/,$id);
  print ">$id$seq" unless exists ($id{$id[0]});
}
close IN2;
