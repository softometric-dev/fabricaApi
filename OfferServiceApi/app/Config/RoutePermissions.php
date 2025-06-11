<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class RoutePermissions extends BaseConfig
{
    public $route_permissions = [
        'OfferService/createOffer' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'OfferService/getOffer' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'OfferService/updateOffer' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'OfferService/deleteOffer' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
        'OfferService/searchOffer' => [
            'permissions' => [
                ['permissionName' => 'APP_LOGIN'],
            ],
            'requireAll' => false
        ],
     
     
        // Add more routes and permissions here as needed
    ];
}