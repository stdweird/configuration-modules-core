declaration template metaconfig/httpd/types_simple;

include 'pan/types';
include 'components/accounts/functions';

type httpd_cipherstring = string with match(SELF, "^(TLSv1|TLSv1.0|TLSv1.1|TLSv1.2)$")
    || error("Use a modern cipher suite, for Pete's sake!");

type httpd_nss_protocol = string with match(SELF, "^(TLSv1.0|SSLv3|All)$");
type httpd_nss_cipherstring = string with match(SELF, '^(\+|-)(rsa_3des_sha|rsa_des_56_sha|rsa_des_sha|rsa_null_md5|rsa_null_sha|rsa_rc2_40_md5|rsa_rc4_128_md5|rsa_rc4_128_sha|rsa_rc4_40_md5|rsa_rc4_56_sha|fortezza|fortezza_rc4_128_sha|fortezza_null|fips_des_sha|fips_3des_sha|rsa_aes_128_sha|rsa_aes_256_sha)$');

type httpd_kerberos = {
    "keytab" : string # this becomes krb5keytab (but nlists can't start with digits)
    "methodnegotiate" : boolean
    "methodk5passwd" : boolean
    "servicename" : string
    "authrealms" : string[]
    "savecredentials" : boolean = false
};

type httpd_shibboleth = {
    "useheaders" ? boolean
    "requestsetting" ? string[]
};

type httpd_log_custom = {
    "location" : string
    "name" : string # this should be an existing format
};

type httpd_log_format = {
    # logformat "expr" name
    "expr" : string
    "name" : string
};

type httpd_log = {
    "error" ? string
    "transfer" ? string
    "level" ? string with match(SELF, "^(debug|info|notice|warn|error|crit|alert|emerg)$")
    "format" ? httpd_log_format[]
    "custom" ? httpd_log_custom[]
};

type httpd_icon_add = {
    "icon" : string
    "names" : string[]
};

type httpd_icon = {
    "default" ? string
    "add" ? httpd_icon_add[]
    "addbytype" ? httpd_icon_add[]
    "addbyencoding" ? httpd_icon_add[]
};

type httpd_lang_add = {
    "lang" : string
    "names" : string[]
};

type httpd_lang = {
    "priority" ? string[]
    "forcepriority" ? string[]
    "default" ? string
    "add" ? httpd_lang_add[]
};

type httpd_setenvif = {
    "attribute" : string
    "regex" : string
    "variables" : string[]
    "quotes" : string = '"'
};

type httpd_env = {
    "if" ? httpd_setenvif[]
    "set" ? string{}
    "unset" ? string[]
    "pass" ? string[]
};

type httpd_ssl_nss_shared = {
    "passphrasehelper" ? string # eg /usr/sbin/nss_pcache
    "sessioncachetimeout" ? long
    "randomseed" ? string[][]
    "verifyclient" ? string with match(SELF, "^(require|none|optional|optional_no_ca)$")
    "require" ? string
    "options" ? string[]
    "requiressl" ? boolean
};

type httpd_nss_global = {
    include httpd_ssl_nss_shared
    "passphrasedialog" ? string with match(SELF,'^(builtin|file:/.*)$')
    "sessioncachesize" ? long
    "session3cachetimeout" ? long
    "renegotiation" ? boolean
    "requiresafenegotiation" ? boolean
};

type httpd_ssl_global = {
    include httpd_ssl_nss_shared
    "passphrasedialog" ? string with match(SELF,'^(builtin)$')
    "sessioncache" ? string
    "mutex" ? string with match(SELF,'^(default)$')
    "cryptodevice" ? string[]

    "certificatefile" ? string
    "certificatekeyfile" ? string
    "certificatechainfile" ? string
    "cacertificatepath" ? string
    "cacertificatefile" ? string
    "carevocationfile" ? string
    "carevocationpath" ? string

    "verifydepth" ? long
};

type httpd_ssl_nss_vhost = {
    "engine" : boolean = true
};

type httpd_nss_vhost = {
    include httpd_nss_global
    include httpd_ssl_nss_vhost

    "protocol" : httpd_nss_protocol[] = list("TLSv1.0")
    "ciphersuite" : httpd_nss_cipherstring[] = list('+rsa_3des_sha', '-rsa_des_56_sha', '+rsa_des_sha', '-rsa_null_md5', '-rsa_null_sha', '-rsa_rc2_40_md5', '+rsa_rc4_128_md5', '-rsa_rc4_128_sha', '-rsa_rc4_40_md5', '-rsa_rc4_56_sha', '-fortezza', '-fortezza_rc4_128_sha', '-fortezza_null', '-fips_des_sha', '+fips_3des_sha', '-rsa_aes_128_sha', '-rsa_aes_256_sha')

    "nickname" : string
    "eccnickname" ? string
    "certificatedatabase" : string
    "dbprefix" ? string

    "ocsp" ? boolean
    "ocspdefaultresponder" ? string
    "ocspdefaulturl" ? string
    "ocspdefaultname" ? string
};

type httpd_ssl_vhost = {
    include httpd_ssl_global
    include httpd_ssl_nss_vhost
    "protocol" : httpd_cipherstring[] = list("TLSv1")
    "ciphersuite" : httpd_cipherstring[] = list("TLSv1")
};

type httpd_directory_allowoverride = string with match(SELF,'^(All|None|Options|FileInfo|AuthConfig|Limit)$');
type httpd_acl_order = string with match(SELF, "^(allow|deny)$");

