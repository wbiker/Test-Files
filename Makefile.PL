use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Test::Files',
    'VERSION_FROM'	=> 'Files.pm', # finds $VERSION
    'PREREQ_PM'		=> {Test::Builder     => 0,
                            Test::More        => 0,
                            Text::Diff        => 0,
                            }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Files.pm', # retrieve abstract from module
       AUTHOR     => 'Phil Crow <phil@localdomain>') : ()),
);
