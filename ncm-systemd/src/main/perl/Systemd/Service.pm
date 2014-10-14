# ${license-info}
# ${developer-info}
# ${author-info}
# ${build-info}

package NCM::Component::Systemd::Service;

use 5.10.1;
use strict;
use warnings;

use CAF::Process;
use CAF::Service;
use CAF::FileReader;
use Readonly;
use EDG::WP4::CCM::Element qw(unescape);

our $EC=LC::Exception::Context->new->will_store_all;

# these won't be turned off with default settings
# TODO add some systemd services?
# TODO protecting network assumes ncm-network is being used
# TODO shouldn't these services be "always on"?
Readonly::Hash my %DEFAULT_PROTECTED_SERVICES => (
    network => 1,
    messagebus => 1,
    haldaemon => 1,
    sshd => 1,
);

Readonly my $CHKCONFIG => "/sbin/chkconfig";
Readonly my $SERVICE => "/sbin/service";
Readonly my $SYSTEMCTL => "/usr/bin/systemctl";

Readonly my $BASE => "/software/components/${project.artifactId}";
Readonly my $LEGACY_BASE => "/software/components/chkconfig";

# TODO should match schema default
Readonly my $DEFAULT_STARTSTOP => 1; # startstop true by default
Readonly my $DEFAULT_STATE => "on"; # state on by default

Readonly my $TARGET_DEFAULT => "default";
Readonly my $TARGET_RESCUE => "rescue";
Readonly my $TARGET_MULTIUSER => "multi-user";
Readonly my $TARGET_GRAPHICAL => "graphical";
Readonly my $TARGET_POWEROFF => "poweroff";
Readonly my $TARGET_REBOOT => "reboot";
Readonly my $DEFAULT_TARGET => $TARGET_MULTIUSER; # default level (if default.target is not responding)
# This array also contains all supported targets
Readonly::Array my @DEFAULT_LEVEL2TARGET => ($TARGET_POWEROFF, # 0
                                          $TARGET_RESCUE, # 1
                                          $TARGET_MULTIUSER, $TARGET_MULTIUSER, $TARGET_MULTIUSER, # 234
                                          $TARGET_GRAPHICAL, # 5
                                          $TARGET_REBOOT); # 6

Readonly my $DEFAULT_LEGACY_RUNLEVEL => 3; # If inittab has no default set 
Readonly my $LEGACY_INITTAB => "/etc/inittab"; # meaningless in systemd

Readonly my $TYPE_SYSV => 'sysv';
Readonly my $TYPE_SERVICE => 'service';
Readonly my $TYPE_TARGET => 'target';

# Local cache of the mapping between runlevels and targets  
my @level2target;

# convert service C<detail> hash to human readable string
sub service_text
{
    my ($self, $detail) = @_;
    
    my $text = "service $detail->{name} (";
    $text .= "state $detail->{state} ";
    $text .= "startstop $detail->{startstop} ";
    $text .= "type $detail->{type} ";
    $text .= "targets ".join(",", @{$detail->{targets}});
    $text .= ")";
    
    return $text;
}

# Create the level2target map (will reset existing one)
# Sets and returns level2target (return is merely for testing)
sub _generate_level2target 
{
    my $self = shift;
    # convenience lookup hash
    my %targets = map { $_ => 1 } @DEFAULT_LEVEL2TARGET;

    # reset
    @level2target = ();

    foreach my $lvl (0..6) {
        my $target = $DEFAULT_LEVEL2TARGET[$lvl];
        my $id = $self->service_systemctl_show("runlevel$lvl.target")->{Id};

        # Is it a target?
        if ($id && $id =~ m/^(.*)\.target$/) {
            if (! exists($targets{$1})) {
                $self->verbose("Target $1 for level $lvl none of default targets");
            } elsif (! ($target eq $1)) {
                $self->verbose("Target $1 for level $lvl different from default $target");
            } else {
                $self->verbose("Target $1 for level $lvl found.");
            }
            $target = $1;
        } else {
            $id = "<undef>" if (!defined($id)); # handle unitialized value warning
            $self->warn("Unable to identify target for runlevel$lvl.target (Id $id). Using default target $target.");
        }
        push(@level2target, $target);
    }
    
    return \@level2target;   
}


