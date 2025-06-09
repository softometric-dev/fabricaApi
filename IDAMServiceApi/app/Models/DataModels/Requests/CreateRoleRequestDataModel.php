<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;

class CreateRoleRequestDataModel extends ApiRequestDataModel
{
    public $userType;
    public $newRole;
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $userType = $this->userType;
        $newRole = $this->newRole;

        // Validate mandatory inputs
        if (
            is_null($newRole) ||
            is_null($userType) ||
            empty($newRole->roleName) ||
            empty($userType->userTypeId)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'user Type Id, role name');
        }

        // Optional inputs and setting defaults (if any)
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $createRoleRequestDataModel = new CreateRoleRequestDataModel();
        if ($jsonData != null) {
            $userType = $jsonData->userType ?? null;
            if ($userType != null) {
                $userTypeDataModel = UserTypeDataModel::fromJson($userType);
                $createRoleRequestDataModel->userType = $userTypeDataModel;
            }

            $newRole = $jsonData->newRole ?? null;
            if ($newRole != null) {
                $roleDataModel = RoleDataModel::fromJson($newRole);
                $createRoleRequestDataModel->newRole = $roleDataModel;
            }
        }
        return $createRoleRequestDataModel;
    }


}