type httpd_acl = {
    "order" ? httpd_acl_order[]
    "allow" ? type_network_name[]
    "deny" ? type_network_name[]
    "allowoverride" ? httpd_directory_allowoverride[]
    "satisfy" ? string with match(SELF,"^(All|Any)$")
};

type httpd_limit_value = string with match(SELF, '^GET|POST|PUT|DELETE|CONNECT|OPTIONS|PATCH|PROPFIND|PROPPATCH|MKCOL|COPY|MOVE|LOCK|UNLOCK$');

type httpd_limit_base = {
    "name" : httpd_limit_value[]
    "except" : boolean = false
};

type httpd_proxy_passreverse = {
    "path" ? string
    "url" : string
};

type httpd_proxy_pass = {
    "match" ? boolean # match is implied when regex is set; but you can have match without regex
    "regex" ? string
    "url" ? string
    "data" ? string{}
};

type httpd_proxy_set = {
    "url" ? string
    "data" ? string{}
};

type httpd_proxy = {
    "requests" ? boolean = false
    "set" ? httpd_proxy_set
    "pass" ? httpd_proxy_pass[]
    "passreverse" ? httpd_proxy_passreverse[]
};

type httpd_proxy_directive = {
    "name" : string
    "match" : boolean = false
    "proxy" ? httpd_proxy
};

type httpd_auth_require = {
    # require type who.join(' ')
    "type" : string with match(SELF,'^(valid-user|user|group)$')
    "who" ? string[]
};

type httpd_name_virtual_host = {
    "ip" : type_ip
    "port" ? type_port
};

type httpd_auth_type = string with match(SELF,"^(Basic|Kerberos|Shibboleth)$");
type httpd_auth = {
    "name": string
    "require" : httpd_auth_require = nlist('type','valid-user')
    "userfile" ? string
    "groupfile" ? string
    "basicprovider" ? string with match(SELF,"^(file)$")
    "type" : httpd_auth_type = "Basic"
};

type httpd_file_base = {
    "name" : string
    "regex" : boolean = false # name is regex (i.e. add ~)
    "quotes" : string = '"'
    "options" ? string[] = list("-indexes")
    "enablesendfile" ? boolean
    "lang" ? httpd_lang
    "ssl" ? httpd_ssl_global
    "nss" ? httpd_nss_global
    "auth" ? httpd_auth
    "kerberos" ? httpd_kerberos
    "shibboleth" ? httpd_shibboleth
};

type httpd_rewrite_cond = {
    "test" : string
    "pattern" : string
};

type httpd_rewrite_rule = {
    "conditions" ? httpd_rewrite_cond[]
    "regexp" : string
    "destination" : string
    "flags" : string[] = list() # empty list will generate empty string ([] is invalid)
};

type httpd_rewrite_map = {
    "name" : string
    "type" : string with match(SELF, '^(txt|rnd|dbm|int|prg|dbd|fastdbd)$')
    "source" : string
};

type httpd_rewrite_option = string with match(SELF,'^(Inherit|InheritBefore|AllowNoSlash|AllowAnyURI|MergeBase)$');

type httpd_rewrite = {
    "engine" : boolean = true
    "base" ? string
    "rules" ? httpd_rewrite_rule[]
    "maps" ? httpd_rewrite_map[]
    "options" ? httpd_rewrite_option[]
};

type httpd_perl_handler = {
    "responsehandler" : string
};

type httpd_wsgi_iportscript = {
    "path" : string
    "process" ? string
    "application" ? string
};

type httpd_wsgi_vhost = {
    "importscript" ? httpd_wsgi_iportscript
    "passauthorization" ?  string with match(SELF, '^(on|off)$')
};

type httpd_listen = {
    "port" : long
    "name" ? string
    "protocol" ? string
};

type httpd_passenger = {
    "ruby" : string = "/usr/bin/ruby"
    "root" : string = "/usr/share/rubygems/gems/passenger-latest"
    "maxpoolsize" : long
};

type httpd_rails = {
    "baseuri" : string[] = list("/rails")
    "env" ? string
};

type httpd_shared = {
    "documentroot" ? string = '/does/not/exist'
    "hostnamelookups" : boolean = false
    "servername" ? type_hostport
    "limitrequestbody" ? long(0..)
};

type httpd_encoding = {
    "mime" : string
    "extensions" : string[]
};

type httpd_alias = {
    "url" : string
    "destination" : string
    "type" : string = "" with match(SELF,'^(|script|wsgiscript)$')
};

type httpd_module_name = string with match(SELF, '^[.\-/\w]+$');

type httpd_module = {
    "name" : httpd_module_name
    "path" : string
};

type httpd_handler_add = {
    # addhandler name target.join(' ')
    "name" : string
    "target" : string[]
};

type httpd_handler = {
    "set" ? string
    "add" ? httpd_handler_add[]
};

type httpd_type_add = {
    # addtype name target.join(' ')
    "name" : string
    "target" : string[]
};

type httpd_type = {
    "default" ? string
    "config" ? string
    "add" ? httpd_type_add[]
};

type httpd_outputfilter_add = {
    # addoutputfilter name target.join(' ')
    "name" : string
    "target" : string[]
};

type httpd_outputfilter = {
    "add" ? httpd_outputfilter_add[]
};

type httpd_perl_vhost = {
    "modules" : string[]
    "options" : string[] = list("+Parent")
    "switches" ? string[]
};

type httpd_browsermatch = {
    # -> browsermatch "match" names.join(' ')
    "match" : string
    "names" : string[]
};