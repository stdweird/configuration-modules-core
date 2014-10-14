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

# ls -l /etc/systemd/system/*target.wants/*.service

# ll /etc/systemd/system/default.target
# lrwxrwxrwx. 1 root root 37 Jul 10 17:33 /etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target

my $some = <<'EOF';
perl -e 'use Data::Dumper; print Dumper(glob("/etc/systemd/system/{default,multi-user,rescue,graphical}.target.wants/*"))'
$VAR1 = '/etc/systemd/system/default.target.wants/systemd-readahead-collect.service';
$VAR2 = '/etc/systemd/system/default.target.wants/systemd-readahead-replay.service';
$VAR3 = '/etc/systemd/system/multi-user.target.wants/atd.service';
$VAR4 = '/etc/systemd/system/multi-user.target.wants/avahi-daemon.service';
$VAR5 = '/etc/systemd/system/multi-user.target.wants/collectl.service';
$VAR6 = '/etc/systemd/system/multi-user.target.wants/crond.service';
$VAR7 = '/etc/systemd/system/multi-user.target.wants/cups.path';
$VAR8 = '/etc/systemd/system/multi-user.target.wants/kdump.service';
$VAR9 = '/etc/systemd/system/multi-user.target.wants/ksm.service';
$VAR10 = '/etc/systemd/system/multi-user.target.wants/ksmtuned.service';
$VAR11 = '/etc/systemd/system/multi-user.target.wants/libvirt-guests.service';
$VAR12 = '/etc/systemd/system/multi-user.target.wants/libvirtd.service';
$VAR13 = '/etc/systemd/system/multi-user.target.wants/lm_sensors.service';
$VAR14 = '/etc/systemd/system/multi-user.target.wants/mcelog.service';
$VAR15 = '/etc/systemd/system/multi-user.target.wants/netcf-transaction.service';
$VAR16 = '/etc/systemd/system/multi-user.target.wants/nfs.target';
$VAR17 = '/etc/systemd/system/multi-user.target.wants/nrpe.service';
$VAR18 = '/etc/systemd/system/multi-user.target.wants/ptpd2.service';
$VAR19 = '/etc/systemd/system/multi-user.target.wants/remote-fs.target';
$VAR20 = '/etc/systemd/system/multi-user.target.wants/rpcbind.service';
$VAR21 = '/etc/systemd/system/multi-user.target.wants/rsyslog.service';
$VAR22 = '/etc/systemd/system/multi-user.target.wants/smartd.service';
$VAR23 = '/etc/systemd/system/multi-user.target.wants/sshd.service';
$VAR24 = '/etc/systemd/system/multi-user.target.wants/sysstat.service';
$VAR25 = '/etc/systemd/system/multi-user.target.wants/xinetd.service';
EOF

# /etc/systemd/system/().target.wants are actual directories

=head 2 Chkconfig list

Get services via chkconfig --list

=cut

my ($name, $svc, @targets, %cs);

set_output("chkconfig_list_el7");

%cs = $cmp->get_current_services_hash_chkconfig();

is(scalar keys %cs, 5, "Found 5 services via chkconfig");


$name = "network";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user", "graphical");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "netconsole";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("rescue", "multi-user", "graphical");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));


=head 2 Systemd service list

Get services via systemctl list-unit-files --type service

=cut

set_output("systemctl_list_unit_files_service");

%cs = $cmp->get_current_services_hash_systemctl('service');

is(scalar keys %cs, 154, "Found 154 services via systemctl list-unit-files --type service");

=head 2 Systemd target list

Get services via systemctl list-unit-files --type target

=cut

set_output("systemctl_list_unit_files_target");

%cs = $cmp->get_current_services_hash_systemctl('target');

is(scalar keys %cs, 54, "Found 54 services via systemctl list-unit-files --type target");


done_testing();