# Convert the legacy levels to new systemsctl targets
# C<legacylevel> is a string with integers e.g. "234"
# retruns reference to an array with the targets
sub service_convert_legacy_levels 
{
    my ($self, $legacylevel) = @_;
    
    if (! @level2target) {
        $self->verbose("Creating level2target cache");
        $self->_generate_level2target;
        if (! @level2target) {
            $self->error("Failed to generate levle2target cache");
        };
    }
    
    # only keep the relevant ones
    my @targets;
    if (defined($legacylevel)) {
        foreach my $lvl (0..6) {
            if ($legacylevel =~ m/$lvl/) {
                my $target = $level2target[$lvl];
                push(@targets, $target) if (! grep {$_ eq $target} @targets);
            }
        }
    
        # only for non-default/non-valid runlevels?    
        if (! scalar @targets) {
            $self->warn("legacylevel set to $legacylevel, but not converted in new targets. Using default $DEFAULT_TARGET.");
            push(@targets, $DEFAULT_TARGET);
        } 
        $self->verbose("Converted legacylevel '$legacylevel' in ".join(', ', @targets));
    } else {
        $self->verbose("legacylevel undefined, using default $DEFAULT_TARGET");
        push(@targets, $DEFAULT_TARGET);
    };    
    
    return \@targets;
}


# Extract the services from LEGACYBASE
# Convert legacy chkconfig structure in new structure
sub service_get_quattor_legacy_services
{
    my ($self, $config) = @_;
    
    my %services;
    return %services if (! $config->elementExists("$LEGACY_BASE/service"));
     
    my $stree = $config->getElement("$LEGACY_BASE/service")->getTree;
    while (my ($service, $detail) = each %$stree) {
        # fix the details to reflect new schema
        
        # all legacy types are assumed to be sysv services
        $detail->{type} = $TYPE_SYSV;
        
        # set the name (not mandatory in new schema either)
        $detail->{name} = unescape($service) if (! exists($detail->{name}));

        my $reset = delete $detail->{reset};
        $self->verbose('Strip the reset value $reset from service $detail->{name}') if defined($reset);

        my $state = $DEFAULT_STATE;
        
        my $add = delete $detail->{add};
        my $del = delete $detail->{del};
        my $on = delete $detail->{on};
        my $off = delete $detail->{off};
        
        if($del) {
            $state = "del"; # implies off, ignores on/add
        } elsif(defined($off)) {
            $state = "off"; # ignores on, implies add
        } elsif(defined($on)) {
            $state = "on"; # implies add
        } elsif($add) {
            $state = "add";
        }

        $detail->{state} = $state;

        my $leveltxt;
        # off-level precedes on-level (as off state precedes on state)
        if(defined($off)) {
            $leveltxt = $off;
        } elsif(defined($on)) {
            $leveltxt = $on;
        }
        $detail->{targets} = $self->service_convert_legacy_levels($leveltxt);
        
        # startstop mandatory
        $detail->{startstop} = $DEFAULT_STARTSTOP if (! exists($detail->{startstop}));

        $self->verbose("Add legacy name $detail->{name} (service $service)");
        $self->debug(1, "Add legacy ", $self->service_text($detail));
        $services{$detail->{name}} = $detail;
                
    };

    return %services;    
}


# Extract the services from BASE and LEGACYBASE
sub service_get_quattor_services
{
    my ($self, $config) = @_;

    my %services = $self->service_get_quattor_legacy_services($config);
    
    # will overwrite new ones
    if ($config->elementExists("$BASE/service")) {
        my $stree = $config->getElement("$BASE/service")->getTree;
        while (my ($service, $detail) = each %$stree) {
            # only set the name (not mandatory in new schema, to be added here)
            $detail->{name} = unescape($service) if (! exists($detail->{name}));

            # all new services are assumed type service
            $detail->{type} = $TYPE_SERVICE if (! exists($detail->{type}));
            
            if(exists($services{$detail->{name}})) {
                $self->verbose("Going to replace legacy service ",
                               $self->service_text($services{$detail->{name}}), 
                               "with new one.");                
            }
            $self->verbose("Add service name $detail->{name} (service $service)");
            $self->debug(1, "Add ", $self->service_text($detail));

            $services{$detail->{name}} = $detail;
        }
    };

    # TODO figure out a way to specify what off-targets and what on-targets mean.
    # If on is defined, all other targets are off
    # If off is defined, all others are on or also off? (2nd case: off means off everywhere) 
    
    return %services;
}


