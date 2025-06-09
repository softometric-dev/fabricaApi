<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
class ForgotPasswordResponseDatamodel extends ApiResponseDataModel
{
    public $passwordForgot;
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
		$forgotPasswordResponseDatamodel = new ForgotPasswordResponseDatamodel();
		if ($jsonData != null) {
			$passwordForgot = $jsonData->passwordForgot ?? null;
			if ($passwordForgot != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($passwordForgot);
				$forgotPasswordResponseDatamodel->passwordForgot = $userProfileDataModel;
			}
		}
		return $forgotPasswordResponseDatamodel;
	}

}