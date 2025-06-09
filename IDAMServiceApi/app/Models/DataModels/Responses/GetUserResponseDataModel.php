<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class GetUserResponseDataModel extends ApiResponseDataModel
{
	public $user;
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
		$getUserResponseDataModel = new GetUserResponseDataModel();
		if ($jsonData != null) {
			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$getUserResponseDataModel->user = $userProfileDataModel;
			}
		}
		return $getUserResponseDataModel;
	}

}