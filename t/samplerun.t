# -*- mode: perl -*-

use Test::More tests => 3;

use IO::File;

use strict;
use warnings;

my $env		= 't/fixtures/sample.env';
my $testplan	= 't/fixtures/sample.plan';
my $input	= 't/fixtures/sample.input';

do {
  my $cmd = "./xmpt -e $env -p $testplan";
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

do {
  my $cmd = "./xmpt -t 1 -e $env -p $testplan cat 2>/dev/null";
  local $SIG{ALRM} = sub { fail("Timed out running $cmd.") };
  alarm 5;
  system $cmd;
  ok(($? >> 8) != 0, 'Timeout test');
};

do {
  my $cmd = "./xmpt -e $env -p $testplan cat $input 2>/dev/null";
  local $SIG{ALRM} = sub { fail("Timed out running $cmd.") };
  alarm 10;
  ok((system($cmd) >> 8) == 0, 'I/O redirected to cat');
  alarm 0;
};
