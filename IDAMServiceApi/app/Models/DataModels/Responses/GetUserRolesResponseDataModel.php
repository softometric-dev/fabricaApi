<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class GetUserRolesResponseDataModel extends ApiResponseDataModel
{
	public $roles;
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
		$getUserRolesResponseDataModel = new GetUserRolesResponseDataModel();
		if ($jsonData != null) {
			$roles = $jsonData->roles ?? null;
			if ($roles != null) {
				$roleDataModel = RoleDataModel::fromJson($roles);
				$getUserRolesResponseDataModel->roles = $roleDataModel;
			}
		}
		return $getUserRolesResponseDataModel;
	}

}