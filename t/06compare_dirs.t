use Test::Builder::Tester tests => 5;

use Test::Files;

test_out("not ok 1 - missing first dir");
my $line = line_num(+3);
test_diag("    Failed test (t/06compare_dirs.t at line $line)",
"t/missing_dir is not a valid directory");
compare_dirs_ok('t/missing_dir', 't/lib',         "missing first dir");
test_test("missing first dir");

test_out("not ok 1 - missing second dir");
$line = line_num(+3);
test_diag("    Failed test (t/06compare_dirs.t at line $line)",
"t/missing_dir is not a valid directory");
compare_dirs_ok('t/lib',         't/missing_dir', "missing second dir");
test_test("missing second dir");

test_out("not ok 1 - failing due to text diff");
$line = line_num(+17);
test_diag(
"    Failed test (t/06compare_dirs.t at line $line)",
'+---+-----------------------------------+---+---------------------------------+',
'|   |t/lib/Test/Simple/Catch.pm         |   |t/lib_fail/Test/Simple/Catch.pm  |',
'| Ln|                                   | Ln|                                 |',
'+---+-----------------------------------+---+---------------------------------+',
'| 12|$t->failure_output($err_fh);       | 12|$t->failure_output($err_fh);     |',
'| 13|$t->todo_output($err_fh);          | 13|$t->todo_output($err_fh);        |',
'| 14|                                   | 14|                                 |',
'* 15|sub caught { return($out, $err) }  * 15|sub caught {                     *',
'|   |                                   * 16|    return($out, $err)           *',
'|   |                                   * 17|}                                *',
'| 16|                                   | 18|                                 |',
'| 17|sub PRINT  {                       | 19|sub PRINT  {                     |',
'| 18|    my $self = shift;              | 20|    my $self = shift;            |',
'+---+-----------------------------------+---+---------------------------------+');
compare_dirs_ok('t/lib',         't/lib_fail',    "failing due to text diff");
test_test("failing due to text diff");

test_out("not ok 1 - failing due to structure diff");
$line = line_num(+5);
test_diag("    Failed test (t/06compare_dirs.t at line $line)",
          't/time/t1 absent',
          't/time/t2 absent',
          't/time/t3 absent');
compare_dirs_ok('t/time3', 't/time', "failing due to structure diff");
test_test("failing due to structure diff");

test_out("ok 1 - passing");
compare_dirs_ok('t/lib',         't/lib_pass',    "passing");
test_test("passing");

__END__
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
#     Failed test (t/06compare_dirs.t at line 42)
# t/missing_dir is not a valid directory
#     Failed test (t/06compare_dirs.t at line 43)
# t/missing_dir is not a valid directory
#     Failed test (t/06compare_dirs.t at line 44)
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

