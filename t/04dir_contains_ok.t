use Test::Builder::Tester tests => 4;

use Test::Files;

test_out("not ok 1 - missing dir");
my $line = line_num(+3);
test_diag("    Failed test (t/04dir_contains_ok.t at line $line)",
"t/missing_dir absent");
dir_contains_ok('t/missing_dir', [qw(some files)], "missing dir");
test_test("missing dir");

test_out("not ok 1 - anon. array expected");
$line = line_num(+3);
test_diag("    Failed test (t/04dir_contains_ok.t at line $line)",
"dir_contains_ok requires array ref as second arg");
dir_contains_ok('t',             "simple_arg",     "anon. array expected");
test_test("anon. array expected");

test_out("ok 1 - passing");
dir_contains_ok(
    't/lib', [qw(Test Test/Simple Test/Simple/Catch.pm)], "passing"
);
test_test("passing");

test_out("not ok 1 - failing");
$line = line_num(+3);
test_diag("    Failed test (t/04dir_contains_ok.t at line $line)",
"failed to see these: A Test/Simple/Simple.pm");
dir_contains_ok(
    't/lib', [qw(A Test Test/Simple Test/Simple/Simple.pm)], "failing"
);
test_test("failing");
