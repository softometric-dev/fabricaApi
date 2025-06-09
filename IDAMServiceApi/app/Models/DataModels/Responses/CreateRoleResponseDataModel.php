<?php

namespace App\Models\DataModels\Responses;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class CreateRoleResponseDataModel extends ApiResponseDataModel
{
	public $newRole;
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
		$createRoleResponseDataModel = new CreateRoleResponseDataModel();
		if ($jsonData != null) {
			$newRole = $jsonData->newRole ?? null;
			if ($newRole != null) {
				$roleDataModel = RoleDataModel::fromJson($newRole);
				$createRoleResponseDataModel->newRole = $roleDataModel;
			}
		}
		return $createRoleResponseDataModel;
	}

}