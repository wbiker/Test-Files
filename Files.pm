package Test::Files;
use Test::Builder;
use Test::More;
use Text::Diff;
use File::Find;

use 5.006;
use strict;
use warnings;  # This is off in Test::More, eventually it may have to go.

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw(
    file_ok
    compare_ok
    dir_contains_ok
    dir_only_contains_ok
    compare_dirs_ok
    compare_dirs_filter_ok
);

our $VERSION = '0.04';

my $Test = Test::Builder->new;
my $diff_options = {
    CONTEXT     => 3,          # change this one later if needed
    STYLE       => "Table",
    FILENAME_A  => "Got",
    FILENAME_B  => "Expected",
    OFFSET_A    => 1,
    OFFSET_B    => 1,
    INDEX_LABEL => "Ln",
};

sub file_ok {
    my $candidate_file = shift;
    my $expected       = shift;
    my $name           = shift;
    
    unless (-f $candidate_file and -r _) {
        $Test->ok(0, $name);
        $Test->diag("$candidate_file absent");
        return;
    }

    # chomping and reappending the line ending was done in
    # Test::Differences::eq_or_diff
    my $diff = diff($candidate_file, \$expected, $diff_options);
    chomp $diff;
    my $failed = length $diff;
    $diff .= "\n";

    if ($failed) {
        $Test->ok(0, $name);
        $Test->diag($diff);
    }
    else {
        $Test->ok(1, $name);
    }
}

sub _read_two_files {
    my $first   = shift;
    my $second  = shift;
    my $filter  = shift;
    my $success = 1;
    my @errors;

    unless (open FIRST, "$first") {
        $success = 0;
        push @errors, "$first absent";
    }
    unless (open SECOND, "$second") {
        $success = 0;
        push @errors, "$second absent";
    }
    return ($success, @errors) unless $success;

    my $first_data  = _read_and_filter_handle(*FIRST,  $filter);
    my $second_data = _read_and_filter_handle(*SECOND, $filter);
    close FIRST;
    close SECOND;

    return ($success, $first_data, $second_data);
}

sub _read_and_filter_handle {
    my $handle = shift;
    my $filter = shift;

    if ($filter) {
        my @retval;
        while (<$handle>) {
            my $filtered = $filter->($_);
            push @retval, $filtered if $filtered;
        }
        return join "", @retval;
    }
    else {
        return join "", <$handle>;
    }
}

sub compare_ok {
    my $got_file      = shift;
    my $expected_file = shift;
    my $name          = shift;
    my @read_result   = _read_two_files($got_file, $expected_file);
    my $files_exist   = shift @read_result;

    if ($files_exist) {
        my ($got, $expected) = @read_result;
        # chomping and reappending the line ending was done in
        # Test::Differences::eq_or_diff
        my $diff = diff(\$got, \$expected, $diff_options);
        chomp $diff;
        my $failed = length $diff;
        $diff .= "\n";

        if ($failed) {
            $Test->ok(0, $name);
            $Test->diag($diff);
        }
        else {
            $Test->ok(1, $name);
        }
    }
    else {
        $Test->ok(0, $name);
        $Test->diag(join "\n", @read_result);
    }
}

sub _dir_missing_helper {
    my $base_dir = shift;
    my $list     = shift;
    my $name     = shift;
    my $function = shift;

    unless (-d $base_dir) {
        return(0, "$base_dir absent");
    }
    if (index(ref $list, 'ARRAY') < 0) {
        return(0, "$function requires array ref as second arg");
        return;
    }

    my @missing;
    foreach my $element (@$list) {
        push @missing, $element unless (-e "$base_dir/$element");
    }
    return (\@missing);
}

sub dir_contains_ok {
    my $base_dir = shift;
    my $list     = shift;
    my $name     = shift;
    my @result   = _dir_missing_helper(
        $base_dir, $list, $name, 'dir_contains_ok'
    );
    if (@result == 2) {
        $Test->ok(0, $name);
        $Test->diag($result[1]);
        return;
    }

    my $missing = $result[0];

    if (@$missing) {
        $Test->ok(0, $name);
        $Test->diag("failed to see these: @$missing");
    }
    else {
        $Test->ok(1, $name);
    }
}

sub dir_only_contains_ok {
    my $base_dir = shift;
    my $list     = shift;
    my $name     = shift;
    my @result   = _dir_missing_helper(
        $base_dir, $list, $name, 'dir_only_contains_ok'
    );
    if (@result == 2) {
        $Test->ok(0, $name);
        $Test->diag($result[1]);
        return;
    }

    my $missing = $result[0];

    my $success;
    my @diags;
    if (@$missing) {
        $success = 0;
        push @diags, "failed to see these: @$missing";
    }
    else {
        $success = 1;
    }

    # Then, make sure no other files are present.
    my %expected;
    my @unexpected;
    @expected{ @$list } = ();
    # by defining $contains here, it can use our scope
    my $contains = sub {
        my $name = $File::Find::name;
        $name    =~ s!.*$base_dir/?!!;
        return if length($name) < 1;  # skip the base directory
        push @unexpected, $name unless (exists $expected{$name});
    };

    find($contains, ($base_dir));

    if (@unexpected) {
        $success  = 0;
        my $unexp = @unexpected;
        push @diags, "unexpectedly saw: @unexpected";
    }

    $Test->ok($success, $name);
    $Test->diag(join "\n", @diags) if @diags;
}

