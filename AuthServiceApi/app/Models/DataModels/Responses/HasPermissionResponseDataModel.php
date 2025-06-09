<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\AuthInfoDataModel;

class HasPermissionResponseDataModel extends ApiResponseDataModel
{
    public $hasPermission;
    public $authInfo;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Validate mandatory inputs if needed

        // Optional inputs and setting defaults if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $hasPermissionResponseDataModel = new self();

        if ($jsonData !== null) {
            $hasPermissionResponseDataModel->hasPermission = $jsonData->hasPermission ?? null;

            if (isset($jsonData->authInfo)) {
                $authInfoDataModel = AuthInfoDataModel::fromJson($jsonData->authInfo);
                $hasPermissionResponseDataModel->authInfo = $authInfoDataModel;
            }
        }

        return $hasPermissionResponseDataModel;
    }
}
