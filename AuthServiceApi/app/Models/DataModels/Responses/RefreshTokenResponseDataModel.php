<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;

class RefreshTokenResponseDataModel extends ApiResponseDataModel
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
        $refreshTokenResponseDataModel = new self();

        if ($jsonData != null) {
            $refreshTokenResponseDataModel->token = $jsonData->token ?? null;
        }

        return $refreshTokenResponseDataModel;
    }
}
