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
);

our $VERSION = '0.03';

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

    my $first_data    = join "", <FIRST>;
    my $second_data   = join "", <SECOND>;
    close FIRST;
    close SECOND;

    return ($success, $first_data, $second_data);
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

    my @diags;

    my $matches = sub {
        my $name = $File::Find::name;
        return if (-d $name);
        $name    =~ s!.*$first_dir/?!!;
        return if length($name) < 1;  # skip the base directory
        my @result = _read_two_files("$first_dir/$name", "$second_dir/$name");
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

    file_ok("path/to/some/file", "contents\nof\file", "some file");

    compare_ok("path/to/a/file", "path/to/correct/file", "they're the same");

    dir_contains_ok     ( "some/dir", [qw(files some/dir should contain)] );

    dir_only_contains_ok( "some/dir", [qw(files some/dir should contain)] );

    compare_dirs_ok("some/dir", "some/other/dir/with/exactly/the/same/stuff");

=head1 ABSTRACT

  Test::Builder based test helper which helps you test files and their contents
  Future versions will likely work on directories too.

=head1 DESCRIPTION

This module is like Test::More, in fact you should use that first as shown
above.  It exports file_ok and compare_ok which compare the contents of a
file to a string or to another file.

Though the SYNOPSIS examples don't all have names, you can and should provide
a name for each test.  Names are omitted above only to reduce clutter and line
widths.

=head2 EXPORT

file_ok
compare_ok
dir_contains_ok

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