# get current configured services via chkconfig --list
sub service_get_current_services_hash_chkconfig {
    my $self = shift;

    my %current;
    my $data = CAF::Process->new([$CHKCONFIG, '--list'], log=>$self)->output();
    my $ec = $?;
    if($ec) {
        $self->error("Cannot get list of current services from $CHKCONFIG: ec $ec ($data)");
        return;
    }

    foreach my $line (split(/\n/,$data)) {
        # afs       0:off   1:off   2:off   3:off   4:off   5:off   6:off
        # ignore the "xinetd based services"
        if ($line =~ m/^([\w\-]+)\s+((?:[0-6]:(?:on|off)(?:\s+|\s*$)){7})/) {
            my ($servicename, $levels) = ($1,$2);
            my $detail = { name => $servicename, type => $TYPE_SYSV, startstop => $DEFAULT_STARTSTOP};

            if ($levels =~ m/[0-6]:on/) {
                my $ontargets = $self->service_convert_legacy_levels(join('', $levels =~ /([0-6]):on/g));
                $detail->{state} = "on";
                $detail->{targets} = $ontargets;    
            } else {
                my $offtargets = $self->service_convert_legacy_levels(join('', $levels =~ /([0-6]):off/g));
                $detail->{state} = "off";
                $detail->{targets} = $offtargets;    
            }
            
            $self->verbose("Add chkconfig service $detail->{name}");
            $self->debug(1, "Add chkconfig ", $self->service_text($detail));
            $current{$servicename} = $detail;
        }
    }
    return %current;
}


# get current configured services via systemctl list-unit-files
# specify C<type> (eg service or target; not sysv as those have no unit files)
sub service_get_current_services_hash_systemctl {
    my ($self, $type) = @_;

    my $treg = '^('.join('|', $TYPE_SERVICE, $TYPE_TARGET).')$';
    if (!($type && $type =~ m/$treg/)) {
        $self->error("Undefined or wrong type $type for systemctl list-unit-files");
        return;
    }
    
    my %current;
    my $data = CAF::Process->new([$SYSTEMCTL, 'list-unit-files', '--all', '--no-pager', '--no-legend', '--type', $type], log=>$self)->output();
    my $ec = $?;

    if($ec) {
        $self->error("Cannot get list of current unit files for type $type from $SYSTEMCTL: ec $ec ($data)");
        return;
    }
    
    my $reg = '^(\s*\S+)\.'.$type.'\s+(\w+)\s*$';
    foreach my $line (split(/\n/,$data)) {
        if ($line =~ m/$reg/) {
            my ($servicename, $state) = ($1,$2);
            my $detail = { name => $servicename, type => $type, startstop => $DEFAULT_STARTSTOP};

            # TODO State map eg static to ...?

            # TODO which level? lookup via status
            $detail->{targets} = [];
            
            $self->verbose("Add chkconfig service $detail->{name}");
            $self->debug(1, "Add chkconfig ", $self->service_text($detail));
            $current{$servicename} = $detail;
        }
    }
    return %current;

};

# see what is currently configured in terms of services
sub service_get_current_services_hash {
    my $self = shift;
    my %current;
    my $data = CAF::Process->new([$CHKCONFIG, '--list'],log=>$self)->output();

    if($?) {
        $self->error("Cannot get list of current services from $CHKCONFIG: $!");
        return;
    } else {
        foreach my $line (split(/\n/,$data)) {
            # afs       0:off   1:off   2:off   3:off   4:off   5:off   6:off
            # ignore the "xinetd based services"
            if ($line =~ m/^([\w\-]+)\s+0:(\w+)\s+1:(\w+)\s+2:(\w+)\s+3:(\w+)\s+4:(\w+)\s+5:(\w+)\s+6:(\w+)\s*$/) {
                $current{$1} = [$2,$3,$4,$5,$6,$7,$8];
            }
            #if ($line =~ m/^([\w\-]+)\s+((?:[0-6]:(?:on|off)(?:\s+|\s*$)){7})/) {
            if ($line =~ m/^([\w\-]+)\s+0:(\w+)/) {
                $current{"$1.new"} = $2;
            }
        }
    }
    return %current;
}

