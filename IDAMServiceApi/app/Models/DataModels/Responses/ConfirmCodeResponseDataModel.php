<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;

class ConfirmCodeResponseDataModel extends ApiResponseDataModel
{
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
		$confirmCodeResponseDataModel = new ConfirmCodeResponseDataModel();
		if ($jsonData != null) {
			$confirmCode = $jsonData->confirmCode ?? null;
			if ($confirmCode != null) {
				$verifyEmailDataModel = VerifyEmailDataModel::fromJson($confirmCode);
				$confirmCodeResponseDataModel->confirmCode = $verifyEmailDataModel;
			}
		}
		return $confirmCodeResponseDataModel;
	}
}