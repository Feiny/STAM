
#!/usr/bin/perl -w
my %id;
open(IN1,"<$ARGV[0]") or die;
while(<IN1>){
  my @line=split;
  $id{$line[0]}=1;
}
close IN1;

$/=">";
open(IN2,"<$ARGV[1]") or die;
while(<IN2>){
  s/>//;
  next unless my ($id, $seq)=split(/\n/, $_, 2);
  my @id=split(/\s/,$id);
  print ">$id$seq" if exists ($id{$id[0]});
}
close IN2;
