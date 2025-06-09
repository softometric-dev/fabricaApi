<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'BrandService/getAllCategory' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
          'BrandService/createBrand' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
          'BrandService/getBrand' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
          'BrandService/updateBrand' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
          'BrandService/deleteBrand' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
          'BrandService/searchBrand' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
       
        
        // Add more routes and permissions here as needed
    ];
}