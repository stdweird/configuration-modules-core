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

use Test::MockModule;
my $mock = Test::MockModule->new ("CAF::Process");

# fake the existence tests for runlevel and who
my $supp_exe = '';
sub test_executable {
    my ($self, $executable) = @_;
    return $executable eq $supp_exe;
  }
$mock->mock ("_test_executable", \&test_executable);

=pod

=head1 DESCRIPTION

Test the C<Configure> method of the component for the services part.

=cut

my $cmp = NCM::Component::systemd->new('systemd');

=head1 Test legacy runlevel

Test legacy runlevel

=cut

# this file has no initdefault, test the readonly  default runlevel this way
set_file('inittab_el7');
is($cmp->service_get_default_runlevel(), 3, "Return default runlevel 3 when no initdefault is set in inittab");

set_file('inittab_el6_level5');
is($cmp->service_get_default_runlevel(), 5, "Return initdefault from inittab");

# runlevel fails, use who
$supp_exe = "/usr/bin/who";
set_desired_output("/usr/bin/who -r","         run-level 4  2014-10-13 19:34");
is($cmp->service_get_current_runlevel(), 4, "Return runlevel 4 from who -r");

# use runlevel
$supp_exe = "/sbin/runlevel";
set_desired_output("/sbin/runlevel","N 2");
is($cmp->service_get_current_runlevel(), 2, "Return runlevel 2 from runlevel");

# both fail, use default
$supp_exe = '';
set_file('inittab_el7');
is($cmp->service_get_current_runlevel(), $cmp->service_get_default_runlevel(), "Return runlevel 3 from default runlevel");

=head1 Test legacy level map generation

Test legacy level map generation

=cut

set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel0.target","Id=poweroff.target");
is($cmp->service_systemctl_show("runlevel0.target")->{Id}, "poweroff.target", "target Id level 0 poweroff.target");
# imaginary mapping
foreach my $lvl (1..5) {
    set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel$lvl.target","Id=x$lvl.target");
    is($cmp->service_systemctl_show("runlevel$lvl.target")->{Id}, "x$lvl.target", "target Id level $lvl x$lvl.target");
}
# broken
set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel6.target","Noid=false");
ok(!defined($cmp->service_systemctl_show("runlevel6.target")->{Id}), "target Id runlevel6 undefined");

is_deeply($cmp->_generate_level2target(), ["poweroff", "x1", "x2", "x3", "x4", "x5", "reboot"], "Generated level2target arraymap");


=head1 Test legacy level conversion 

Test legacy level conversion arbitrary and realistic

=cut

is_deeply($cmp->service_convert_legacy_levels(), ["multi-user"], "Test undefined legacy level returns default multi-user");
is_deeply($cmp->service_convert_legacy_levels(''), ["multi-user"], "Test empty-string legacy level returns default multi-user");

# fake/partial fake
is_deeply($cmp->service_convert_legacy_levels('0'), ["poweroff"], "Test shutdown legacy level returns poweroff");
is_deeply($cmp->service_convert_legacy_levels('1'), ["x1"], "Test 1 legacy level returns fake x1");
is_deeply($cmp->service_convert_legacy_levels('234'), ["x2", "x3", "x4"], "Test 234 legacy level returns fake x2,x3,x4");
is_deeply($cmp->service_convert_legacy_levels('5'), ["x5"], "Test 5 legacy level returns fake x5");
is_deeply($cmp->service_convert_legacy_levels('6'), ["reboot"], "Test reboot legacy level returns default reboot");

is_deeply($cmp->service_convert_legacy_levels('0123456'), ["poweroff", "x1", "x2", "x3", "x4", "x5", "reboot"], "Test 012345 legacy level with fake data");

# realistic tests
my $res = ["poweroff", "rescue", "multi-user", "multi-user", "multi-user", "graphical", "reboot"];
foreach my $lvl (0..6) {
    set_output("systemctl_show_runlevel${lvl}_target_el7");
    is($cmp->service_systemctl_show("runlevel${lvl}.target")->{Id}, $res->[$lvl].".target", "target Id level $lvl ".$res->[$lvl]);
}
# regenerate cache
is_deeply($cmp->_generate_level2target(), $res, "Regenerated level2target arraymap");

is_deeply($cmp->service_convert_legacy_levels('0'), ["poweroff"], "Test shutdown legacy level returns poweroff");
is_deeply($cmp->service_convert_legacy_levels('1'), ["rescue"], "Test 1 legacy level returns rescue");
is_deeply($cmp->service_convert_legacy_levels('234'), ["multi-user"], "Test 234 legacy level returns multi-user");
is_deeply($cmp->service_convert_legacy_levels('5'), ["graphical"], "Test 5 legacy level returns graphical");
is_deeply($cmp->service_convert_legacy_levels('6'), ["reboot"], "Test reboot legacy level returns reboot");
is_deeply($cmp->service_convert_legacy_levels('0123456'), ["poweroff", "rescue", "multi-user", "graphical", "reboot"], "Test 012345 legacy level returns poweroff,resuce,multi-user,graphical,reboot");


done_testing();
