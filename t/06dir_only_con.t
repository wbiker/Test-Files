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
Test::Simple->import(tests => 6);

use Test::Files;

dir_only_contains_ok('t/missing_dir', [qw(some files)], "missing dir");
dir_only_contains_ok('t',             "simple_arg",     "anon. array expected");
dir_only_contains_ok(
    't/lib', [qw(Test Test/Simple Test/Simple/Catch.pm)], "passing"
);
dir_only_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Catch.pm)], "failing because of extra"
);
dir_only_contains_ok(
    't/lib', [qw(Test Test/Simple)], "failing because of missing"
);
dir_only_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Simple.pm)], "failing both"
);

END {
#    print "out:$$out:tuo\nerr:$$err:rre\n";
#    exit;
    My::Test::ok($$out eq <<"EOF", "standard out for dir_only_contains_ok");
1..6
not ok 1 - missing dir
not ok 2 - anon. array expected
ok 3 - passing
not ok 4 - failing because of extra
not ok 5 - failing because of missing
not ok 6 - failing both
EOF

    my $expected = <<'EOF';
#     Failed test (t/06dir_only_con.t at line 42)
# t/missing_dir absent
#     Failed test (t/06dir_only_con.t at line 43)
# dir_only_contains_ok requires array ref as second arg
#     Failed test (t/06dir_only_con.t at line 47)
# failed to see these: A
#     Failed test (t/06dir_only_con.t at line 50)
# unexpectedly saw: Test/Simple/Catch.pm
#     Failed test (t/06dir_only_con.t at line 53)
# failed to see these: A Test/Simple/Simple.pm
# unexpectedly saw: Test/Simple/Catch.pm
EOF

    My::Test::ok($$err eq $expected, "error text for dir_only_contains_ok");

    Test::Builder->new->no_ending(1);
    exit 0;
}

