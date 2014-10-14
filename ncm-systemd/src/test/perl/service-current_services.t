# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor;
use NCM::Component::systemd;
use Readonly;

use helper;

$CAF::Object::NoAction = 1;
my $cmp = NCM::Component::systemd->new('systemd');

=pod

=head1 DESCRIPTION

Test the gathering of current services

=cut

# switch target
# ln -sf /usr/lib/systemd/system/foobar.service /etc/systemd/system/multi-user.target.wants/foobar.service
# systemctl daemon-reload

# use systemctl show target to get runlevel etc etc


=head 2 Chkconfig list

Get services via chkconfig --list

=cut

my ($name, $svc, @targets, %cs);

set_output("chkconfig_list_el7");

%cs = $cmp->service_get_current_services_hash_chkconfig();

is(scalar keys %cs, 5, "Found 5 services via chkconfig");


$name = "network";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user", "graphical"], "Service $name targets");

$name = "netconsole";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state off");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["rescue", "multi-user", "graphical"], "Service $name targets");

=head 2 Systemd service list

Get services via systemctl list-unit-files --type service

=cut

set_output("systemctl_list_unit_files_service");

%cs = $cmp->service_get_current_services_hash_systemctl('service');

is(scalar keys %cs, 154, "Found 154 services via systemctl list-unit-files --type service");

$name = 'autovt@';
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"disabled", "Service $name state disabled");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["rescue", "multi-user", "graphical"], "Service $name targets");

=head 2 Systemd target list

Get services via systemctl list-unit-files --type target

=cut

set_output("systemctl_list_unit_files_target");

%cs = $cmp->service_get_current_services_hash_systemctl('target');

is(scalar keys %cs, 54, "Found 54 services via systemctl list-unit-files --type target");


done_testing();
