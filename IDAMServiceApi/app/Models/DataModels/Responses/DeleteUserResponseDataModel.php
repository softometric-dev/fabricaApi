<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class DeleteUserResponseDataModel extends ApiResponseDataModel
{
	public $deletedUser;
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
		$deleteUserResponseDataModel = new DeleteUserResponseDataModel();
		if ($jsonData != null) {
			$deletedUser = $jsonData->deletedUser ?? null;
			if ($deletedUser != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($deletedUser);
				$deleteUserResponseDataModel->deletedUser = $userProfileDataModel;
			}
		}
		return $deleteUserResponseDataModel;
	}

}