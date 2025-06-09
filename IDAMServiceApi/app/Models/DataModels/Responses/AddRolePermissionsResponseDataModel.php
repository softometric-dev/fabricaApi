<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class AddRolePermissionsResponseDataModel extends ApiResponseDataModel
{
	public $role;
	public $permissions;
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		//Validate mandatory inputs

		//Optional inputs and setting defaults			

	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addRolePermissionsResponseDataModel = new AddRolePermissionsResponseDataModel();
		if ($jsonData != null) {
			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$addRolePermissionsResponseDataModel->role = $roleDataModel;
			}

			$permissions = $jsonData->permissions ?? null;
			if ($permissions != null) {
				$permissionDataModel = PermissionDataModel::fromJson($permissions);
				$addRolePermissionsResponseDataModel->permissions = $permissionDataModel;
			}
		}
		return $addRolePermissionsResponseDataModel;
	}
}