# legacy method to determine the default runlevel
sub service_get_default_runlevel
{
    my $self = shift;
    my $inittab = CAF::FileReader->new($LEGACY_INITTAB);
    my $defaultrunlevel = $DEFAULT_LEGACY_RUNLEVEL;
    if ("$inittab" =~ m/^[^:]*:(\d):initdefault:/m) {
        $defaultrunlevel = $1;
        $self->verbose("Found initdefault $defaultrunlevel set in inittab $LEGACY_INITTAB");
    } else {
        $self->verbose("No initdefault set in inittab $LEGACY_INITTAB; using default legacy runlevel $defaultrunlevel");
    }
    return $defaultrunlevel;
}


# legacy method to get the runlevel
# different from ncm-chkconfig (doesn't return undef if commands produce invalid output)
sub service_get_current_runlevel 
{
    my $self = shift;

    my $process = sub {
        my ($self, $cmd, $reg) = @_;
        my $proc = CAF::Process->new($cmd, log=>$self);
        if (! $proc->is_executable) {
            $self->verbose("No runlevel via command $proc (not executable)");
            return;
        }
        
        my $line = $proc->output();
        my $ec = $?;
        my $level;
        if ($line && $line =~ m/$reg/m) {
            $level = $1;
            $self->info("Current runlevel from command $proc is $level");
        } else {
            # happens at install time
            $self->warn("Cannot get runlevel from command $proc: $line (exitcode $ec). Using default reunlevel $level.");  
        }
        return $level
    };
    
    # output: N 5
    my $level = &$process($self, ["/sbin/runlevel"], qr{^\w+\s+(\d+)\s*$});
    return $level if (defined($level));

    # output:         run-level 5  Feb 19 16:08                   last=S
    $level = &$process($self, ["/usr/bin/who", "-r"], qr{^\s*run-level\s+(\d+)\s});
    return $level if (defined($level));

    $level = $self->service_get_default_runlevel();
    $self->verbose("Returning default runlevel $level (other commands unavailable/failed)");
    return $level;
}

# Run systemctl show on single C<$name> and return parsed output
# If C<$name> is undef, the manager itself is shown
sub service_systemctl_show
{
    my ($self, $name) = @_;
    my $proc = CAF::Process->new([$SYSTEMCTL, "--no-pager", "--all", "show"]);
    if (defined($name)) {
        $proc->pushargs($name);
        $self->verbose("service_systemctl_show for name $name");
    } else {
        $self->verbose("service_systemctl_show for manager itself, name undefined");
    }
    my $output = $proc->output();
    my $ec = $?;
    if($ec) {
        my $msg = "systemctl show failed (cmd $proc; ec $ec)";
        $msg .= " with output $output" if (defined($output));
        $self->error($msg);
        return;
    }
    
    # output is k=[v]
    # some keys will be split on whitespace
    my @isarray = qw(Names Requires Wants Before After Conflicts);
    my $res={};
    while($output =~ m/^([^=\s]+)\s*=(.*)?$/mg) {
        my ($k,$v) = ($1,"$2");
        if (grep {$_ eq $k} @isarray) {
            my @values = split(/\s+/, $v);
            $res->{$k} = \@values;
        } else {
            $res->{$k} = $v;
        }
    }
    
    return $res;    
}

## To port 
##

