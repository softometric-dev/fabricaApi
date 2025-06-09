<?php

namespace App\Models\Common\DataModels;


use App\Libraries\{
    JsonException
};

abstract class BaseDataModel
{
    // Constructor
    public function __construct()
    {
        // Initialization if needed
    }

    // Abstract methods
    abstract public static function fromJson($jsonString);
    abstract public function validateAndEnrichData();

    // Convert the object to JSON
    public function toJson()
    {
        return json_encode($this);
    }

    // Decode JSON string to object
    public static function jsonDecode($jsonString)
    {
        
        $object = $jsonString;
       
      
        if (is_object($jsonString)) {
           
            // No need to decode, it is already an object
            $object = $jsonString;
        } else {
           
            $object = json_decode($jsonString);
            
            $lastError = json_last_error();
            if ($lastError !== JSON_ERROR_NONE) {
                // Throw the custom JsonException
                throw new JsonException('JSON decoding error: ' . json_last_error_msg(), $lastError);
            }
        }
       
        return $object;
    }
}
