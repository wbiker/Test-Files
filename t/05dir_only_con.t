use Test::Builder::Tester tests => 6;

use Test::Files;

test_out("not ok 1 - missing dir");
my $line = line_num(+3);
test_diag("    Failed test (t/05dir_only_con.t at line $line)",
"t/missing_dir absent");
dir_only_contains_ok('t/missing_dir', [qw(some files)], "missing dir");
test_test("missing dir");

test_out("not ok 1 - anon. array expected");
$line = line_num(+3);
test_diag("    Failed test (t/05dir_only_con.t at line $line)",
"dir_only_contains_ok requires array ref as second arg");
dir_only_contains_ok('t',             "simple_arg",     "anon. array expected");
test_test("anon. array expected");

test_out("ok 1 - passing");
dir_only_contains_ok(
    't/lib', [qw(Test Test/Simple Test/Simple/Catch.pm)], "passing"
);
test_test("passing");

test_out("not ok 1 - failing because of missing file");
$line = line_num(+3);
test_diag("    Failed test (t/05dir_only_con.t at line $line)",
"failed to see these: A");
dir_only_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Catch.pm)],
    "failing because of missing file"
);
test_test("failing because of missing file");

test_out("not ok 1 - failing because of extra file");
$line = line_num(+3);
test_diag("    Failed test (t/05dir_only_con.t at line $line)",
"unexpectedly saw: Test/Simple/Catch.pm");
dir_only_contains_ok(
    't/lib', [qw(Test Test/Simple)], "failing because of extra file"
);
test_test("failing because of extra file");

test_out("not ok 1 - failing both");
$line = line_num(+4);
test_diag("    Failed test (t/05dir_only_con.t at line $line)",
"failed to see these: A Test/Simple/Simple.pm",
"unexpectedly saw: Test/Simple/Catch.pm");
dir_only_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Simple.pm)], "failing both"
);
test_test("failing both");