sub service_configure 
{
    my ($self, $config)=@_;

    my $default = $config->getValue("$BASE/default");
    $self->info("Default setting for non-specified services: $default");

    my %currentservices = $self->get_current_services_hash();

    my $currentrunlevel = $self->getcurrentrunlevel();

    my (%configuredservices, @cmdlist, @servicecmdlist);

    my $tree = $config->getElement('/software/components/chkconfig')->getTree;
    while(my ($escservice, $detail) = each %{$tree->{service}}) {
        my ($service, $startstop);

        #get startstop value if it exists
        $startstop = $detail->{startstop} if (exists($detail->{startstop}));

        #override the service name to use value of 'name' if it is set
        if (exists($detail->{name})) {
            $service = $detail->{name};
        } else {
            $service = unescape($escservice);
        }

        # remember about this one for later
        $configuredservices{$service}=1;

        # unfortunately not all combinations make sense. Check for some
        # of the more obvious ones, but eventually we need a single
        # entry per service.
        while(my ($optname, $optval) = each %$detail) {
            my $msg = "$service: ";

            # 6 kinds of entries: on,off,reset,add,del and startstop.
            if($optname eq 'add' && $optval) {
                if(exists($detail->{del})) {
                    $self->warn("Service $service has both 'add' and 'del' settings defined, 'del' wins");
                } elsif($detail->{on}) {
                    $self->info("Service $service has both 'add' and 'on' settings defined, 'on' implies 'add'");
                } elsif (! $currentservices{$service} ) {
                    $msg .= "adding to chkconfig";
                    push(@cmdlist, [$CHKCONFIG, "--add", $service]);

                    if($startstop) {
                        # this smells broken - shouldn't we check the desired runlevel? At least we no longer do this at install time.
                        $msg .= " and starting";
                        push(@servicecmdlist, [$SERVICE, $service, "start"]);
                    }
                    $self->info($msg);
                } else {
          $self->debug(2, "$service is already known to chkconfig, but running 'reset'");
          push(@cmdlist, [$CHKCONFIG, $service, "reset"]);
                }
            } elsif ($optname eq 'del' && $optval) {
                if ($currentservices{$service} ) {
                    $msg .= "removing from chkconfig";
                    push(@cmdlist, [$CHKCONFIG, $service, "off"]);
                    push(@cmdlist, [$CHKCONFIG, "--del", $service]);

                    if($startstop) {
                        $msg .= " and stopping";
                        push(@servicecmdlist, [$SERVICE, $service, "stop"]);
                    }
                    $self->info($msg);
                } else {
                    $self->debug(2, "$service is not known to chkconfig, no need to 'del'");
                }
            } elsif ($optname eq 'on') {
                if(exists($detail->{off})) {
                    $self->warn("Service $service has both 'on' and 'off' settings defined, 'off' wins");
                } elsif (exists($detail->{del})) {
                    $self->warn("Service $service has both 'on' and 'del' settings defined, 'del' wins");
                } elsif(!$self->validrunlevels($optval)) {
                    $self->warn("Invalid runlevel string $optval defined for ".
                                "option \'$optname\' in service $service, ignoring");
                } else {
                    if(!$optval) {
                        $optval = '2345'; # default as per doc (man chkconfig)
                        $self->debug(2, "$service: assuming default 'on' runlevels to be $optval");
                    }
                    my $currentlevellist = "";
                    if ($currentservices{$service} ) {
                        foreach my $i (0.. 6) {
                            if ($currentservices{$service}[$i] eq 'on') {
                                $currentlevellist .= "$i";
                            }
                        }
                    } else {
                        $self->info("$service was not configured, 'add'ing it");
                        push(@cmdlist, [$CHKCONFIG, "--add", $service]);
                    }
                    if ($optval ne $currentlevellist) {
                        $msg .= "was 'on' for \"$currentlevellist\", new list is \"$optval\"";
                        push(@cmdlist, [$CHKCONFIG, $service, "off"]);
                        push(@cmdlist, [$CHKCONFIG, "--level", $optval,
                             $service, "on"]);
                        if($startstop && ($optval =~ /$currentrunlevel/)) {
                            $msg .= " ; and starting";
                            push(@servicecmdlist,[$SERVICE, $service, "start"]);
                        }
                        $self->info($msg);
                    } else {
                        $self->debug(2, "$service already 'on' for \"$optval\", nothing to do");
                    }
                }
            } elsif ($optname eq 'off') {
                if(exists($detail->{del})) {
                    $self->info("service $service has both 'off' and 'del' settings defined, 'del' wins");
                } elsif(!$self->validrunlevels($optval)) {
                    $self->warn("Invalid runlevel string $optval defined for ".
                                "option \'$optname\' in service $service");
                } else {
                    if(!$optval) {
                        $optval = '2345'; # default as per doc (man chkconfig)
                        $self->debug(2, "$service: assuming default 'on' runlevels to be $optval");  # 'on' because this means we have to turn them 'off' here..
                    }
                    my $currentlevellist = "";
                    my $todo = "";
                    if ($currentservices{$service}) {
                        foreach my $i (0.. 6) {
                            if ($currentservices{$service}[$i] eq 'off') {
                                $currentlevellist .= "$i";
                            }
                        }
                        foreach my $s (split('',$optval)) {
                            if ($currentlevellist !~ /$s/) {
                                $todo .="$s";
                            } else {
                                $self->debug(3, "$service: already 'off' for runlevel $s");
                            }
                        }
                    }
                    if ($currentlevellist &&        # do not attempt to turn off a non-existing service
                            $todo &&                    # do nothing if service is already off for everything we'd like to turn off..
                            ($optval ne $currentlevellist)) {
                        $msg .= "was 'off' for '$currentlevellist', new list is '$optval', diff is '$todo'";
                        push(@cmdlist, [$CHKCONFIG, "--level", $optval,
                                        $service, "off"]);
                        if($startstop and ($optval =~ /$currentrunlevel/)) {
                            $msg .= "; and stopping";
                            push(@cmdlist, [$SERVICE, $service, "stop"]);
                        }
                        $self->info($msg);
                    }
                }
            } elsif ($optname eq 'reset') {
                if(exists($detail->{del})) {
                    $self->warn("service $service has both 'reset' and 'del' settings defined, 'del' wins");
                } elsif(exists($detail->{off})) {
                    $self->warn("service $service has both 'reset' and 'off' settings defined, 'off' wins");
                } elsif(exists($detail->{on})) {
                    $self->warn("service $service has both 'reset' and 'on' settings defined, 'on' wins");
                } elsif($self->validrunlevels($optval)) {
                    # FIXME - check against current?.
                    $msg .= 'chkconfig reset';
                    if($optval) {
                        push(@cmdlist,[$CHKCONFIG, "--level", $optval,
                                        $service, "reset"]);
                    } else {
                        push(@cmdlist, [$CHKCONFIG, $service, "reset"]);
                    }
                    $self->info($msg);
                } else {
                    $self->warn("Invalid runlevel string $optval defined for ".
                                "option $optname in service $service");
                }
            } elsif ($optname eq 'startstop' or $optname eq 'add' or
                        $optname eq 'del' or $optname eq 'name') {
                # do nothing
            } else {
                $self->error("Undefined option name $optname in service $service");
                return;
            }
        } # while
    } # while

    # check for leftover services that are known to the machine but not in template
    if ($default eq 'off') {
        $self->debug(2,"Looking for other services to turn 'off'");
        foreach my $oldservice (keys(%currentservices)) {
            if ($configuredservices{$oldservice}) {
                $self->debug(2,"$oldservice is explicitly configured, keeping it");
                next;
            }
            # special case "network" and friends, awfully hard to recover from if turned off.. #54376
            if(exists($DEFAULT_PROTECTED_SERVICES{$oldservice}))  {
                $self->warn("DEFAULT_PROTECTED_SERVICES: refusing to turn '$oldservice' off via a default setting.");
                next;
            }
            # turn 'em off.
            if (defined($currentrunlevel) and  $currentservices{$oldservice}[$currentrunlevel] ne 'off' ) {
                # they supposedly are even active _right now_.
                $self->debug(2,"$oldservice was not 'off' in current level $currentrunlevel, 'off'ing and 'stop'ping it..");
                $self->info("$oldservice: oldservice stop and chkconfig off");
                push(@servicecmdlist, [$SERVICE, $oldservice, "stop"]);
                push(@cmdlist, [$CHKCONFIG, $oldservice, "off"]);
            } else {
                # see whether this was non-off somewhere else
                my $was_on = "";
                foreach my $i ((0..6)) {
                    if ( $currentservices{$oldservice}[$i] ne 'off' ) {
                        $was_on .= $i;
                    }
                }
                if($was_on) {
                    $self->debug(2,"$oldservice was not 'off' in levels $was_on, 'off'ing it..");
                    push(@cmdlist, [$CHKCONFIG, "--level", $was_on,
                                    $oldservice, "off"]);
                } else {
                    $self->debug(2,"$oldservice was already 'off', nothing to do");
                }
            }
        }
    }

    #perform the "chkconfig" commands
    $self->run_and_warn(\@cmdlist);

    #perform the "service" commands - these need ordering and filtering
    if($currentrunlevel) {
        if ($#servicecmdlist >= 0) {
            my @filteredservicelist = $self->service_filter(@servicecmdlist);
            my @orderedservicecmdlist = $self->service_order($currentrunlevel, @filteredservicelist);
            $self->run_and_warn(\@orderedservicecmdlist);
        }
    } else {
        $self->info("Not running any 'service' commands at install time.");
    }

}


