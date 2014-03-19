object template pod-examples;

"/software/components/grub/kernels/0" =
        nlist("kernelpath", "/vmlinuz-2.6.9-22.0.1.EL",
              "kernelargs", "ro root=LABEL=/",
              "title", "Scientific Linux 4.2 / 2.6.9",
              "initrd", "/initrd-2.6.9-22.0.1.EL.img"
);
"/software/components/grub/kernels/1" =
        nlist("multiboot", "/xen-3.0.2-2.gz",
              "mbargs", "dom0_mem=400000",
              "title", "Xen 3 / XenLinux 2.6.16",
              "kernelpath", "/vmlinuz-2.6.16-xen3_86.1_rhel4.1",
              "kernelargs", "max_loop=128 root=/dev/hda2 ro",
              "initrd", "/initrd-2.6.16-xen3_86.1_rhel4.1"
);
