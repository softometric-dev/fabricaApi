<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class CreatePermissionRequestDataModel extends ApiRequestDataModel
{
    public $newPermission;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $newPermission = $this->newPermission;

        // Validate mandatory inputs
        if (is_null($newPermission) || is_null($newPermission->permissionName)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'permission name');
        }

        // Optional inputs and setting defaults (if any)
    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $createPermissionRequestDataModel = new CreatePermissionRequestDataModel();
        if ($jsonData != null) {
            $newPermission = $jsonData->newPermission ?? null;
            if ($newPermission != null) {
                $permissionDataModel = PermissionDataModel::fromJson($newPermission);
                $createPermissionRequestDataModel->newPermission = $permissionDataModel;
            }
        }
        return $createPermissionRequestDataModel;
    }

}