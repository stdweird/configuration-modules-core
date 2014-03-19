#!/usr/bin/perl 
# -*- mode: cperl -*-
# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

use strict;
use warnings;
use Test::More;
use NCM::Component::grub;
use CAF::Object;
use Test::Quattor qw(serial);

use helper; 

my $cfg = get_config_for_profile('serial');
my $cmp = NCM::Component::grub->new('grub');

# returns undef for now, can't find grubby
#is($cmp->Configure($cfg), 1, "Component runs correctly with a test profile");
set_file("example0");
$cmp->Configure($cfg);
my $fh = get_file('/boot/grub/grub.conf');
like($fh, qr/serial/, 'serial line present');

set_file("example1withheader");
$cmp->Configure($cfg);
$fh = get_file('/boot/grub/grub.conf');
like($fh, qr/serial/, 'serial line present');

diag("$fh");

done_testing();
