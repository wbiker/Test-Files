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
Test::Simple->import(tests => 4);

use Test::Files;

dir_contains_ok('t/missing_dir', [qw(some files)], "missing dir");
dir_contains_ok('t',             "simple_arg",     "anon. array expected");
dir_contains_ok(
    't/lib', [qw(Test Test/Simple Test/Simple/Catch.pm)], "passing"
);
dir_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Simple.pm)], "failing"
);

END {
#    print "out:$$out:tuo\nerr:$$err:rre\n";
#    exit;
    My::Test::ok($$out eq <<"EOF", "standard out for dir_contains_ok");
1..4
not ok 1 - missing dir
not ok 2 - anon. array expected
ok 3 - passing
not ok 4 - failing
EOF

    my $expected = <<'EOF';
#     Failed test (t/05dir_contains_ok.t at line 42)
# t/missing_dir absent
#     Failed test (t/05dir_contains_ok.t at line 43)
# dir_contains_ok requires array ref as second arg
#     Failed test (t/05dir_contains_ok.t at line 47)
# failed to see these: A Test/Simple/Simple.pm
EOF

#print "AFTER:$count:\n$err\n";

    My::Test::ok($$err eq $expected, "error text for dir_contains_ok");

    Test::Builder->new->no_ending(1);
    exit 0;
}

