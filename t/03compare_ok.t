use strict;

use Test::Builder::Tester tests => 5;

use Test::Files;

test_out("not ok 1 - first file missing");
my $line = line_num(+3);
test_diag("    Failed test (t/03compare_ok.t at line $line)",
"t/missing absent");
compare_ok("t/missing",    "t/ok_pass.dat",       "first file missing");
test_test("first file missing");

test_out("not ok 1 - second file missing");
$line = line_num(+3);
test_diag("    Failed test (t/03compare_ok.t at line $line)",
"t/missing absent");
compare_ok("t/ok_pass.dat", "t/missing",          "second file missing");
test_test("second file missing");

test_out("not ok 1 - both files missing");
$line = line_num(+4);
test_diag("    Failed test (t/03compare_ok.t at line $line)",
"t/absent absent",
"t/missing absent");
compare_ok("t/absent",      "t/missing",          "both files missing");
test_test("both files missing");

test_out("ok 1 - passing file");
compare_ok("t/ok_pass.dat", "t/ok_pass.same.dat", "passing file");
test_test("passing file");

test_out("not ok 1 - failing file");
$line = line_num(+9);
test_diag("    Failed test (t/03compare_ok.t at line $line)",
'+---+--------------------+-------------------+',
'|   |Got                 |Expected           |',
'| Ln|                    |                   |',
'+---+--------------------+-------------------+',
'|  1|This file           |This file          |',
'*  2|is for 03ok_pass.t  |is for many tests  *',
'+---+--------------------+-------------------+'  );
compare_ok("t/ok_pass.dat", "t/ok_pass.diff.dat", "failing file");
test_test("failing file");

