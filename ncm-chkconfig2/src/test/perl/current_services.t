# -*- mode: cperl -*-
use strict;
use warnings;
use Test::More;
use CAF::Object;
use Test::Quattor;
use NCM::Component::chkconfig2;
use Readonly;

$CAF::Object::NoAction = 1;
my $cmp = NCM::Component::chkconfig2->new('chkconfig2');

=pod

=head1 DESCRIPTION

Test the gathering of current services

=cut

Readonly my $CHKCONFIG_LIST_OUTPUT_EL7 => <<EOF;
Note: This output shows SysV services only and does not include native
      systemd services. SysV configuration data might be overridden by native
      systemd configuration.

      If you want to list systemd services use 'systemctl list-unit-files'.
      To see services enabled on particular target use
      'systemctl list-dependencies [target]'.

cdp-listend     0:off   1:off   2:on    3:on    4:on    5:on    6:off
ceph            0:off   1:off   2:on    3:on    4:on    5:on    6:off
ncm-cdispd      0:off   1:off   2:on    3:on    4:on    5:on    6:off
netconsole      0:off   1:off   2:off   3:off   4:off   5:off   6:off
network         0:off   1:off   2:on    3:on    4:on    5:on    6:off

xinetd based services:
    chargen-dgram:  off
    chargen-stream: off
    daytime-dgram:  off
    daytime-stream: off
    discard-dgram:  off
    discard-stream: off
    echo-dgram:     off
    echo-stream:    off
    tcpmux-server:  off
    time-dgram:     off
    time-stream:    off
EOF

Readonly my $SYSTEMCTL_LIST_UNIT_FILES_SERVICE_OUTPUT_EL7 => <<EOF;
arp-ethers.service                     disabled
atd.service                            enabled 
autovt@.service                        disabled
avahi-daemon.service                   enabled 
blk-availability.service               disabled
brandbot.service                       static  
collectl.service                       enabled 
console-getty.service                  disabled
console-shell.service                  disabled
crond.service                          enabled 
cups-browsed.service                   disabled
cups.service                           enabled 
dbus-org.freedesktop.Avahi.service     enabled 
dbus-org.freedesktop.hostname1.service static  
dbus-org.freedesktop.locale1.service   static  
dbus-org.freedesktop.login1.service    static  
dbus-org.freedesktop.machine1.service  static  
dbus-org.freedesktop.timedate1.service static  
dbus.service                           static  
debug-shell.service                    disabled
dm-event.service                       disabled
dnsmasq.service                        disabled
dracut-cmdline.service                 static  
dracut-initqueue.service               static  
dracut-mount.service                   static  
dracut-pre-mount.service               static  
dracut-pre-pivot.service               static  
dracut-pre-trigger.service             static  
dracut-pre-udev.service                static  
dracut-shutdown.service                static  
ebtables.service                       disabled
emergency.service                      static  
fancontrol.service                     disabled
fprintd.service                        static  
getty@.service                         enabled 
halt-local.service                     static  
initrd-cleanup.service                 static  
initrd-parse-etc.service               static  
initrd-switch-root.service             static  
initrd-udevadm-cleanup-db.service      static  
ip6tables.service                      disabled
ipmi.service                           disabled
ipmievd.service                        disabled
iptables.service                       disabled
iscsi.service                          enabled 
iscsid.service                         disabled
iscsiuio.service                       disabled
kdump.service                          enabled 
kmod-static-nodes.service              static  
ksm.service                            enabled 
ksmtuned.service                       enabled 
libvirt-guests.service                 enabled 
libvirtd.service                       enabled 
lm_sensors.service                     enabled 
lvm2-lvmetad.service                   disabled
lvm2-monitor.service                   enabled 
lvm2-pvscan@.service                   static  
mcelog.service                         enabled 
messagebus.service                     static  
netcf-transaction.service              enabled 
nfs-blkmap.service                     disabled
nfs-idmap.service                      disabled
nfs-lock.service                       enabled 
nfs-mountd.service                     disabled
nfs-rquotad.service                    disabled
nfs-secure-server.service              disabled
nfs-secure.service                     disabled
nfs-server.service                     disabled
nfs.service                            disabled
nfslock.service                        disabled
nrpe.service                           enabled 
numad.service                          disabled
plymouth-halt.service                  disabled
plymouth-kexec.service                 disabled
plymouth-poweroff.service              disabled
plymouth-quit-wait.service             disabled
plymouth-quit.service                  disabled
plymouth-read-write.service            disabled
plymouth-reboot.service                disabled
plymouth-start.service                 disabled
plymouth-switch-root.service           static  
polkit.service                         static  
ptpd2.service                          enabled 
quotaon.service                        static  
radvd.service                          disabled
rc-local.service                       static  
rdisc.service                          disabled
rescue.service                         static  
rhel-autorelabel-mark.service          static  
rhel-autorelabel.service               static  
rhel-configure.service                 static  
rhel-dmesg.service                     disabled
rhel-domainname.service                disabled
rhel-import-state.service              static  
rhel-loadmodules.service               static  
rhel-readonly.service                  static  
rpcbind.service                        enabled 
rpcgssd.service                        disabled
rpcidmapd.service                      disabled
rpcsvcgssd.service                     disabled
rsyncd.service                         disabled
rsyslog.service                        enabled 
saslauthd.service                      disabled
serial-getty@.service                  static  
smartd.service                         enabled 
sshd-keygen.service                    static  
sshd.service                           enabled 
sshd@.service                          static  
sysstat.service                        enabled 
systemd-ask-password-console.service   static  
systemd-ask-password-plymouth.service  static  
systemd-ask-password-wall.service      static  
systemd-backlight@.service             static  
systemd-binfmt.service                 static  
systemd-fsck-root.service              static  
systemd-fsck@.service                  static  
systemd-halt.service                   static  
systemd-hibernate.service              static  
systemd-hostnamed.service              static  
systemd-hybrid-sleep.service           static  
systemd-initctl.service                static  
systemd-journal-flush.service          static  
systemd-journald.service               static  
systemd-kexec.service                  static  
systemd-localed.service                static  
systemd-logind.service                 static  
systemd-machined.service               static  
systemd-modules-load.service           static  
systemd-nspawn@.service                disabled
systemd-poweroff.service               static  
systemd-quotacheck.service             static  
systemd-random-seed.service            static  
systemd-readahead-collect.service      enabled 
systemd-readahead-done.service         static  
systemd-readahead-drop.service         enabled 
systemd-readahead-replay.service       enabled 
systemd-reboot.service                 static  
systemd-remount-fs.service             static  
systemd-shutdownd.service              static  
systemd-suspend.service                static  
systemd-sysctl.service                 static  
systemd-timedated.service              static  
systemd-tmpfiles-clean.service         static  
systemd-tmpfiles-setup-dev.service     static  
systemd-tmpfiles-setup.service         static  
systemd-udev-settle.service            static  
systemd-udev-trigger.service           static  
systemd-udevd.service                  static  
systemd-update-utmp-runlevel.service   static  
systemd-update-utmp.service            static  
systemd-user-sessions.service          static  
systemd-vconsole-setup.service         static  
virtlockd.service                      static  
xinetd.service                         enabled 
EOF

