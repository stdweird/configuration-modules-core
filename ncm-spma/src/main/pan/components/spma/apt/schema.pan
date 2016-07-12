# ${license-info}
# ${developer-info}
# ${author-info}

declaration template components/spma/apt/schema;

include 'components/spma/schema';

type component_spma_apt = {
    include structure_component
    include component_spma_common
};

bind "/software/components/spma" = component_spma_apt;