sub compare_dirs_ok {
    my $first_dir  = shift;
    my $second_dir = shift;
    my $name       = shift;

    @_ = ($first_dir, $second_dir, undef, $name);
    goto &compare_dirs_filter_ok;
}

sub compare_dirs_filter_ok {
    my $first_dir  = shift;
    my $second_dir = shift;
    my $filter     = shift;
    my $name       = shift;

    unless (-d $first_dir) {
        $Test->ok(0, $name);
        $Test->diag("$first_dir is not a valid directory");
        return;
    }
    unless (-d $second_dir) {
        $Test->ok(0, $name);
        $Test->diag("$second_dir is not a valid directory");
        return;
    }
    unless (not defined $filter or ref($filter) =~ /CODE/) {
        $Test->ok(0, $filter);
        $Test->diag(
            "Third argument to compare_dirs_filter_ok must be "
            . "a code reference (or undef)"
        );
        return;
    }

    my @diags;

    my $matches = sub {
        my $name = $File::Find::name;
        return if (-d $name);
        $name    =~ s!.*$first_dir/?!!;
        return if length($name) < 1;  # skip the base directory
        my @result = _read_two_files(
            "$first_dir/$name", "$second_dir/$name", $filter
        );
        my $files_exist = shift @result;

        if ($files_exist) {
            my ($got, $expected) = @result;
            my $diff = diff(
                \$got,
                \$expected,
                {
                    %$diff_options,
                    FILENAME_A => "$first_dir/$name",
                    FILENAME_B => "$second_dir/$name"
                }
            );
            chomp $diff;
            my $failed = length $diff;
            $diff .= "\n";

            if ($failed) {
                push @diags, $diff;
            }
        }
        else {
            push @diags, @result;
        }
    };

    find({ wanted => $matches, no_chdir => 1 }, $first_dir);

    if (@diags) {
        $Test->ok(0, $name);
        $Test->diag(@diags);
    }
    else {
        $Test->ok(1, $name);
    }
}

1;
__END__

=head1 NAME

Test::Files - A Test::Builder based module to ease testing with files and dirs

=head1 SYNOPSIS

    use Test::More tests => 5;
    use Test::Files;

    file_ok("path/to/some/file", "contents\nof file", "some file");

    compare_ok("path/to/a/file", "path/to/correct/file", "they're the same");

    dir_contains_ok     ( "some/dir", [qw(files some/dir should contain)] );

    dir_only_contains_ok( "some/dir", [qw(files some/dir should contain)] );

    compare_dirs_ok("some/dir", "some/other/dir/with/exactly/the/same/stuff");
    compare_dirs_filter_ok("some/dir", "some/other/dir", \&filter_fcn);

=head1 ABSTRACT

  Test::Builder based test helper which helps you test files and their contents.
  Includes facilities for comparing whole directory trees for structure and/or
  content.

=head1 DESCRIPTION

This module is like Test::More, in fact you should use that first as shown
above.  It exports

=over 4

=item file_ok 

compare the contents of a file to a string

=item compare_ok

compare the contents of two files

=item dir_contains_ok

checks a directory for the presence of a list files

=item dir_contains_only_ok

checks a directory to ensure that the listed files are present and
that they are the only ones present

=item compare_dirs_ok

compares all text files in two directories reporting any differences

=item compare_dirs_filter_ok

works like compare_dirs_ok, but calls a filter function on each line of
input, allowing you to exclude or alter some text to avoid spurious failures
(like timestamp disagreements).

=back

Though the SYNOPSIS examples don't all have names, you can and should provide
a name for each test.  Names are omitted above only to reduce clutter and line
widths.

Most of the functions are self explanatory.  One exception is
C<compare_dirs_filter_ok> which compares two directory trees, like
C<compare_dirs_ok> but with a twist.  The twist is a filter which each
line is fed through before comparison.  I wanted this because some
files are really the same, but look different textually.  In particular,
I was comparing files with machine generated dates.  Everything in them
was identical, except those dates.

The filter function receives each line of each file.  It may perform
any necessary transformations (like excising dates), then it must
return the line in (possibly) transformed state.  For example, my filter
was

    sub chop_dates {
        my $line = shift;
        $line =~ s/\d{4}(.\d\d){5}//;
        return $line;
    }

This removes all strings like 2003.10.14.14.17.37.  Everything else is
unchanged and my failing tests started passing as expected.  If you want
to exclude the line from consideration, return "" (do not return undef,
that makes it harder to chain filters together and might lead to warnings).

=head2 EXPORT

file_ok
compare_ok
dir_contains_ok
dir_only_contains_ok
compare_dirs_ok
compare_dirs_filter_ok

=head1 DEPENDENCIES

Test::Builder
Test::More
Test::Differences

=head1 SEE ALSO

Consult Test::Simple, Test::More, and Test::Builder for more testing help.
This module really just adds functions to what Test::More does.

=head1 AUTHOR

Phil Crow, E<lt>philcrow2000@yahoo.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Phil Crow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl 5.8.1 itself. 

=cut
