<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class CreateRoleAndAddPermissionResponseDataModel extends ApiResponseDataModel
{
	public $newRole;
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
		$createRoleAndAddPermissionResponseDataModel = new CreateRoleAndAddPermissionResponseDataModel();
		if ($jsonData != null) {
			$newRole = $jsonData->newRole ?? null;
			if ($newRole != null) {
				$roleDataModel = RoleDataModel::fromJson($newRole);
				$createRoleAndAddPermissionResponseDataModel->newRole = $roleDataModel;
			}

			$permissions = $jsonData->permissions ?? null;
			if ($permissions != null) {
				$permissionDataModel = PermissionDataModel::fromJson($permissions);
				$createRoleAndAddPermissionResponseDataModel->permissions = $permissionDataModel;
			}
		}
		return $createRoleAndAddPermissionResponseDataModel;
	}

}