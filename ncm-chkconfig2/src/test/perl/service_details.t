# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor qw(service_details);
use NCM::Component;
use NCM::Component::chkconfig2;
use Readonly;

$CAF::Object::NoAction = 1;

my $cfg = get_config_for_profile('service_details');
my $cmp = NCM::Component::chkconfig2->new('chkconfig2');

=head1 Test quattor service details 

Test the gathering of the service details of legacy and new style

=cut

my %cs = $cmp->get_quattor_services($cfg);

is(scalar keys %cs, 8, "Found 8 services in quattor (3 legacy, 3 new, 2 legacy redefined)");

my ($name, $svc, @targets);

# old ones
 
$name = "test_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("rescue", "multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "othername"; # test_on_rename
$svc = $cs{$name};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

# new ones

$name = "test2_on";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "service", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("rescue", "multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test2_add";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
is($svc->{type}, "target", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "othername2"; # "test2_on_rename"
$svc = $cs{$name};
is($svc->{name}, "othername2", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "service", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));


# redefined in new

$name = "test_off";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
is($svc->{type}, "service", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@targets = ("rescue");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

$name = "test_del";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "service", "Service $name type sysv");
ok(!$svc->{startstop}, "Service $name startstop true");
@targets = ("multi-user");
is(@{$svc->{targets}}, @targets, "Service $name targets ".join(',', @targets));

=head1 Test details to string 

Test the generating text message from service details

=cut

is($cmp->service_text($svc), "service test_del (state on startstop 0 type service targets rescue)", "Generate string of service details");


done_testing();
