# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor qw(service-simple_legacy_services);
use NCM::Component;
use NCM::Component::systemd;
use Readonly;
use helper;

$CAF::Object::NoAction = 1;

my $cfg = get_config_for_profile('service-simple_legacy_services');
my $cmp = NCM::Component::systemd->new('systemd');


=head1 Test legacy service conversion

Test legacy service conversion to new schema

=cut

my %cs = $cmp->service_get_quattor_legacy_services($cfg);

is(scalar keys %cs, 10, "Found 5+5 legacy services");

my ($name, $svc);

$name = "test_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["rescue", "multi-user"], "Service $name targets");

$name = "test_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user"], "Service $name targets");

$name = "othername"; # "test_on_rename";
$svc = $cs{$name};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user"], "Service $name targets");

$name = "test_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user", "graphical"], "Service $name targets");

$name = "test_del";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user"], "Service $name targets");

$name = "test_on_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
# off wins
is_deeply($svc->{targets}, ["multi-user", "graphical"], "Service $name targets");

$name = "test_add_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user"], "Service $name targets");

$name = "test_off_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user", "graphical"], "Service $name targets");

$name = "test_del_off_on_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user", "graphical"], "Service $name targets");

$name = "default";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
is_deeply($svc->{targets}, ["multi-user"], "Service $name targets");


=head1 Test legacy configure 

Test legacy configure

=cut

my $cmd;

## TODO put here to fail
set_output("runlevel_5");
set_output("chkconfig_list_test");
is($cmp->service_configure, 1, "Configure service runs ok");

# service add (test_add also tests unescaping of getTree)
# test_add should not exist in $chkconfig_list_output
$cmd = get_command("/sbin/chkconfig --add test_add")->{object};
isa_ok($cmd, "CAF::Process", "Command for service --add test_add run");

# service on
$cmd = get_command("/sbin/chkconfig test_on off")->{object};
isa_ok($cmd, "CAF::Process", "Command for service test_on on (off first) run");
$cmd = get_command("/sbin/chkconfig --level 123 test_on on")->{object};
isa_ok($cmd, "CAF::Process", "Command for service test_on on run");

# service on with renamed service
$cmd = get_command("/sbin/chkconfig othername off")->{object};
isa_ok($cmd, "CAF::Process", "Command for service test_on_rename on (off first) run");
$cmd = get_command("/sbin/chkconfig --level 4 othername on")->{object};
isa_ok($cmd, "CAF::Process", "Command for service test_on_rename on run");


# to test del and/or off, the service needs to be there and
# turned on for at least one of the selected runlevels.
$cmd = get_command("/sbin/chkconfig --level 45 test_off off")->{object};
isa_ok($cmd, "CAF::Process", "Command for service test_off off run");

$cmd = get_command("/sbin/chkconfig test_del off")->{object};
isa_ok($cmd, "CAF::Process", "Command for service --del test_del (off first) run");
$cmd = get_command("/sbin/chkconfig --del test_del")->{object};
isa_ok($cmd, "CAF::Process", "Command for service --del test_del run");


done_testing();
