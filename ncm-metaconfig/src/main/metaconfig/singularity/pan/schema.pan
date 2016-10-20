declaration template metaconfig/singularity/schema;

include 'pan/types';

@documentation{
singularity.conf settings
This is the global configuration file for Singularity. This file controls
what the container is allowed to do on a particular host, and as a result
this file must be owned by root.
}
type service_singularity = {
    # standalone ones
    @{Should we allow users to utilize the setuid binary for launching singularity?
    The majority of features require this to be set to yes, but newer Fedora and
    Ubuntu kernels can provide limited functionality in unprivileged mode}
    'allow-setuid' : boolean = true
    @{Should we allow users to request the PID namespace?}
    'allow-pid-ns' : boolean = true
    @{Enabling this option will make it possible to specify bind paths to locations
    that do not currently exist within the container. Some limitations still exist
    when running in completely non-privileged mode. (note: this option is only
    supported on hosts that support overlay file systems)}
    'enable-overlay' : boolean = false
    @{If /etc/passwd exists within the container, this will automatically append
    an entry for the calling user}
    'config-passwd' : boolean = true
    @{If /etc/group exists within the container, this will automatically append
    an entry for the calling user}
    'config-group' : boolean = true
    @{If there is a bind point within the container, use the host's /etc/resolv.conf}
    'config-resolv_conf' : boolean = true
    @{Should we automatically bind mount /proc within the container?}
    'mount-proc' : boolean = true
    @{Should we automatically bind mount /sys within the container?}
    'mount-sys' : boolean = true
    @{Should we automatically bind mount /dev within the container? If you select
    minimal, and if overlay is enabled, then Singularity will attempt to create
    the following devices inside the container: null, zero, random and urandom}
    'mount-dev' : boolean = true
    @{Should we automatically determine the calling user's home directory and
    attempt to mount it's base path into the container? If the --contain option
    is used, the home directory will be created within the session directory or
    can be overridden with the SINGULARITY_HOME or SINGULARITY_WORKDIR
    environment variables (or their corresponding command line options)}
    'mount-home' : boolean = true
    @{Should we automatically bind mount /tmp and /var/tmp into the container? If
    the --contain option is used, both tmp locations will be created in the
    session directory or can be specified via the  SINGULARITY_WORKDIR
    environment variable (or the --workingdir command line option)}
    'mount-tmp' : boolean = true
    @{Probe for all mounted file systems that are mounted on the host, and bind
    those into the container?}
    'mount-hostfs' : boolean = false
    @{Define a list of files/directories that should be made available from within
    the container. The file or directory must exist within the container on
    which to attach to. you can specify a different source and destination
    path (respectively) with a colon; otherwise source and dest are the same}
    'bind-path' ? string[]
    @{Allow users to influence and/or define bind points at runtime? This will allow
    users to specify bind points, scratch and tmp locations. (note: User bind
    control is only allowed if the host also supports PR_SET_NO_NEW_PRIVS)}
    'user-bind-control' : boolean = true
    @{Should we automatically propagate file-system changes from the host?
    This should be set to 'yes' when autofs mounts in the system should
    show up in the container}
    'mount-slave' : boolean = true
    @{This path specifies the location to use for mounting the container, overlays
    and other necessary file systems for the container. Note, this location
    absolutely must be local on this host}
    'container-dir' : string = '/var/singularity/mnt'
    @{This specifies the prefix for the session directory. Appended to this string
    is an identification string unique to each user and container. Note, this
    location absolutely must be local on this host. If the default location of
    /tmp/ does not work for your system, /var/singularity/sessions maybe a
    better option}
    'sessiondir-prefix' ? string
};
