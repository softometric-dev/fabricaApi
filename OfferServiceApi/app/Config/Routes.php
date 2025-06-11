<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/**
 * @var RouteCollection $routes
 */
// $routes->get('/', 'Home::index');

$routes->post('OfferService/createOffer', 'OfferService::createOffer');
$routes->post('OfferService/getOffer', 'OfferService::getOffer');
$routes->post('OfferService/updateOffer', 'OfferService::updateOffer');
$routes->post('OfferService/deleteOffer', 'OfferService::deleteOffer');
$routes->post('OfferService/searchOffer', 'OfferService::searchOffer');



if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

