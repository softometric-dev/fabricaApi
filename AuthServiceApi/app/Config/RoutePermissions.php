<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'AuthService/ImpersonateUser' => [
            'permissions' => [
                ['permissionName' => 'IMPERSONATE_USER']
            ],
            'requireAll' => false
        ],
        // Add more routes and permissions here as needed
    ];
}
