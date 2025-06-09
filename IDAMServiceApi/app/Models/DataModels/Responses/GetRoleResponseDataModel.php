<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class GetRoleResponseDataModel extends ApiResponseDataModel
{


	public $role;
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
		$getRoleResponseDataModel = new GetRoleResponseDataModel();
		if ($jsonData != null) {
			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$getRoleResponseDataModel->role = $roleDataModel;
			}
		}
		return $getRoleResponseDataModel;
	}

}