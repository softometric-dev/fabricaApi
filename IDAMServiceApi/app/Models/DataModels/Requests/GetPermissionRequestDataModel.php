<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class GetPermissionRequestDataModel extends ApiRequestDataModel
{

    public $permission;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $permission = $this->permission;

        // Validate mandatory inputs
        if (
            is_null($permission) ||
            (is_null($permission->permissionId) && is_null($permission->permissionName))
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'permissionId or permissionName');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getPermissionRequestDataModel = new GetPermissionRequestDataModel();
        if ($jsonData != null) {
            $permission = $jsonData->permission ?? null;
            if ($permission != null) {
                $permissionDataModel = PermissionDataModel::fromJson($permission);
                $getPermissionRequestDataModel->permission = $permissionDataModel;
            }
        }
        return $getPermissionRequestDataModel;
    }

}