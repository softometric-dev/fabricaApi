<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\AddressDataModel;

class FranchiseeDataModel extends BaseDataModel
{
    public $franchiseeId;
    public $franchiseeName;
    public $address;
    public $taxId;
    public $website;
    public $email;
    public $phone;
    public $mobile;
    public $lastModifiedDateTime;
    public $status;
    
    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $franchiseeDataModel = new self();
        
        if ($jsonData != null)
        {
            $franchiseeDataModel->franchiseeId = $jsonData->franchiseeId ?? null;
            $franchiseeDataModel->franchiseeName = $jsonData->franchiseeName ?? null;
            $franchiseeDataModel->address = isset($jsonData->address) ? AddressDataModel::fromJson($jsonData->address) : null;
            $franchiseeDataModel->taxId = $jsonData->taxId ?? null;
            $franchiseeDataModel->website = $jsonData->website ?? null;
            $franchiseeDataModel->email = $jsonData->email ?? null;
            $franchiseeDataModel->phone = $jsonData->phone ?? null;
            $franchiseeDataModel->mobile = $jsonData->mobile ?? null;
            $franchiseeDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
            $franchiseeDataModel->status = $jsonData->status ?? null;
        }
        
        return $franchiseeDataModel;
    }

    // Create instances from database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $franchisees = [];
        
        if ($dbResultSet != null)
        {
            foreach ($dbResultSet as $row)
            {
                $franchisees[] = self::fromDbResultRow($row);
            }
        }
        
        return $franchisees;
    }

    // Create an instance from a single database result row
    public static function fromDbResultRow($row)
    {
        $franchisee = null;
        
        if ($row != null)
        {
            $objRow = is_object($row) ? $row : (object)$row;
            $franchisee = new self();
            $franchisee->franchiseeId = property_exists($objRow, 'franchiseeId') ? $objRow->franchiseeId : null;
            $franchisee->franchiseeName = property_exists($objRow, 'franchiseeName') ? $objRow->franchiseeName : null;
            $franchisee->address = AddressDataModel::fromDbResultRow($objRow); // Assuming AddressDataModel::fromDbResultRow() method exists
            $franchisee->taxId = property_exists($objRow, 'taxId') ? $objRow->taxId : null;
            $franchisee->website = property_exists($objRow, 'website') ? $objRow->website : null;
            $franchisee->email = property_exists($objRow, 'email') ? $objRow->email : null;
            $franchisee->phone = property_exists($objRow, 'phone') ? $objRow->phone : null;
            $franchisee->mobile = property_exists($objRow, 'mobile') ? $objRow->mobile : null;
            $franchisee->lastModifiedDateTime = property_exists($objRow, 'lastModifiedDateTime') ? $objRow->lastModifiedDateTime : null;
            $franchisee->status = property_exists($objRow, 'status') ? $objRow->status : null;
        }
        
        return $franchisee;
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }
}
?>
