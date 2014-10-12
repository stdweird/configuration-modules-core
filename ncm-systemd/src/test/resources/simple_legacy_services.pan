object template simple_legacy_services;

include 'legacy_services';

prefix "/software/components/chkconfig/service";

# additional combinations
"{test_on_off}" = nlist("on","123", "off", "345");
"{test_add_on}" = nlist("add",true, "on", "234");
"{test_off_add}" = nlist("off","45", "add", true);
"{test_del_off_on_add}" = nlist("del",true, "add", true, "on", "2345");
"{default}" = nlist();
