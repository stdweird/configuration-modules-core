# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor qw(simple_legacy_services);
use NCM::Component::chkconfig2;
use Readonly;

$CAF::Object::NoAction = 1;

my $cfg = get_config_for_profile('simple_legacy_services');
my $cmp = NCM::Component::chkconfig2->new('chkconfig');

=head1 Test legacy level conversion

Test legacy level conversion

=cut

my @mu = ("multi-user");
is($cmp->convert_legacy_levels(), @mu, "Test undefined legacy level returns default multi-user");
is($cmp->convert_legacy_levels(''), @mu, "Test empty-string legacy level returns default multi-user");
is($cmp->convert_legacy_levels('0'), @mu, "Test unsupported shutdown legacy level returns default multi-user");
is($cmp->convert_legacy_levels('6'), @mu, "Test unsupported reboot legacy level returns default multi-user");

my @levels;
@levels = ("rescue");
is($cmp->convert_legacy_levels('1'), @levels, "Test 1 legacy level returns secure");

@levels = ("multi-user");
is($cmp->convert_legacy_levels('234'), @levels, "Test 234 legacy level returns multi-user");

@levels = ("graphical");
is($cmp->convert_legacy_levels('5'), @levels, "Test 5 legacy level returns graphical");

@levels = ("rescue", "multi-user", "graphical");
is($cmp->convert_legacy_levels('0123456'), @levels, "Test 012345 legacy level returns resuce,multi-user,graphical");


done_testing();
