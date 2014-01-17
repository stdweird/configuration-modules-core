# # -*- mode: cperl -*-
# ${license-info}
# ${author-info}
# ${build-info}

=pod

=head1 run Ceph command test
Test the runs of ceph commands


=cut


use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Quattor qw(basic_cluster);
use Test::MockModule;
use NCM::Component::ceph;
use CAF::Object;
use data;
use Readonly;
Readonly::Scalar my $PATH => '/software/components/ceph';


$CAF::Object::NoAction = 1;
my $mock = Test::MockModule->new('NCM::Component::ceph');

my $cfg = get_config_for_profile('basic_cluster');
my $cmp = NCM::Component::ceph->new('ceph');

my $t = $cfg->getElement($PATH)->getTree();
my $cluster = $t->{clusters}->{ceph};

$cmp->use_cluster();
$cmp->{is_deploy} = 1;
$cmp->{hostname} = 'ceph001';
my $gather1 = "su - ceph -c /usr/bin/ceph-deploy --cluster ceph gatherkeys ceph001";
my $gather2 = "su - ceph -c /usr/bin/ceph-deploy --cluster ceph gatherkeys ceph002";
my $gather3 = "su - ceph -c /usr/bin/ceph-deploy --cluster ceph gatherkeys ceph003";
my @gathers = ($gather1, $gather2, $gather3);
set_desired_output("/usr/bin/ceph -f json status --cluster ceph", $data::STATE);


# Totally new cluster
foreach my $gcmd (@gathers) {
    set_command_status($gcmd,1);
    set_desired_err($gcmd,'');
}
my $cephusr = { 'homeDir' => '/tmp' };
$cmp->init_commands();
my $clustercheck= $cmp->cluster_ready_check($cluster, $cephusr);
my $cmd;
foreach my $gcmd (@gathers) {
    $cmd = get_command($gcmd);
    ok(defined($cmd), "no cluster: gather had been tried");
}
#diag explain $cmp->{man_cmds};
cmp_deeply($cmp->{man_cmds}, \@data::NEWCLUS);

done_testing();