Readonly my $SYSTEMCTL_LIST_UNIT_FILES_TARGET_OUTPUT_EL7 => <<EOF;
basic.target              static  
bluetooth.target          static  
cryptsetup.target         static  
ctrl-alt-del.target       disabled
default.target            enabled 
emergency.target          static  
final.target              static  
getty.target              static  
graphical.target          disabled
halt.target               disabled
hibernate.target          static  
hybrid-sleep.target       static  
initrd-fs.target          static  
initrd-root-fs.target     static  
initrd-switch-root.target static  
initrd.target             static  
kexec.target              disabled
local-fs-pre.target       static  
local-fs.target           static  
multi-user.target         enabled 
network-online.target     static  
network.target            static  
nfs.target                enabled 
nss-lookup.target         static  
nss-user-lookup.target    static  
paths.target              static  
poweroff.target           disabled
printer.target            static  
reboot.target             disabled
remote-fs-pre.target      static  
remote-fs.target          enabled 
rescue.target             disabled
rpcbind.target            static  
runlevel0.target          disabled
runlevel1.target          disabled
runlevel2.target          disabled
runlevel3.target          disabled
runlevel4.target          disabled
runlevel5.target          disabled
runlevel6.target          disabled
shutdown.target           static  
sigpwr.target             static  
sleep.target              static  
slices.target             static  
smartcard.target          static  
sockets.target            static  
sound.target              static  
suspend.target            static  
swap.target               static  
sysinit.target            static  
system-update.target      static  
time-sync.target          static  
timers.target             static  
umount.target             static  
EOF

set_desired_output("/usr/bin/systemctl list-unit-files --no-pager --all --no-legend --type service", $SYSTEMCTL_LIST_UNIT_FILES_SERVICE_OUTPUT_EL7);
set_desired_output("/usr/bin/systemctl list-unit-files --no-pager --all --no-legend --type target", $SYSTEMCTL_LIST_UNIT_FILES_TARGET_OUTPUT_EL7);
set_desired_output("/sbin/chkconfig --list", $CHKCONFIG_LIST_OUTPUT_EL7);

my %cs = $cmp->get_current_services_hash_chkconfig();

is(scalar keys %cs, 5, "Found 5 services via chkconfig");

my ($name, $svc, @levels);

$name = "network";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"on", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("multi-user", "graphical");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

$name = "netconsole";
$svc = $cs{$name};
is($svc->{name}, $name, "Service $name name matches");
is($svc->{state},"off", "Service $name state on");
is($svc->{type}, "sysv", "Service $name type sysv");
ok($svc->{startstop}, "Service $name startstop true");
@levels = ("rescue", "multi-user", "graphical");
is(@{$svc->{levels}}, @levels, "Service $name levels ".join(',', @levels));

done_testing();
