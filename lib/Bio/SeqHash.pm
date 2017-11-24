package Bio::SeqHash;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(fa2hs);

# VERSION: 
# ABSTRACT: get one or more sequences from a FASTA file quickly.

=head1 SYNOPSIS

  # use it in object-oriented way;
  
  use Bio::SeqHash;
  my $obj = Bio::SeqHash->new(file => "test.fa");
  my $hs = $obj->fa2hs; # get a HashRef coverted from the test.fa
  my $seq = $obj->get_seq("seq_id"); # get the sequence of "seq_id"(only the sequence)
  my $seq_fa = $obj->get_id_seq("seq_id"); # get the sequence of "seq_id"(in the FASTA format)
  $obj->get_seqs_batch('id_list.txt', 'output.fa');  # extract specified sequence to output file

  # use it in Common mode;

  use Bio::SeqHash "fa2hs";
  my $hs = fa2hs("in.fa");


=head1 DESCRIPTION

Currently, there do have some modules that can operate the FASTA file such as Bio::SeqIO, 
But it only provide some basic operation to obtain the information about sequence. In my daily work,
I still have to write some repetitive code. So this module is write to perform a deeper wrapper for operating FASTA file
Notice: this module is not suitable for the FASTA file that is extremble big.


=head1 METHODS

=cut

sub new {
  my $class = shift;
  my $self =  ref $_[0] ? $_[0] : {@_};
  $self->{file} || die `file parameter is not exist`;
  bless $self, $class;
}

=head2 fa2hs

  Convert a fasta file into a HashRef variable. If the C<file> parameter have been passed
  into during the process of new, here needs no parameter, otherwise you have to provide
  the path of a fasta file.

=cut

sub fa2hs {
  my $fa = ref $_[0] ? $_[0]->{file} : $_[0];
  open my $file, "<", "$fa" or  die "Can not open $fa $!";
  my (%hs, $name);
  while (my $line = <$file>) {
    chomp($line);
    if ($line =~/^>(\S+)/) {
      $name = $1;
    } else {
      $hs{$name} .= $line;
    }
  }
  close($file);
  return \%hs;
}

sub _initialize {
  my $self = shift;
  $self->{id2seq} = $self->fa2hs();
}

=head2 get_id_seq

  get a sequence by a id in FASTA format

=cut

sub get_id_seq {
  my ($self, $id) = @_;
  $self->_initialize() unless (exists $self->{id2seq});
  return ">$id\n" . $self->{id2seq}->{$id} . "\n";
}

=head2 get_seq

  get a sequence by a id

=cut

sub get_seq {
  my ($self, $id) = @_;
  $self->_initialize() unless (exists $self->{id2seq});
  return $self->{id2seq}{$id};
}

=head2 get_seqs_batch

  extract specified gene list from input file

=cut

sub get_seqs_batch {
  my ($self, $id_file, $outfile) = @_;
  open my $IN, "<",  $id_file or die "Can not open $id_file $!";
  my @ids = <$IN>;
  chomp @ids;
  open my $OUT, ">", $outfile or die "Can not open $outfile $!";
  for my $id (@ids) {
    print $OUT $self->get_id_seq($id);
  }
}

# may be use later
sub rename_seqs {
  
}

1;

