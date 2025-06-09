<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;


class CreateUserResponseDataModel extends ApiResponseDataModel
{
	public $newUser;
	public $role;
	public $confirmCode;
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
		$createUserResponseDataModel = new CreateUserResponseDataModel();
		if ($jsonData != null) {
			$newUser = $jsonData->newUser ?? null;
			if ($newUser != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($newUser);
				$createUserResponseDataModel->newUser = $userProfileDataModel;
			}

			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$createUserResponseDataModel->role = $roleDataModel;
			}
			$confirmCode = $jsonData->confirmCode ?? null;
			if ($confirmCode != null) {
				$verifyEmailDataModel = VerifyEmailDataModel::fromJson($confirmCode);
				$createUserResponseDataModel->confirmCode = $verifyEmailDataModel;
			}

		}
		return $createUserResponseDataModel;
	}

}