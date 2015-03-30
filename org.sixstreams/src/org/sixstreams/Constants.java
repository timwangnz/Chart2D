package org.sixstreams;

public interface Constants {

    public static final String USERNAME = "username";
    public static final String AUTH_SOURCE = "authSource";
    public static final String DATE_TIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.sss";
    public static final String APPLICATION_ID = "X-sixstreams-application-id";
    public static final String APPLICATION_KEY = "X-sixstreams-application-key";
    public static final String SIGN_UP = "signup";
    public static final String DELETE_ACCOUNT = "delete-account";
    public static final String SIGN_IN = "signin";
    public static final String AUTHENTICATION = "Authorization";
    public static final String SECURITY_REQUEST = "X-sixstreams-security-request";
    public static final String SECURITY_REQUEST_SOURCE_KEY = "X-sixstreams-security-oauth";

    public static final String RESOURCE_DESCRIPTOR = "org.sixstreams.rest.ResourceDescripter";
    public static final String RESOURCE_NAME_FOR_API = "application";
    public static final String RESOURCE_NAME_FOR_METADATA = "definition";
    public static final String SEARCH_WILD_CARD = "*";
    public static final String PATH_SEPARATOR = "/";

    public static final String DEFAULT_FORMAT = "json";
    public static final String CONTENT_TYPE_JSON = "application/json";

    public static final String OPERATION = "op";
    public static final String SEARCH_KEYWORDS = "q";

    public static final String SEARCH_FILTERS = "filters";
    public static final String SEARCH_OPERATOR_EQ = "EQ";
    public static final String PAGE = "offset";
    public static final String PAGE_SIZE = "limit";
    public static final String ORDER_BY = "orderBy";
    public static final String SEARCH_FACETS = "facets";
    public static final String SEARCH_ELEMENT_DELIMINATOR = ";";

    public static final String NUMBER = "NUMBER";
    public static final String STRING = "String";
    public static final String LONGITUDE = "longitude";
    public static final String LATITUDE = "latitude";
    public static final String SEARCH_DISTANCE = "distance";
    public static final String SEARCH_CONTENT = "content", SEARCH_ICON = "icon";

    public static final String QMD_CACH_KEY = "QueryMetaData";
    public static final String USER_AGENT = "User-Agent";

    public static final String ACTION_CREATE = "Create";
    public static final String ACTION_UPDATE = "Update";
    public static final String ACTION_DELETE = "Delete";
    public static final String ACTION_LIST = "List";
    public static final String ACTION_UPLOAD = "Upload";
    public static final String ACTION_SECURITY = "Security";

    static final String STRING_ARRAY = "[Ljava.lang.String;";
    static final int DEFAULT_PAGE_SIZE = 10, DEFAULT_OFFSET = 0;
    static final String FACET_SUFFIX = "_s";
    static final String WILDCARD_CHAR = "*";

    static final String PRIMARY_KEY = "sixstreams_primary_key";
    static final String TITLE = "sixstreams_title";
    static final String CONTENT = "sixstreams_content";
    static final String SO_NAME = "sixstreams_so_name";
    static final String ATTR_TAGS = "tags";
    static final String ACL_KEY = "sixstreams_acl_key";

    static final String INDEXABLE_DOCUMENT_KEY = "INDEXABLE_DOCUMENT_KEY";

    static final String ACTION_TITLE = "sixstreams_action_title";

    static final String LAST_MODIFIED_DATE = "sixstreams_lst_modifed";

    static final long INVALID_ENGINE_INST_ID = -1L;

    static final String OPERATOR_CONTAINS = "CONTAINS";
    static final String OPERATOR_EQS = "EQ";
    static final String OPERATOR_GT = "GT";
    static final String OPERATOR_LT = "LT";
    static final String OPERATOR_RANGE = "RANGE";

    static final String SECURITY_DISABLED = "org.sixstreams.search.query.security.disabled";

    static final String UNDERSCORE = "_";
}
