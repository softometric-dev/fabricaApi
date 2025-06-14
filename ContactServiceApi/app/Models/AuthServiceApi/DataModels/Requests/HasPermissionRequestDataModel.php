<?php

namespace App\Models\AuthServiceApi\DataModels\Requests;

use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class HasPermissionRequestDataModel extends ApiRequestDataModel
{
    public $permissions = [];
    public $requireAll;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $permissions = $this->permissions;

        // Validate mandatory inputs
        if (empty($permissions) ||
            (empty(array_column($permissions, 'permissionId')) &&
             empty(array_column($permissions, 'permissionName')))) 
        {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'permissionId or permissionName');
        }

        // Optional inputs and setting defaults
        $this->requireAll = $this->requireAll ?? true;
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $hasPermissionRequestDataModel = new HasPermissionRequestDataModel();

        if ($jsonData !== null) {
            $permissions = $jsonData->permissions ?? null;
            if (!empty($permissions)) {
                foreach ($permissions as $permission) {
                    $hasPermissionRequestDataModel->permissions[] = PermissionDataModel::fromJson($permission);
                }
            }
           
            $hasPermissionRequestDataModel->requireAll = $jsonData->requireAll ?? null;
        }

        return $hasPermissionRequestDataModel;
    }
}
