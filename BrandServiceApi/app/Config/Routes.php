<?php

namespace Config;

use App\Controllers\AuthService;

// Create a new instance of our RouteCollection class.
$routes = Services::routes();

/**
 * @var RouteCollection $routes
 */
// $routes->get('/', 'Home::index');

$routes->post('BrandService/getAllCategory', 'BrandService::getAllCategory');
$routes->post('BrandService/createBrand', 'BrandService::createBrand');
$routes->post('BrandService/getBrand', 'BrandService::getBrand');
$routes->post('BrandService/updateBrand', 'BrandService::updateBrand');
$routes->post('BrandService/deleteBrand', 'BrandService::deleteBrand');
$routes->post('BrandService/searchBrand', 'BrandService::searchBrand');



if (file_exists(SYSTEMPATH . 'Config/Routes.php')) {
    require SYSTEMPATH . 'Config/Routes.php';
}

