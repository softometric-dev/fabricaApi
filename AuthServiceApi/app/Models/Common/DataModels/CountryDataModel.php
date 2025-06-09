<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use CodeIgniter\Database\ResultInterface; // Use CodeIgniter's result interface

class CountryDataModel extends BaseDataModel 
{
    public $countryId;
    public $countryName;
    public $countryCode;
    public $lastModifiedDateTime;

    // Constructor
    public function __construct()
    { 
        parent::__construct();
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {			
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $countryDataModel = new self(); // Use self to refer to the current class
        
        if ($jsonData != null)
        {
            $countryDataModel->countryId = $jsonData->countryId ?? null;
            $countryDataModel->countryName = $jsonData->countryName ?? null;
            $countryDataModel->countryCode = $jsonData->countryCode ?? null;
            $countryDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
        }
        
        return $countryDataModel;
    }

    // Create an array of instances from database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $countries = [];
        
        if ($dbResultSet != null)
        {
            foreach ($dbResultSet->getResultArray() as $row)
            {
                $countries[] = self::fromDbResultRow($row);
            }
        }			
        
        return $countries;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $country = null;
        
        if ($row != null)
        {
            $objRow = (object)$row;
            $country = new self();
            $country->countryId = $objRow->countryId ?? null;
            $country->countryName = $objRow->countryName ?? null;
            $country->countryCode = $objRow->countryCode ?? null;
            $country->lastModifiedDateTime = $objRow->lastModifiedDateTime ?? null;
        }
        
        return $country;
    }
}
?>
