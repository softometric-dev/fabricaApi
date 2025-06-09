<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class DeletePermissionResponseDataModel extends ApiResponseDataModel
{
	public $deletedPermission;
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
		$deletePermissionResponseDataModel = new DeletePermissionResponseDataModel();
		if ($jsonData != null) {
			$deletedPermission = $jsonData->deletedPermission ?? null;
			if ($deletedPermission != null) {
				$permissionDataModel = PermissionDataModel::fromJson($deletedPermission);
				$deletePermissionResponseDataModel->deletedPermission = $permissionDataModel;
			}
		}
		return $deletePermissionResponseDataModel;
	}

}