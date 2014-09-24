# ${license-info}
# ${developer-info}
# ${author-info}

############################################################
#
# type definition components/${project.artifactId}
#
#
#
############################################################

declaration template components/${project.artifactId}/schema;

include { 'quattor/schema' };

function ${project.artifactId}_allow_combinations = {
    # Check if certain combinations of service_types are allowed
    # Return true if they are allowed, throws an error otherwise

    if ( ARGC != 1 || ! is_nlist(ARGV[0]) ) {
        error('${project.artifactId}_allow_combinations requires 1 nlist as argument');
    };
    service = ARGV[0];

    # A mapping between chkconfig service_types that the component will
    # prefer over other service_types. The ones listed here are considered
    # dangerous.
    # Others combinations are still allowed (eg combining del and off,
    # where del will be preferred)
    svt_map = nlist(
        'del',list("add","on","reset"),
        'off',list("on","reset"),
        'on',list("reset"),
    );
    foreach(win_svt;svt_list;svt_map) {
        if (exists(service[win_svt])) {
            foreach(idx;svt;svt_list) {
                if (exists(service[svt])) {
                    error(format("Cannot combine '%s' with '%s' (%s would win).",win_svt, svt, win_svt));
                };
            };
        };
    };
    return(true);
};

type ${project.artifactId}_service_type = {
  "name"      ? string
  "add"       ? boolean
  "del"       ? boolean
  "on"        ? string
  "off"       ? string
  "reset"     ? string
  "startstop" ? boolean
} with ${project.artifactId}_allow_combinations(SELF);

type component_${project.artifactId}_type = {
  include structure_component
  "service" : service_type{}
  "default" ? string with match (SELF, 'ignore|off')
};

bind "/software/components/${project.artifactId}" = component_${project.artifactId}_type;
