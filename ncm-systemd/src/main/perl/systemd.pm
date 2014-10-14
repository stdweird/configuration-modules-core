# ${license-info}
# ${developer-info}
# ${author-info}

package NCM::Component::${project.artifactId};

use strict;
use warnings;
use base qw(NCM::Component NCM::Component::Systemd::Service);

use NCM::Check;

our $EC=LC::Exception::Context->new->will_store_all;
$NCM::Component::${project.artifactId}::NoActionSupported = 1;

sub Configure 
{

    return 1;
}


sub Unconfigure 
{
}


1; #required for Perl modules

