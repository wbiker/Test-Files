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

print "1..2\n";

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
Test::Simple->import(tests => 2);

use Test::Files;

file_ok("t/ok_pass.dat", <<"EOF", "passing text");
This file
is for 03ok_pass.t
EOF
file_ok("t/ok_pass.dat", "This file\nis wrong", "failing text");

END {
#    print "out:$$out:tuo\nerr:$$err:rre\n";
    My::Test::ok($$out eq <<"EOF", "standard out for simple ok");
1..2
ok 1 - passing text
not ok 2 - failing text
EOF

# The first line of error output from Test::Differences includes the
# absolute path of the Test::Files module, which won't match on users machine.
# So remove it before checking the output.
#    my @err_lines = split /\n/, $$err;
#    
#    my $err = join "\n", @err_lines;
    $$err =~ s{^# \| Ln\|.*}{}m;
    my $expected = <<'EOF';
#     Failed test (t/03file_ok.t at line 46)
# +---+--------------------------+-----------+
# |   |Got                       |Expected   |

# +---+--------------------------+-----------+
# |  1|This file                 |This file  |
# *  2|is for 03ok_pass.t\n      |is wrong   *
# +---+--------------------------+-----------+
EOF

    My::Test::ok($$err eq $expected, "error text for simple ok");

    Test::Builder->new->no_ending(1);
    exit 0;
}

