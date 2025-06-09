<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class GetRoleRequestDataModel extends ApiRequestDataModel
{
    public $role;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $role = $this->role;

        // Validate mandatory inputs
        if (
            is_null($role) ||
            (is_null($role->roleId) && is_null($role->roleName))
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'roleId or roleName');
        }

        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getRoleRequestDataModel = new GetRoleRequestDataModel();
        if ($jsonData != null) {
            $role = $jsonData->role ?? null;
            if ($role != null) {
                $roleDataModel = RoleDataModel::fromJson($role);
                $getRoleRequestDataModel->role = $roleDataModel;
            }
        }
        return $getRoleRequestDataModel;
    }
}