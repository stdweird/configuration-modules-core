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

include 'quattor/schema';

# legacy conversion
# 1->rescue
# 234 -> multi-user
# 5 -> graphical
type ${project.artifactId}_level = string with match(SELF, "^(rescue|multi-user|graphical)$");

type ${project.artifactId}_service_type = {
    "name" ? string
    "state" : string = 'on' with match(SELF,"^(on|add|off|del)$")
    "levels" : ${project.artifactId}_level[] = list("multi-user") 
    "startstop" : boolean = true
};

type component_${project.artifactId}_type = {
  include structure_component
  "service" : ${project.artifactId}_service_type{}
  "default" ? string with match (SELF, '^(ignore|off)$')
};

bind "/software/components/${project.artifactId}" = component_${project.artifactId}_type;
