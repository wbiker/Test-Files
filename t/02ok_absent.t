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
Test::Simple->import(tests => 1);

use Test::Files;

file_ok("t/missing", "This file is really absent", "absent file");

END {
    My::Test::ok(
        $$out eq "1..1\nnot ok 1 - absent file\n",
        "missing file"
    );
    My::Test::ok($$err eq <<"EOJ", "missing file error text");
#     Failed test (t/02ok_absent.t at line 42)
# t/missing absent
EOJ
    Test::Builder->new->no_ending(1);
    exit 0;
}

