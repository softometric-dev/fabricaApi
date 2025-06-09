<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use Exception;

class AuthInfoDataModel extends BaseDataModel
{
    public $payload;
    public $remoteAddress;

    public function __construct()
    {
        parent::__construct();  // Ensure parent constructor is called if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);  // Call custom jsonDecode from BaseDataModel

        $authInfoDataModel = new self();

        if ($jsonData !== null) {
            $authInfoDataModel->payload = isset($jsonData->payload) ? $jsonData->payload : null;
            $authInfoDataModel->remoteAddress = isset($jsonData->remoteAddress) ? $jsonData->remoteAddress : null;
        }

        return $authInfoDataModel;
    }

    public function validateAndEnrichData()
    {
        // Implement validation and enrichment logic if needed
    }

    public function getUserProfileId()
    {
        return isset($this->payload->sub) ? explode(",", $this->payload->sub)[0] : null;
    }

    public function getUserType()
    {
        return isset($this->payload->sub) ? explode(",", $this->payload->sub)[1] : null;
    }
}
