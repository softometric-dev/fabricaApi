<?php

/*
 | --------------------------------------------------------------------
 | App Namespace
 | --------------------------------------------------------------------
 |
 | This defines the default Namespace that is used throughout
 | CodeIgniter to refer to the Application directory. Change
 | this constant to change the namespace that all application
 | classes should use.
 |
 | NOTE: changing this will require manually modifying the
 | existing namespaces of App\* namespaced-classes.
 */
defined('APP_NAMESPACE') || define('APP_NAMESPACE', 'App');

/*
 | --------------------------------------------------------------------------
 | Composer Path
 | --------------------------------------------------------------------------
 |
 | The path that Composer's autoload file is expected to live. By default,
 | the vendor folder is in the Root directory, but you can customize that here.
 */
defined('COMPOSER_PATH') || define('COMPOSER_PATH', ROOTPATH . 'vendor/autoload.php');

/*
 |--------------------------------------------------------------------------
 | Timing Constants
 |--------------------------------------------------------------------------
 |
 | Provide simple ways to work with the myriad of PHP functions that
 | require information to be in seconds.
 */
defined('SECOND') || define('SECOND', 1);
defined('MINUTE') || define('MINUTE', 60);
defined('HOUR')   || define('HOUR', 3600);
defined('DAY')    || define('DAY', 86400);
defined('WEEK')   || define('WEEK', 604800);
defined('MONTH')  || define('MONTH', 2_592_000);
defined('YEAR')   || define('YEAR', 31_536_000);
defined('DECADE') || define('DECADE', 315_360_000);

/*
 | --------------------------------------------------------------------------
 | Exit Status Codes
 | --------------------------------------------------------------------------
 |
 | Used to indicate the conditions under which the script is exit()ing.
 | While there is no universal standard for error codes, there are some
 | broad conventions.  Three such conventions are mentioned below, for
 | those who wish to make use of them.  The CodeIgniter defaults were
 | chosen for the least overlap with these conventions, while still
 | leaving room for others to be defined in future versions and user
 | applications.
 |
 | The three main conventions used for determining exit status codes
 | are as follows:
 |
 |    Standard C/C++ Library (stdlibc):
 |       http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
 |       (This link also contains other GNU-specific conventions)
 |    BSD sysexits.h:
 |       http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
 |    Bash scripting:
 |       http://tldp.org/LDP/abs/html/exitcodes.html
 |
 */
defined('EXIT_SUCCESS')        || define('EXIT_SUCCESS', 0);        // no errors
defined('EXIT_ERROR')          || define('EXIT_ERROR', 1);          // generic error
defined('EXIT_CONFIG')         || define('EXIT_CONFIG', 3);         // configuration error
defined('EXIT_UNKNOWN_FILE')   || define('EXIT_UNKNOWN_FILE', 4);   // file not found
defined('EXIT_UNKNOWN_CLASS')  || define('EXIT_UNKNOWN_CLASS', 5);  // unknown class
defined('EXIT_UNKNOWN_METHOD') || define('EXIT_UNKNOWN_METHOD', 6); // unknown class member
defined('EXIT_USER_INPUT')     || define('EXIT_USER_INPUT', 7);     // invalid user input
defined('EXIT_DATABASE')       || define('EXIT_DATABASE', 8);       // database error
defined('EXIT__AUTO_MIN')      || define('EXIT__AUTO_MIN', 9);      // lowest automatically-assigned error code
defined('EXIT__AUTO_MAX')      || define('EXIT__AUTO_MAX', 125);    // highest automatically-assigned error code

define('STATUS_ACTIVE',1);
define('STATUS_INACTIVE',2);
define('STATUS_DISABLED',3);
define('STATUS_DELETED',4);

define('SUCCESS_STATUS',0);
define('ERROR_STATUS',1);

const ERROR_MSG_PARAMETERS_EMPTY = "empty parameres";
//Permissions
define('APP_LOGIN','APP_LOGIN');
define('PERMISSION_MODIFY','PERMISSION_MODIFY');
define('PERMISSION_VIEW','PERMISSION_VIEW');
define('PERMISSION_DELETE','PERMISSION_DELETE');
define('CORPORATE_ROLE_MODIFY','CORPORATE_ROLE_MODIFY');
define('CORPORATE_ROLE_VIEW','CORPORATE_ROLE_VIEW');
define('CORPORATE_ROLE_DELETE','CORPORATE_ROLE_DELETE');
define('FRANCHISEE_ROLE_MODIFY','FRANCHISEE_ROLE_MODIFY');
define('FRANCHISEE_ROLE_VIEW','FRANCHISEE_ROLE_VIEW');
define('FRANCHISEE_ROLE_DELETE','FRANCHISEE_ROLE_DELETE');
define('CORPORATE_USER_MODIFY','CORPORATE_USER_MODIFY');
define('CORPORATE_USER_VIEW','CORPORATE_USER_VIEW');
define('CORPORATE_USER_DELETE','CORPORATE_USER_DELETE');
define('FRANCHISEE_USER_MODIFY','FRANCHISEE_USER_MODIFY');
define('FRANCHISEE_USER_VIEW','FRANCHISEE_USER_VIEW');
define('FRANCHISEE_USER_DELETE','FRANCHISEE_USER_DELETE');
define('FRANCHISEE_MODIFY','FRANCHISEE_MODIFY');
define('FRANCHISEE_VIEW','FRANCHISEE_VIEW');
define('FRANCHISEE_DELETE','FRANCHISEE_DELETE');
define('RESOURCE_MODIFY','RESOURCE_MODIFY');
define('RESOURCE_VIEW','RESOURCE_VIEW');
define('RESOURCE_DELETE','RESOURCE_DELETE');

//Error codes


//Error code E_1000 - E_1999 client errors
define('AUTH_HEADER_NOT_FOUND_ERROR','E_1000');
define('EMPTY_TOKEN_ERROR','E_1001');
define('TOKEN_FORBIDDEN_ERROR','E_1002');
define('TOEKN_EXPIRY_NOT_DEFINED_ERROR','E_1003');
define('TOKEN_EXPIRED','E_1004');
define('TOKEN_VALIDATION_ERROR','E_1005');
define('MANDATORY_PARAMETER_ERROR','E_1006');
define('INVALID_CREDENTIALS_ERROR','E_1007');
define('INSUFFCIENT_PRIVILEGES','E_1008');
define('CONFLICTING_VALUE','E_1009');
define('ACCOUNT_DISABLED_ERROR','E_1010');
define('INVALID_VERIFICATION_CODE_ERROR','E_1011');
define('INVALID_USER_ERROR','E_1012');
define('PASSWORD_INCORRECT_ERROR','E_1013');
define('PARAMETER_VALIDATION_ERROR','E_1014');


//Error code E_2000 - E_2999 API errors
define('GENERIC_ERROR','E_2000');
define('FILE_SYSTEM_ERROR','E_2001');
define('FILE_ALREADY_EXIST','E_2002');
define('FILE_NOT_EXIST','E_2003');
define('FOLDER_ALREADY_EXIST','E_2004');
define('FOLDER_NOT_EXIST','E_2005');

//Error code E_3000 - E_3999 Database errors
define('DB_ERROR','E_3000');
define('DB_DUPLICATE_RECORD','E_3001');
define('DB_RECORD_NOT_FOUND','E_3002');

