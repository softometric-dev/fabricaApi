<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;

class VerifyEmailResponseDataModel extends ApiResponseDataModel
{
    public $verifyEmail;
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
		$verifyEmailResponseDataModel = new VerifyEmailResponseDataModel();
		if ($jsonData != null) {
			$verifyEmail = $jsonData->verifyEmail ?? null;
			if ($verifyEmail != null) {
				$verifyEmailDataModel = VerifyEmailDataModel::fromJson($verifyEmail);
				$verifyEmailResponseDataModel->verifyEmail = $verifyEmailDataModel;
			}

		}
		return $verifyEmailResponseDataModel;
	}

}