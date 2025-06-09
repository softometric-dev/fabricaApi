<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;

class VerifyEmailRequestDataModel extends ApiRequestDataModel
{
    public $verifyEmail;
    public function __construct()
    {
			parent::__construct();
	}
    public function validateAndEnrichData()
	{
		$verifyEmail = $this->verifyEmail;
			//Validate mandatory inputs
		if( isNullOrEmpty($verifyEmail) ||
			isNullOrEmpty($verifyEmail->email)
			 )
			{
				throw new ParameterException(MANDATORY_PARAMETER_ERROR,'email');
			}
			//Optional inputs and setting defaults		
	}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$verifyEmailRequestDataModel = new VerifyEmailRequestDataModel();
		if ($jsonData != null) {
			$verifyEmail = $jsonData->verifyEmail ?? null;
			if ($verifyEmail != null) {
				$verifyEmailDataModel = VerifyEmailDataModel::fromJson($verifyEmail);
				$verifyEmailRequestDataModel->verifyEmail = $verifyEmailDataModel;
			}

			
		}
		return $verifyEmailRequestDataModel;
	}
}