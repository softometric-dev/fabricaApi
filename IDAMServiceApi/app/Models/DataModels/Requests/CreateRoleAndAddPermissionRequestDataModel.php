<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;

class CreateRoleAndAddPermissionRequestDataModel extends ApiRequestDataModel
{
    public $userType;
    public $newRole;
    public $permissions = [];

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $userType = $this->userType;
        $newRole = $this->newRole;
        $permissions = $this->permissions;

        // Validate mandatory inputs
        if (
            is_null($newRole) ||
            is_null($permissions) ||
            is_null($userType) ||
            is_null($userType->userTypeId) ||
            is_null($newRole->roleName) ||
            empty($permissions) ||
            array_filter($permissions, fn($p) => is_null($p->permissionId)) !== []
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'user type, role name, permission Ids');
        }

        // Optional inputs and setting defaults (if any)
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $createRoleAndAddPermissionRequestDataModel = new CreateRoleAndAddPermissionRequestDataModel();
        if ($jsonData != null) {
            $userType = $jsonData->userType ?? null;
            if ($userType != null) {
                $userTypeDataModel = UserTypeDataModel::fromJson($userType);
                $createRoleAndAddPermissionRequestDataModel->userType = $userTypeDataModel;
            }

            $newRole = $jsonData->newRole ?? null;
            if ($newRole != null) {
                $roleDataModel = RoleDataModel::fromJson($newRole);
                $createRoleAndAddPermissionRequestDataModel->newRole = $roleDataModel;
            }

            $permissions = $jsonData->permissions ?? null;
            if ($permissions != null && count($permissions) > 0) {
                foreach ($permissions as $permission) {
                    $createRoleAndAddPermissionRequestDataModel->permissions[] = PermissionDataModel::fromJson($permission);
                }
            }
        }
        return $createRoleAndAddPermissionRequestDataModel;
    }
}