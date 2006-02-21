use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XML::XPathEngine',
    AUTHOR              => 'Michel Rodriguez <mirod@cpan.org>',
    VERSION_FROM        => 'lib/XML/XPathEngine.pm',
    ABSTRACT_FROM       => 'lib/XML/XPathEngine.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XML-XPathEngine-*' },
);
