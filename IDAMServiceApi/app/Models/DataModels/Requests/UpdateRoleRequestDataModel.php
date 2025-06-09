<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;

class UpdateRoleRequestDataModel extends ApiRequestDataModel
{
	public $userType;
	public $role;
	public $permissions;
	public function __construct()
	{
		parent::__construct();
	}
	public function validateAndEnrichData()
	{
		$role = $this->role;

		// Validate mandatory inputs
		if (empty($role) || empty($role->roleId) || empty($role->lastModifiedDateTime)) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'roleId, lastModifiedDateTime');
		}

		// Optional inputs and setting defaults        
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$updateRoleRequestDataModel = new UpdateRoleRequestDataModel();
		if ($jsonData != null) {
			$userType = $jsonData->userType ?? null;
			if ($userType != null) {
				$userTypeDataModel = UserTypeDataModel::fromJson($userType);
				$updateRoleRequestDataModel->userType = $userTypeDataModel;
			}

			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$updateRoleRequestDataModel->role = $roleDataModel;
			}

			$permissions = $jsonData->permissions ?? null;
			if ($permissions != null && count($permissions) > 0) {
				foreach ($permissions as $permission) {
					$updateRoleRequestDataModel->permissions[] = PermissionDataModel::fromJson($permission);
				}
			}
		}
		return $updateRoleRequestDataModel;
	}
}