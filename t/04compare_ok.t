# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

use strict;

require Test::Simple::Catch;
my ($out, $err) = Test::Simple::Catch::caught();

package My::Test;

print "1..3\n";

my $test_num = 1;
# Utility testing functions.  Stolen from the Test::Simple test suite.
sub ok ($;$) {
    my($test, $name) = @_;
    my $ok = '';
    $ok .= "not " unless $test;
    $ok .= "ok $test_num";
    $ok .= " - $name" if defined $name;
    $ok .= "\n";
    print $ok;
    $test_num++;
}

package main;
require Test::Simple;
Test::Simple->import(tests => 5);

use Test::Files;

compare_ok("t/missing",    "t/ok_pass.dat",       "first file missing");
compare_ok("t/ok_pass.dat", "t/missing",          "second file missing");
compare_ok("t/absent",      "t/missing",          "both files missing");
compare_ok("t/ok_pass.dat", "t/ok_pass.same.dat", "passing file");
compare_ok("t/ok_pass.dat", "t/ok_pass.diff.dat", "failing file");

END {
#    print "out:$$out:tuo\nerr:$$err:rre\n";
#    exit;
    My::Test::ok($$out eq <<"EOF", "standard out for compare_ok");
1..5
not ok 1 - first file missing
not ok 2 - second file missing
not ok 3 - both files missing
ok 4 - passing file
not ok 5 - failing file
EOF

    my @err_lines = split /\n/, $$err;
    my $count = 0;
    while ((my $line = shift @err_lines) !~ /---/) {
        $count++ if $line =~ /Failed test/;
    }
#    while ((my $line = shift @err_lines) =~ /Failed/) { $count++ }
    my $err = join "\n", @err_lines;
    my $expected = <<'EOF';
# | Ln|Got                 |Expected           |
# +---+--------------------+-------------------+
# |  1|This file           |This file          |
# *  2|is for 03ok_pass.t  |is for many tests  *
# +---+--------------------+-------------------+
EOF

#print "AFTER:$count:\n$err\n";

    My::Test::ok("$err\n" eq $expected, "error text for compare_ok");
    My::Test::ok($count eq 4, "failure count");

    Test::Builder->new->no_ending(1);
    exit 0;
}

