<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/**
 * @var RouteCollection $routes
 */
// $routes->get('/', 'Home::index');

$routes->post('ProductService/createProduct', 'ProductService::createProduct');
$routes->post('ProductService/getProduct', 'ProductService::getProduct');
$routes->post('ProductService/updateProduct', 'ProductService::updateProduct');
$routes->post('ProductService/deleteProduct', 'ProductService::deleteProduct');
$routes->post('ProductService/searchProduct', 'ProductService::searchProduct');



if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

