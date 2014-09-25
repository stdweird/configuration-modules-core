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

my @levels;
@levels = ("rescue");
is(@{$cmp->convert_legacy_levels('1')}, @levels, "Test 1 legacy level returns secure");

@levels = ("multi-user");
is(@{$cmp->convert_legacy_levels('234')}, @levels, "Test 234 legacy level returns multi-user");

@levels = ("graphical");
is(@{$cmp->convert_legacy_levels('5')}, @levels, "Test 5 legacy level returns graphical");

@levels = ("rescue", "multi-user", "graphical");
is(@{$cmp->convert_legacy_levels('0123456')}, @levels, "Test 012345 legacy level returns resuce,multi-user,graphical");


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
@levels = ("rescue", "multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "othername"; # "test_on_rename";
$svc = $cs{$name};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user", "graphical");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_del";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_on_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user", "graphical"); # off wins
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_add_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user"); 
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_off_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user", "graphical"); 
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_del_off_on_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user", "graphical");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "default";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));



done_testing();
