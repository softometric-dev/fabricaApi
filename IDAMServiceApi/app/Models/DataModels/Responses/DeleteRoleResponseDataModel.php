<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class DeleteRoleResponseDataModel extends ApiResponseDataModel
{
	public $deletedRole;
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
		$deleteRoleResponseDataModel = new DeleteRoleResponseDataModel();
		if ($jsonData != null) {
			$deletedRole = $jsonData->deletedRole ?? null;
			if ($deletedRole != null) {
				$roleDataModel = RoleDataModel::fromJson($deletedRole);
				$deleteRoleResponseDataModel->deletedRole = $roleDataModel;
			}
		}
		return $deleteRoleResponseDataModel;
	}

}