<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Psr\Log\LoggerInterface;
use App\Libraries\{
    AuthorisationException,
    ApiCallException,
    AuthenticationException
};
use App\Models\AuthServiceApi\AuthServiceApiProxy_model;
use Config\Services;
use Config\RoutePermissions; 
class BaseController extends Controller
{
    protected $authServiceApiProxyModel;
    protected $route_permissions;

    public function __construct()
    {
        error_reporting(E_ALL);
        header('Content-Type: application/json');

        // Initialize the AuthServiceApiProxyModel
        $this->authServiceApiProxyModel = new AuthServiceApiProxy_model();

         // Load route permissions config
         $routePermissionsConfig = new RoutePermissions(); // Instantiate the RoutePermissions config class
         $this->route_permissions = $routePermissionsConfig->route_permissions;

        

        // Set the language to English
        Services::language()->setLocale('en'); // Assuming 'en' is the language code for English
    }

    protected function checkPermission()
    {
       
        $hasPermission = false;
        $authInfo = null;
        $route = $this->request->uri->getPath();

        if (array_key_exists($route, $this->route_permissions)) 
        {
            $route_config = $this->route_permissions[$route];
            $required_permissions = $route_config['permissions'];
            $requireAll = isset($route_config['requireAll']) ? $route_config['requireAll'] : false;

            $response = $this->authServiceApiProxyModel->hasPermission($required_permissions, $requireAll);
            $hasPermission = $response->hasPermission;
            $authInfo = $response->authInfo;
        }

        if (!$hasPermission || $authInfo == null) 
        {
            throw new AuthorisationException(INSUFFCIENT_PRIVILEGES);
        }

        return $authInfo;
    }

    protected function sendErrorResponse($response, $e)
    {
       
        $response->setErrorDetails($e);
        $exceptionClassName = get_class($e);

        
        switch ($exceptionClassName) 
        {
            case ApiCallException::class:
                $response->setAdditionalErrorDetails($e->getApiException());
                $httpStatusCode = $e->getHttpStatusCode();
                break;
            case AuthorisationException::class:
                $httpStatusCode = 403;
                break;
            case AuthenticationException::class:
                $httpStatusCode = 401;
                break;
            default:
                $httpStatusCode = 500;
        }
      
        $response->success = false;
       
       $this->sendResponse($httpStatusCode, $response);
    }

    protected function sendSuccessResponse($response, $httpStatus = 200)
    {
        $response->success = true;
        $this->sendResponse($httpStatus, $response);
    }
    
    protected function sendResponse($status,$response)
	{  
      
        $this->response->setStatusCode($status)->setJSON($response->toJson())->send();
		// header('Content-Type: application/json');
		// $this->output->set_status_header($status)->set_output($response->toJson());
	}
   
}
