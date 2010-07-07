# ${license-info}
# ${developer-info}
# ${author-info}

# Coding style: emulate <TAB> characters with 4 spaces, thanks!
################################################################################

unique template components/etcservices/config-rpm;
include components/etcservices/schema;

# Package to install
"/software/packages"=pkg_repl("ncm-etcservices","1.2.0-1","noarch");
 
"/software/components/etcservices/dependencies/pre" ?= list("spma");
"/software/components/etcservices/active" ?= true;
"/software/components/etcservices/dispatch" ?= true;
 
