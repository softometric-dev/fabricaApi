<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\AuthTokenPayloadDataModel;

class IdTokenPayloadDataModel extends AuthTokenPayloadDataModel
{
    public $userProfileId;
    public $userType;
    public $email;
    public $firstName;
    public $middleName;
    public $lastName;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {
        // $jsonData = self::jsonDecode($jsonString);
        // $idTokenPayloadDataModel = new self();
        
        // if ($jsonData != null)
        // {
        //     $idTokenPayloadDataModel->userProfileId = $jsonData->userProfileId ?? null;
        //     $idTokenPayloadDataModel->userType = $jsonData->userType ?? null;
        //     $idTokenPayloadDataModel->email = $jsonData->email ?? null;
        //     $idTokenPayloadDataModel->firstName = $jsonData->firstName ?? null;
        //     $idTokenPayloadDataModel->middleName = $jsonData->middleName ?? null;
        //     $idTokenPayloadDataModel->lastName = $jsonData->lastName ?? null;
        // }
        
        // return $idTokenPayloadDataModel;
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }

    // // Decode JSON string
    // protected static function jsonDecode(string $jsonString)
    // {
    //     return json_decode($jsonString);
    // }
}
?>
