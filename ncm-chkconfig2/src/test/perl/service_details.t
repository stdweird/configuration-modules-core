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

sub escape {
  my ($str)=@_;
  $str =~ s/(^[0-9]|[^a-zA-Z0-9])/sprintf("_%lx", ord($1))/eg;
  return $str;
}


=head1 Test quattor service details 

Test the gathering of the service details of legacy and new style

=cut

my %cs = $cmp->get_quattor_services($cfg);
my ($name, $svc, @levels);

# old ones
 
$name = "test_on";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("rescue", "multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_add";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_on_rename";
$svc = $cs{escape($name)};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

# new ones

$name = "test2_on";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("rescue", "multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test2_add";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"add", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test2_on_rename";
$svc = $cs{escape($name)};
is($svc->{name}, "othername", "Service $name renamed matches");
is($svc->{state},"on", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));


# redefined in new

$name = "test_off";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"del", "Service $name state on");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("rescue");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "test_del";
$svc = $cs{escape($name)};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
ok(!$svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

=head1 Test details to string 

Test the generating text message from service details

=cut

is($cmp->service_text($svc), "service test_del (state on startstop 0 levels rescue)", "Generate string of service details");


done_testing();
