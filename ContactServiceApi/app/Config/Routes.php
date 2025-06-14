<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/**
 * @var RouteCollection $routes
 */
// $routes->get('/', 'Home::index');

$routes->post('ContactService/createContactForm', 'ContactService::createContactForm');
$routes->post('ContactService/createDealEnquiry', 'ContactService::createDealEnquiry');
$routes->post('ContactService/createPartner', 'ContactService::createPartner');
$routes->post('ContactService/createProductEnquiry', 'ContactService::createProductEnquiry');
$routes->post('ContactService/deleteContactForm', 'ContactService::deleteContactForm');
$routes->post('ContactService/deleteDealEnquiry', 'ContactService::deleteDealEnquiry');
$routes->post('ContactService/deletePartner', 'ContactService::deletePartner');
$routes->post('ContactService/deleteProductEnquiry', 'ContactService::deleteProductEnquiry');
$routes->post('ContactService/searchContactForm', 'ContactService::searchContactForm');
$routes->post('ContactService/searchDealEnquiry', 'ContactService::searchDealEnquiry');
$routes->post('ContactService/searchPartner', 'ContactService::searchPartner');
$routes->post('ContactService/searchProductEnquiry', 'ContactService::searchProductEnquiry');



if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

