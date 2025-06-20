<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'ProductService/createProduct' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
             'ProductService/getProduct' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
       
             'ProductService/updateProduct' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
       
             'ProductService/deleteProduct' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
       
             'ProductService/searchProduct' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'ProductService/getDashboardStatitics' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
       
       
        
        // Add more routes and permissions here as needed
    ];
}