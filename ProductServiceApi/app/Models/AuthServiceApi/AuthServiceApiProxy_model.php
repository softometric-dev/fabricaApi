<?php

namespace App\Models\AuthServiceApi;

use App\Models\Common\ApiBaseProxy_model;
use App\Models\Common\DataModels\PermissionDataModel;
use App\Models\AuthServiceApi\DataModels\Requests\HasPermissionRequestDataModel;
use App\Models\AuthServiceApi\DataModels\Responses\HasPermissionResponseDataModel;

class AuthServiceApiProxy_model extends ApiBaseProxy_model
{
    public function __construct()
    {
        // Call the parent constructor with the base URL from the config
        parent::__construct(config('App')->authServiceApiBaseUrl);
    }

    public function hasPermission($requiredPermissions, $requireAll)
    {
     
        $hasPermissionRequestDataModel = new HasPermissionRequestDataModel();
        $hasPermissionRequestDataModel->permissions = $requiredPermissions;
        $hasPermissionRequestDataModel->requireAll = $requireAll;
         	
            
        $hasPermissionAction = config('App')->authServiceApiHasPermissionAction;

      
        $responseJsonData = $this->invokeApi($hasPermissionAction, $hasPermissionRequestDataModel->toJson());

      
        $hasPermissionResponseDataModel = HasPermissionResponseDataModel::fromJson($responseJsonData);
      
		return $hasPermissionResponseDataModel;
    }
}