sub service_filter 
{
    # check the proposed "service" actions:
    #   drop anything that is already running from being restarted
    #   drop anything that isn't from being stopped.
    #   relies on 'service bla status' to return something useful (lots don't).
    #   If in doubt, we leave the command..
    my ($self, @service_actions) = @_;
    my ($service, $action, @new_actions);
    foreach my $line (@service_actions) {
        $service = $line->[1];
        $action = $line->[2];

        my $current_state=CAF::Process->new([$SERVICE, $service, 'status'],log=>$self)->output();

        if($action eq 'start' && $current_state =~ /is running/s ) {
            $self->debug(2,"$service already running, no need to '$action'");
        } elsif ($action eq 'stop' && $current_state =~ /is stopped/s ) {
            $self->debug(2,"$service already stopped, no need to '$action'");
        } else {    # keep.
            if( $current_state =~ /is (running|stopped)/s) {  # these are obvious - not the desired state.
                $self->debug(2,"$service: '$current_state', needs '$action'");
            } else {
                # can't figure out
                $self->info("Can't figure out whether $service needs $action from\n$current_state");
            }
            push(@new_actions, [$SERVICE, $service, $action]);
        }
    }
    return @new_actions;
}

sub service_order 
{
    # order the proposed "service" actions:
    #   first stop things, then start. In both cases use the init script order, as shown in /etc/rc.?d/{S|K}numbername
    #   Ideally, figure out whether we are booting, and at what priority, and don't do things that will be done anyway..
    #   might get some services that need stopping but are no longer registered with chkconfig - these get killed late.

    my ($self, $currentrunlevel, @service_actions) = @_;
    my (@new_actions, @stop_list, @start_list, $service, $action);
    my $bootprio = 999; # FIXME: until we can figure that out

    foreach my $line (@service_actions) {
        $service = $line->[1];
        $action = $line->[2];

        my ($prio,$serviceprefix);
        if($action eq 'stop') {
            $prio = 99;
            $serviceprefix = 'K';
        } elsif ($action eq 'start') {
            $prio = 1; # actually, these all should be chkconfiged on!
            $serviceprefix = 'S';
        }

        my $globtxt = "/etc/rc$currentrunlevel.d/$serviceprefix*$service";
        my @files = glob($globtxt);
        my $nrfiles = scalar(@files);
        if ($nrfiles == 0) {
            $self->warn("No files found matching $globtxt");
        } elsif ($nrfiles > 1) {
            $self->warn("$nrfiles files found matching $globtxt, using first one.".
                        " List: ".join(',',@files));
        }
        if($nrfiles && $files[0] =~ m:/$serviceprefix(\d+)$service:) { # assume first file/link, if any.
            $prio = $1;
            $self->debug(3,"Found $action prio $prio for $service");
        } else {
            $self->warn("Did not find $action prio for $service, assume $prio");
        }


        if($action eq 'stop') {
            push (@stop_list, [$prio, $line]);
        } elsif ($action eq 'start') {
            if ($prio < $bootprio) {
                push (@start_list, [$prio, $line]);
            } else {
                $self->debug(3, "dropping '$line' since will come later in boot - $prio is higher than current $bootprio");
            }
        }
    }

    # so we've got both lists, with [priority,command]. just sort them, drop the "priority" column, and concat.
    @new_actions = map { $$_[1] } sort { $$a[0] <=> $$b[0] } @stop_list;
    push (@new_actions , map { $$_[1] } sort { $$a[0] <=> $$b[0] } @start_list);
    return @new_actions;
}

sub service_validrunlevels 
{
    my ($self, $str) = @_;
    chomp($str);

    return 1 unless ($str);

    if($str =~ /^[0-7]+$/) {
        return 1;
    }

    return 0;
}


sub service_run_and_warn 
{
    my ($self, $cmdlistref) = @_;
    foreach my $cmd (@$cmdlistref) {
        my $out = CAF::Process->new($cmd, log=>$self)->output();
        if ($?) {
            chomp($out);
            $self->warn("Exitcode $?, output $out");
        }
    }
}

1;