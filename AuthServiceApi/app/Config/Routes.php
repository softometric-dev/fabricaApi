<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/*
 * --------------------------------------------------------------------
 * Router Setup
 * --------------------------------------------------------------------
 */
// $routes->setDefaultNamespace('App\Controllers');
// $routes->setDefaultController('AuthService');
// $routes->setDefaultMethod('index');
// $routes->setTranslateURIDashes(false);
// $routes->set404Override();
// $routes->setAutoRoute(true);

$routes->post('login', 'AuthService::login');
// $routes->post('hasPermission', 'AuthService::hasPermission');
$routes->post('hasPermission', 'AuthService::hasPermission', ['filter' => 'apiaccess']);
/*
 * --------------------------------------------------------------------
 * Route Definitions
 * --------------------------------------------------------------------
 */

$routes->post('AuthService/ImpersonateUser', 'AuthService::impersonateUser');
$routes->post('AuthService/refreshToken', 'AuthService::refreshToken');

/*
 * --------------------------------------------------------------------
 * Additional Routing
 * --------------------------------------------------------------------
 */

if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}
