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

=head1 Test legacy level conversion

Test legacy level conversion

=cut

my @targets;

set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel0","Id=poweroff");
# imaginary mapping
foreach my $lvl (1..5) {
    set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel$lvl","Id=x$lvl");
}
# broken
set_desired_output("/usr/bin/systemctl --no-pager --all show runlevel6","Noid=false");
@targets = ("poweroff", "x1", "x2", "x3", "x4", "x5", "reboot");
is(@{$cmp->_generate_level2target()}, @targets, "Generated level2target arraymap");

my @mu = ("multi-user");
is(@{$cmp->service_convert_legacy_levels()}, @mu, "Test undefined legacy level returns default multi-user");
is(@{$cmp->service_convert_legacy_levels('')}, @mu, "Test empty-string legacy level returns default multi-user");
is(@{$cmp->service_convert_legacy_levels('0')}, @mu, "Test unsupported shutdown legacy level returns default multi-user");
is(@{$cmp->service_convert_legacy_levels('6')}, @mu, "Test unsupported reboot legacy level returns default multi-user");

@targets = ("rescue");
is(@{$cmp->service_convert_legacy_levels('1')}, @targets, "Test 1 legacy level returns secure");

@targets = ("multi-user");
is(@{$cmp->service_convert_legacy_levels('234')}, @targets, "Test 234 legacy level returns multi-user");

@targets = ("graphical");
is(@{$cmp->service_convert_legacy_levels('5')}, @targets, "Test 5 legacy level returns graphical");

@targets = ("rescue", "multi-user", "graphical");
is(@{$cmp->service_convert_legacy_levels('0123456')}, @targets, "Test 012345 legacy level returns resuce,multi-user,graphical");




done_testing();
