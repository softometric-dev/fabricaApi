<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;

class AddressDataModel extends BaseDataModel
{
    public $addressLine1;
    public $addressLine2;
    public $country;
    public $state;
    public $zipOrPostCode;

    // Constructor
    public function __construct()
    {
        parent::__construct(); // Call the parent constructor if needed
    }

    public function validateAndEnrichData()
    {
        // Implement validation and enrichment logic
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $addressDataModel = new AddressDataModel();

        if ($jsonData != null) {
            $addressDataModel->addressLine1 = $jsonData->addressLine1 ?? null;
            $addressDataModel->addressLine2 = $jsonData->addressLine2 ?? null;

            if (isset($jsonData->country)) {
                $addressDataModel->country = CountryDataModel::fromJson($jsonData->country);
            }

            if (isset($jsonData->state)) {
                $addressDataModel->state = StateDataModel::fromJson($jsonData->state);
            }

            $addressDataModel->zipOrPostCode = $jsonData->zipOrPostCode ?? null;
        }

        return $addressDataModel;
    }

    public static function fromDbResultSet($dbResultSet)
    {
        $address = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $address[] = AddressDataModel::fromDbResultRow($row);
            }
        }

        return $address;
    }

    public static function fromDbResultRow($row)
    {
        $address = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object) $row;
            $address = new AddressDataModel();

            $address->addressLine1 = property_exists($objRow, 'addressLine1') ? $objRow->addressLine1 : null;
            $address->addressLine2 = property_exists($objRow, 'addressLine2') ? $objRow->addressLine2 : null;
            $address->country = CountryDataModel::fromDbResultRow($objRow);
            $address->state = StateDataModel::fromDbResultRow($objRow);
            $address->zipOrPostCode = property_exists($objRow, 'zipOrPostCode') ? $objRow->zipOrPostCode : null;
        }

        return $address;
    }
}
