# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor qw(simple_legacy_services);
use NCM::Component;
use NCM::Component::chkconfig2;
use Readonly;

$CAF::Object::NoAction = 1;

my $cfg = get_config_for_profile('simple_legacy_services');
my $cmp = NCM::Component::chkconfig2->new('chkconfig2');


=head1 Test legacy level conversion

Test legacy level conversion

=cut

my @mu = ("multi-user");
is(@{$cmp->convert_legacy_levels()}, @mu, "Test undefined legacy level returns default multi-user");
is(@{$cmp->convert_legacy_levels('')}, @mu, "Test empty-string legacy level returns default multi-user");
is(@{$cmp->convert_legacy_levels('0')}, @mu, "Test unsupported shutdown legacy level returns default multi-user");
is(@{$cmp->convert_legacy_levels('6')}, @mu, "Test unsupported reboot legacy level returns default multi-user");

my @targets;
@targets = ("rescue");
is(@{$cmp->convert_legacy_levels('1')}, @targets, "Test 1 legacy level returns secure");

@targets = ("multi-user");
is(@{$cmp->convert_legacy_levels('234')}, @targets, "Test 234 legacy level returns multi-user");

@targets = ("graphical");
is(@{$cmp->convert_legacy_levels('5')}, @targets, "Test 5 legacy level returns graphical");

@targets = ("rescue", "multi-user", "graphical");
is(@{$cmp->convert_legacy_levels('0123456')}, @targets, "Test 012345 legacy level returns resuce,multi-user,graphical");


=head1 Test legacy service conversion

Test legacy service conversion to new schema

=cut

my %cs = $cmp->get_quattor_legacy_services($cfg);

is(scalar keys %cs, 10, "Found 5+5 legacy services");

my ($name, $svc);

$name = "test_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("rescue", "multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "othername"; # "test_on_rename";
$svc = $cs{$name};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user", "graphical");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_del";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_on_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user", "graphical"); # off wins
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_add_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user"); 
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_off_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user", "graphical"); 
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_del_off_on_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user", "graphical");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "default";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));



done_testing();
