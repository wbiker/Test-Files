use strict;
use Test::Builder::Tester tests => 5;

use Test::Files;

test_out("not ok 1 - missing first dir");
my $line = line_num(+3);
test_diag("    Failed test (t/07comp_dir_f.t at line $line)",
"t/missing_dir is not a valid directory");
compare_dirs_filter_ok('t/missing_dir', 't/time', sub{}, "missing first dir");
test_test("missing first dir");

test_out("not ok 1 - missing second dir");
$line = line_num(+3);
test_diag("    Failed test (t/07comp_dir_f.t at line $line)",
"t/missing_dir is not a valid directory");
compare_dirs_filter_ok('t/time', 't/missing_dir', sub{}, "missing second dir");
test_test("missing second dir");

test_out("not ok 1 - missing coderef");
$line = line_num(+3);
test_diag("    Failed test (t/07comp_dir_f.t at line $line)",
"Third argument to compare_dirs_filter_ok must be a code reference (or undef)");
compare_dirs_filter_ok('t/time', 't/lib_fail',    "missing coderef");
test_test("missing coderef");

test_out("not ok 1 - failing noop filter");
$line = line_num(+9);
test_diag("    Failed test (t/07comp_dir_f.t at line $line)",
'+---+----------------------------------------------------------+----------------------------------------------------------+',
'| Ln|t/time/time_stamp.dat                                     |t/time2/time_stamp.dat                                    |',
'+---+----------------------------------------------------------+----------------------------------------------------------+',
'|  1|This file                                                 |This file                                                 |',
'|  2|is for 03ok_pass.t                                        |is for 03ok_pass.t                                        |',
'*  3|Touched on: Wed Oct 15 12:38:12 CDT 2003, this afternoon  |Touched on: Wed Oct 15 12:38:42 CDT 2003, this afternoon  *',
'+---+----------------------------------------------------------+----------------------------------------------------------+');
compare_dirs_filter_ok('t/time', 't/time2', \&noop, "failing noop filter");
test_test("failing noop filter");

sub noop {
    return $_[0];
}

test_out("ok 1 - passing");
compare_dirs_filter_ok('t/time', 't/time2', \&four_to_one, "passing");
test_test("passing");

sub four_to_one {
    my $line =  shift;
    $line    =~ s/4/1/;
    return $line;
}

