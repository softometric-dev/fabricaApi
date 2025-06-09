<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;

class LoginResponseDataModel extends ApiResponseDataModel
{
    public $token;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Validate mandatory inputs
        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);

        $loginResponseDataModel = new LoginResponseDataModel();

        if ($jsonData != null) {
            $loginResponseDataModel->token = $jsonData->token ?? null;
        }

        return $loginResponseDataModel;
    }
}
