<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'ContactService/createContactForm' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],

           'ContactService/createDealEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/createPartner' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/createProductEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/deleteContactForm' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/deleteDealEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/deletePartner' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/deleteProductEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
           'ContactService/searchContactForm' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],

            'ContactService/searchDealEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
            'ContactService/searchPartner' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
            'ContactService/searchProductEnquiry' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        
     
        // Add more routes and permissions here as needed
    ];
}