use strict;

use Test::Builder::Tester tests => 3;
use File::Spec;

use Test::Files;

my $test_file    = File::Spec->catfile( 't', '02file_ok.t' );
my $missing_file = File::Spec->catfile( 't', 'missing' );
my $ok_pass_file = File::Spec->catfile( 't', 'ok_pass.dat' );

#-----------------------------------------------------------------
# Compare text to a file with same text.
#-----------------------------------------------------------------

test_out("ok 1 - passing text");
file_ok($ok_pass_file, <<"EOF", "passing text");
This file
is for 03ok_pass.t
EOF
test_test("passing text");

#-----------------------------------------------------------------
# Compare text to a missing file.
#-----------------------------------------------------------------

test_out("not ok 1 - absent file");
my $line = line_num(+3);
test_diag("    Failed test ($test_file at line $line)",
          "$missing_file absent");
file_ok("$missing_file", "This file is really absent", "absent file");
test_test("absent file");

#-----------------------------------------------------------------
# Compare text to a file with different text.
#-----------------------------------------------------------------

# The following test on Solaris failed due to the reported time
# for the source file being Fri Oct 10 21:51:32 2003 instead of the
# one shown below.  This has not yet been fixed.
test_out("not ok 1 - failing text");
$line = line_num(+9);
test_diag("    Failed test ($test_file at line $line)",
'+---+----------------------+-----------+',
'|   |Got                   |Expected   |',
'| Ln|                      |           |',
'+---+----------------------+-----------+',
'|  1|This file             |This file  |',
'*  2|is for 03ok_pass.t\n  |is wrong   *',
'+---+----------------------+-----------+'  );
file_ok($ok_pass_file, "This file\nis wrong", "failing text");
test_test("failing text");

