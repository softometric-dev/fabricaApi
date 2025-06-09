<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class AddRolePermissionsRequestDataModel extends ApiRequestDataModel
{
	public $role;
	public $permissions = [];
	public function __construct()
	{
		parent::__construct();
	}
	public function validateAndEnrichData()
	{
		$role = $this->role;
		$permissions = $this->permissions;

		// Validate mandatory inputs
		if (
			is_null($role) ||
			is_null($permissions) ||
			is_null($role->roleId) ||
			empty(array_filter($permissions, fn($permission) => isset ($permission->permissionId)))
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'role id, permission id');
		}

		// Optional inputs and setting defaults (if any)
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addRolePermissionsRequestDataModel = new AddRolePermissionsRequestDataModel();
		if ($jsonData != null) {
			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$addRolePermissionsRequestDataModel->role = $roleDataModel;
			}

			$permissions = $jsonData->permissions ?? null;
			if ($permissions != null && count($permissions) > 0) {
				foreach ($permissions as $permission) {
					$addRolePermissionsRequestDataModel->permissions[] = PermissionDataModel::fromJson($permission);
				}
			}
		}
		return $addRolePermissionsRequestDataModel;
	}

}