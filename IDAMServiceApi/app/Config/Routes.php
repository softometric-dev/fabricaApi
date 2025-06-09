<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/**
 * @var RouteCollection $routes
 */
// $routes->get('/', 'Home::index');

$routes->post('IDAMService/createUser', 'IDAMService::createUser');
$routes->post('IDAMService/registerUser', 'IDAMService::registerUser');
$routes->post('IDAMService/updateUser', 'IDAMService::updateUser');
$routes->post('IDAMService/getUser', 'IDAMService::getUser');
$routes->post('IDAMService/deleteUser', 'IDAMService::deleteUser');
$routes->post('IDAMService/searchUser', 'IDAMService::searchUser');
$routes->post('IDAMService/forgotPassword', 'IDAMService::forgotPassword');
$routes->post('IDAMService/addDealerUsers', 'IDAMService::addDealerUsers');
$routes->post('IDAMService/searchUnAssignedDealerUser', 'IDAMService::searchUnAssignedDealerUser');
$routes->post('IDAMService/verifyEmail', 'IDAMService::verifyEmail');
$routes->post('IDAMService/confirmCode', 'IDAMService::confirmCode');


if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

