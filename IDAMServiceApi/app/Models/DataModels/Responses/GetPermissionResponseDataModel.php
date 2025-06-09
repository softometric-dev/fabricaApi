<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class GetPermissionResponseDataModel extends ApiResponseDataModel
{
	public $permission;
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
		$getPermissionResponseDataModel = new GetPermissionResponseDataModel();
		if ($jsonData != null) {
			$permission = $jsonData->permission ?? null;
			if ($permission != null) {
				$permissionDataModel = PermissionDataModel::fromJson($permission);
				$getPermissionResponseDataModel->permission = $permissionDataModel;
			}
		}
		return $getPermissionResponseDataModel;
	}

}