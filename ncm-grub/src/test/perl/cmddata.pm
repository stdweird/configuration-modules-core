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

$files{example0}{path} = "/boot/grub/grub.conf";
$files{example0}{txt}=<<'EOF';
title Scientific Linux 4.2 / 2.6.9
        kernel /vmlinuz-2.6.9-22.0.1.EL ro root=LABEL=/
        initrd /initrd-2.6.9-22.0.1.EL.img
EOF

$files{example1}{path} = "/boot/grub/grub.conf";
$files{example1}{txt}=<<'EOF';
title Xen 3 / XenLinux 2.6.16
        kernel /xen-3.0.2-2.gz dom0_mem=400000 addthis
        module /vmlinuz-2.6.16-xen3_86.1_rhel4.1 max_loop=128 root=/dev/hda2 ro
        module /initrd-2.6.16-xen3_86.1_rhel4.1
EOF

$files{example1withheader}{path} = "/boot/grub/grub.conf";
$files{example1withheader}{txt}=<<'EOF';
# my 
# header
# do 
# not modify
# and don't put stuff before it
title Xen 3 / XenLinux 2.6.16
        kernel /xen-3.0.2-2.gz dom0_mem=400000 addthis
        module /vmlinuz-2.6.16-xen3_86.1_rhel4.1 max_loop=128 root=/dev/hda2 ro
        module /initrd-2.6.16-xen3_86.1_rhel4.1
EOF
