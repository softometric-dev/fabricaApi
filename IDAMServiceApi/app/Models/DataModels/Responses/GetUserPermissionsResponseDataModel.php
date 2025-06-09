<?php

namespace App\Models\DataModels\Responses;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class GetUserPermissionsResponseDataModel extends ApiResponseDataModel
{
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
		$getUserPermissionsResponseDataModel = new GetUserPermissionsResponseDataModel();
		if ($jsonData != null) {
			$permissions = $jsonData->permissions ?? null;
			if ($permissions != null) {
				$permissionDataModel = PermissionDataModel::fromJson($permissions);
				$getUserPermissionsResponseDataModel->permissions = $permissionDataModel;
			}
		}
		return $getUserPermissionsResponseDataModel;
	}

}