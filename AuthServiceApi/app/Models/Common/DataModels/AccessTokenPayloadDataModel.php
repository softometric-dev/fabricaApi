<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\AuthTokenPayloadDataModel;

class AccessTokenPayloadDataModel extends AuthTokenPayloadDataModel
{
    public $azp;
    public $scope;

    public function __construct()
    {
        // If there's any initialization, add it here.
        parent::__construct();
    }

    public static function fromJson($jsonString)
    {
        // Implement the logic for converting a JSON string into an object
    }

    public function validateAndEnrichData()
    {
        // Implement the validation and enrichment logic
    }
}
