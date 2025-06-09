<?php

namespace App\Models\DataModels\Requests;

use App\Libraries\CustomExceptionHandler\ParameterException;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;

class RefreshTokenRequestDataModel extends ApiRequestDataModel
{
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Validate mandatory inputs
        // Add validation logic if required

        // Optional inputs and setting defaults
        // Implement if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData =  BaseDataModel::jsonDecode($jsonString);
			$refreshTokenRequestDataModel = new RefreshTokenRequestDataModel();
			if($jsonData != null)
			{
				
			}	
            
			return $refreshTokenRequestDataModel;

        
    }
}
