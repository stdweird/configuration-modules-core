# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor qw(service-simple_services);
use NCM::Component::systemd;
use Readonly;
use helper;

$CAF::Object::NoAction = 1;

=pod

=head1 DESCRIPTION

Test the C<Configure> method of the component for the services part.

=cut

my $cfg = get_config_for_profile('service-simple_services');
my $cmp = NCM::Component::systemd->new('systemd');

my ($res, @names);
set_output("systemctl_show_runlevel6_target_el7");
$res=$cmp->service_systemctl_show('runlevel6.target');

is(scalar keys %$res, 63, "Found 63 keys");
is($res->{Id}, 'reboot.target', "Runlevel6 is reboot.target");

is_deeply($res->{Names}, ["runlevel6.target", "reboot.target"], "Runlevel6 names/aliases");

done_testing();
