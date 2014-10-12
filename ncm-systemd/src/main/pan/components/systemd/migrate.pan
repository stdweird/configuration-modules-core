unique template components/${project.artifactId}/migrate;

# move from chkconfig to ${project.artifactId}
"/software/components/${project.artifactId}" = {
    if(exists("/software/components/chkconfig/default")) { 
        SELF["default"] = value("/software/components/chkconfig/default");
    };
    SELF;   
};

# disable chkconfig
"/software/components/chkconfig/active" = false;
 
# TODO fix dependencies
"/" = {error('fix deps')};