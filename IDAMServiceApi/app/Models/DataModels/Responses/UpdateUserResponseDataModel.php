<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class UpdateUserResponseDataModel extends ApiResponseDataModel
{
	public $user;
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
		$updateUserResponseDataModel = new UpdateUserResponseDataModel();
		if ($jsonData != null) {
			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$updateUserResponseDataModel->user = $userProfileDataModel;
			}

			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$updateUserResponseDataModel->role = $roleDataModel;
			}
		}
		return $updateUserResponseDataModel;
	}

}