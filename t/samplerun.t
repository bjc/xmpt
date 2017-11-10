# -*- mode: perl -*-

use Test::More tests => 3;

use strict;
use warnings;

my $config = 't/fixtures/localhost.conf';
my $testplan = 't/fixtures/testplan';
my $input = 't/fixtures/input';

subtest 'standard input', sub {
  my $cmd = "./xmpt -c $config -p $testplan";
  my $xmptfh = new IO::File("|$cmd") or BAIL_OUT "Can't run '$cmd': $!.\n";
  my $inputfh = new IO::File($input) or
    BAIL_OUT "Couldn't open $input for reading: $!.\n";
  while (<$inputfh>) {
    print $xmptfh $_;
  }
  $inputfh->close;
  $xmptfh->close;
  ok($? == 0, 'Standard input redirect');
};

subtest 'timeout', sub {
  my $cmd = "./xmpt -t 1 -c $config -p $testplan cat 2>/dev/null";
  local $SIG{ALRM} = sub { fail("Timed out running $cmd.") };
  alarm 5;
  system $cmd;
  ok(($? >> 8) != 0, 'Timeout test');
};

subtest 'I/O redirected to cat', sub {
  my $cmd = "./xmpt -c $config -p $testplan cat $input 2>/dev/null";
  local $SIG{ALRM} = sub { fail("Timed out running $cmd.") };
  alarm 10;
  ok((system($cmd) >> 8) == 0, 'I/O redirected to cat');
  alarm 0;
};
