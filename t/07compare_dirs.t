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

compare_dirs_ok('t/missing_dir', 't/lib',         "missing first dir");
compare_dirs_ok('t/lib',         't/missing_dir', "missing second dir");
compare_dirs_ok('t/lib',         't/lib_fail',    "failing due to text diff");
compare_dirs_ok('t/lib',         't/lib_pass',    "passing");

END {
#    print "out:$$out:tuo\nerr:$$err:rre\n";
#    exit;
    My::Test::ok($$out eq <<"EOF", "standard out for dir_only_contains_ok");
1..4
not ok 1 - missing first dir
not ok 2 - missing second dir
not ok 3 - failing due to text diff
ok 4 - passing
EOF

    my $expected = <<'EOF';
#     Failed test (t/07compare_dirs.t at line 42)
# t/missing_dir is not a valid directory
#     Failed test (t/07compare_dirs.t at line 43)
# t/missing_dir is not a valid directory
#     Failed test (t/07compare_dirs.t at line 44)
# +---+-----------------------------------+---+---------------------------------+
# | Ln|t/lib/Test/Simple/Catch.pm         | Ln|t/lib_fail/Test/Simple/Catch.pm  |
# +---+-----------------------------------+---+---------------------------------+
# | 12|$t->failure_output($err_fh);       | 12|$t->failure_output($err_fh);     |
# | 13|$t->todo_output($err_fh);          | 13|$t->todo_output($err_fh);        |
# | 14|                                   | 14|                                 |
# * 15|sub caught { return($out, $err) }  * 15|sub caught {                     *
# |   |                                   * 16|    return($out, $err)           *
# |   |                                   * 17|}                                *
# | 16|                                   | 18|                                 |
# | 17|sub PRINT  {                       | 19|sub PRINT  {                     |
# | 18|    my $self = shift;              | 20|    my $self = shift;            |
# +---+-----------------------------------+---+---------------------------------+
EOF

    My::Test::ok($$err eq $expected, "error text for dir_only_contains_ok");

    Test::Builder->new->no_ending(1);
    exit 0;
}

