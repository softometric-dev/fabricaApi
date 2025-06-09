<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class AddUserRolesResponseDataModel extends ApiResponseDataModel
{

	public $roles;

	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		// Validate mandatory inputs if needed
		// Optional inputs and setting defaults
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addUserRolesResponseDataModel = new AddUserRolesResponseDataModel();
		if ($jsonData != null) {
			$roles = $jsonData->roles ?? null;
			if ($roles != null) {
				$rolesDataModel = RolesDataModel::fromJson($roles);
				$addUserRolesResponseDataModel->roles = $rolesDataModel;
			}
		}
		return $addUserRolesResponseDataModel;
	}
}