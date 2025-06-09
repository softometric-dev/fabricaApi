<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'IDAMService/createUser' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
            ],
            'requireAll' => false
        ],
        'IDAMService/registerUser' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'IDAMService/getUser' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/deleteUser' => [
            'permissions' => [
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/createRole' => [
            'permissions' => [
                ['permissionName' => 'ROLE_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/createRoleAndAddPermissions' => [
            'permissions' => [
                ['permissionName' => 'ROLE_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/getRole' => [
            'permissions' => [
                ['permissionName' => 'ROLE_MODIFY'],
                ['permissionName' => 'ROLE_VIEW'],
                ['permissionName' => 'ROLE_DELETE']
            ],
            'requireAll' => false
        ],
        'IDAMService/deleteRole' => [
            'permissions' => [
                ['permissionName' => 'ROLE_DELETE']
            ],
            'requireAll' => false
        ],
        'IDAMService/getRolePermissions' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_VIEW'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/getUserPermissions' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/searchUser' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_VIEW'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/getAllUserTypes' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/getAllStatus' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/searchRole' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_VIEW'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/searchPermission' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/addUserRoles' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/getUserStatistics' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_VIEW'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/getAllUserRoles' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
                ['permissionName' => 'USER_VIEW'],
                ['permissionName' => 'USER_DELETE'],
            ],
            'requireAll' => false
        ],
        'IDAMService/searchUserAuditLog' => [
            'permissions' => [
                ['permissionName' => 'USER_STATUS_ALERT_VIEW']
            ],
            'requireAll' => false
        ],
        'IDAMService/updateUser' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
            ],
            'requireAll' => false
        ],
        'IDAMService/updateRole' => [
            'permissions' => [
                ['permissionName' => 'ROLE_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/updateUserWithPhoto' => [
            'permissions' => [
                ['permissionName' => 'USER_MODIFY'],
            ],
            'requireAll' => false
        ],
        'IDAMService/ResetPassword' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/passwordResetRequest' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/forgotPassword' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/addDealerUsers' => [
            'permissions' => [
                ['permissionName' => 'DEALER_USER_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/searchUnAssignedDealerUser' => [
            'permissions' => [
                ['permissionName' => 'DEALER_USER_VIEW'],
                ['permissionName' => 'DEALER_USER_MODIFY']
            ],
            'requireAll' => false
        ],
        'IDAMService/verifyEmail' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        'IDAMService/confirmCode' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN']
            ],
            'requireAll' => false
        ],
        
        // Add more routes and permissions here as needed
    ];
}