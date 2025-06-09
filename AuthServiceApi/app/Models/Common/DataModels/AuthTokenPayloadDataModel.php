<?php

namespace App\Models\Common\DataModels;

use CodeIgniter\Model;

class AuthTokenPayloadDataModel extends BaseDataModel
{
    public $iss;
    public $sub;
    public $aud;
    public $iat;
    public $exp;

    // Constructor
    public function __construct()
    {
        // Initialization if needed
        parent::__construct();
    }

    // Static method to create an instance from a JSON string
    public static function fromJson($jsonString)
    {
        // Use the custom jsonDecode method from BaseDataModel
        // $jsonData = self::jsonDecode($jsonString);

        // // Create an instance of AuthTokenPayloadDataModel
        // $authTokenPayloadDataModel = new self();

        // if ($jsonData !== null) {
        //     // Set properties based on JSON data
        //     $authTokenPayloadDataModel->iss = isset($jsonData->iss) ? $jsonData->iss : null;
        //     $authTokenPayloadDataModel->sub = isset($jsonData->sub) ? $jsonData->sub : null;
        //     $authTokenPayloadDataModel->aud = isset($jsonData->aud) ? $jsonData->aud : null;
        //     $authTokenPayloadDataModel->iat = isset($jsonData->iat) ? $jsonData->iat : null;
        //     $authTokenPayloadDataModel->exp = isset($jsonData->exp) ? $jsonData->exp : null;
        // }

        // return $authTokenPayloadDataModel;
    }

    // Example of a method for validation and enrichment
    public function validateAndEnrichData()
    {
        // Implement validation and enrichment logic if needed
    }
}
