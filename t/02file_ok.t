use strict;

use Test::Builder::Tester tests => 3;

use Test::Files;

test_out("not ok 1 - absent file");
my $line = line_num(+3);
test_diag("    Failed test (t/02file_ok.t at line $line)",
          "t/missing absent");
file_ok("t/missing", "This file is really absent", "absent file");
test_test("absent file");

test_out("ok 1 - passing text");
file_ok("t/ok_pass.dat", <<"EOF", "passing text");
This file
is for 03ok_pass.t
EOF
test_test("passing text");

# The following test on Solaris failed due to the reported time
# for the source file being Fri Oct 10 21:51:32 2003 instead of the
# one shown below.  This has not yet been fixed.
test_out("not ok 1 - failing text");
$line = line_num(+9);
test_diag("    Failed test (t/02file_ok.t at line $line)",
'+---+----------------------+-----------+',
'|   |Got                   |Expected   |',
'| Ln|                      |           |',
'+---+----------------------+-----------+',
'|  1|This file             |This file  |',
'*  2|is for 03ok_pass.t\n  |is wrong   *',
'+---+----------------------+-----------+'  );
file_ok("t/ok_pass.dat", "This file\nis wrong", "failing text");
test_test("failing text");

