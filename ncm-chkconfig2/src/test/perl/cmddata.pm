# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

=pod

=head1 cmddata module

This module provides raw command data (output and exit code) and file content. 

=cut
package cmddata;

use strict;
use warnings;

# bunch of commands and their output
our %cmds;
our %files;

$cmds{systemctl_list_unit_files_target}{cmd}="/usr/bin/systemctl list-unit-files --all --no-pager --no-legend --type target";
$cmds{systemctl_list_unit_files_target}{out}=<<'EOF';
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

$cmds{systemctl_list_unit_files_service}{cmd}="/usr/bin/systemctl list-unit-files --all --no-pager --no-legend --type service";
$cmds{systemctl_list_unit_files_service}{out}=<<'EOF';
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

$cmds{systemctl_list_units_service}{cmd}="/usr/bin/systemctl list-units --type=service --no-pager --no-legend";
$cmds{systemctl_list_units_service}{out}=<<'EOF';
atd.service                        loaded active running Job spooling tools
avahi-daemon.service               loaded active running Avahi mDNS/DNS-SD Stack
cdp-listend.service                loaded active running SYSV: cdp-listend daemon for the CDP notifications
ceph.service                       loaded active exited  LSB: Start Ceph distributed file system daemons at boot time
collectl.service                   loaded active running Performance data collection for a number of subsystems
crond.service                      loaded active running Command Scheduler
dbus.service                       loaded active running D-Bus System Message Bus
getty@tty1.service                 loaded active running Getty on tty1
kdump.service                      loaded failed failed  Crash recovery kernel arming
kmod-static-nodes.service          loaded active exited  Create list of required static device nodes for the current kernel
ks-post-reboot.service             loaded failed failed  ks-post-reboot.service
ksm.service                        loaded active exited  Kernel Samepage Merging
ksmtuned.service                   loaded active running Kernel Samepage Merging (KSM) Tuning Daemon
libvirt-guests.service             loaded active exited  Suspend Active Libvirt Guests
libvirtd.service                   loaded active running Virtualization daemon
lm_sensors.service                 loaded active exited  Initialize hardware monitoring sensors
lvm2-lvmetad.service               loaded active running LVM2 metadata daemon
lvm2-monitor.service               loaded active exited  Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
mcelog.service                     loaded active running Machine Check Exception Logging Daemon
ncm-cdispd.service                 loaded active running SYSV: The Configuration Dispatch Daemon
netcf-transaction.service          loaded active exited  Rollback uncommitted netcf network config change transactions
network.service                    loaded active exited  LSB: Bring up/down networking
nfs-lock.service                   loaded active running NFS file locking service.
nrpe.service                       loaded active running NRPE
polkit.service                     loaded active running Authorization Manager
ptpd2.service                      loaded failed failed  ptpd time precision daemon
rc-local.service                   loaded failed failed  /etc/rc.d/rc.local Compatibility
rhel-dmesg.service                 loaded active exited  Dump dmesg to /var/log/dmesg
rhel-import-state.service          loaded active exited  Import network configuration from initramfs
rhel-readonly.service              loaded active exited  Configure read-only root support
rpcbind.service                    loaded active running RPC bind service
rsyslog.service                    loaded active running System Logging Service
smartd.service                     loaded active running Self Monitoring and Reporting Technology (SMART) Daemon
sshd.service                       loaded active running OpenSSH server daemon
sysstat.service                    loaded active exited  Resets System Activity Logs
systemd-binfmt.service             loaded active exited  Set Up Additional Binary Formats
systemd-fsck-root.service          loaded active exited  File System Check on Root Device
systemd-journald.service           loaded active running Journal Service
systemd-logind.service             loaded active running Login Service
systemd-random-seed.service        loaded active exited  Load/Save Random Seed
systemd-readahead-collect.service  loaded active exited  Collect Read-Ahead Data
systemd-readahead-replay.service   loaded active exited  Replay Read-Ahead Data
systemd-remount-fs.service         loaded active exited  Remount Root and Kernel File Systems
systemd-sysctl.service             loaded active exited  Apply Kernel Variables
systemd-tmpfiles-setup-dev.service loaded active exited  Create static device nodes in /dev
systemd-tmpfiles-setup.service     loaded active exited  Create Volatile Files and Directories
systemd-udev-trigger.service       loaded active exited  udev Coldplug all Devices
systemd-udevd.service              loaded active running udev Kernel Device Manager
systemd-update-utmp.service        loaded active exited  Update UTMP about System Reboot/Shutdown
systemd-user-sessions.service      loaded active exited  Permit User Sessions
systemd-vconsole-setup.service     loaded active exited  Setup Virtual Console
xinetd.service                     loaded active running Xinetd A Powerful Replacement For Inetd
EOF

$cmds{systemctl_list_units_tagret}{cmd}="/usr/bin/systemctl list-units --type=target --no-pager --no-legend";
$cmds{systemctl_list_units_tagret}{out}=<<'EOF';
basic.target        loaded active active Basic System
cryptsetup.target   loaded active active Encrypted Volumes
getty.target        loaded active active Login Prompts
local-fs-pre.target loaded active active Local File Systems (Pre)
local-fs.target     loaded active active Local File Systems
multi-user.target   loaded active active Multi-User System
network.target      loaded active active Network
nfs.target          loaded active active Network File System Server
paths.target        loaded active active Paths
remote-fs.target    loaded active active Remote File Systems
slices.target       loaded active active Slices
sockets.target      loaded active active Sockets
swap.target         loaded active active Swap
sysinit.target      loaded active active System Initialization
timers.target       loaded active active Timers
EOF

$cmds{chkconfig_list_el7}{cmd}="/sbin/chkconfig --list";
$cmds{chkconfig_list_el7}{out} = <<'EOF';
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

