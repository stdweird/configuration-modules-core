unique template services;

prefix "/software/components/chkconfig2/service";

"{test2_on}" = nlist("state", "on", "levels", list("rescue", "multi-user"), "startstop", true);
"{test2_add}" = nlist("state","add", "levels", list("multi-user"), "startstop", true);
"{test2_on_rename}" = nlist("state", "on", "levels", list("multi-user"), "startstop", true, "name","othername");

# redefine old ones / these have the same name
"{test_off}" = nlist("state", "del","levels", list("rescue"), "startstop", true);
"{test_del}" = nlist("state", "on", "levels", list("rescue"), "startstop", false);

