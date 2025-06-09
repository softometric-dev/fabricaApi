<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class StateDataModel extends BaseDataModel
{
    public $stateId;
    public $stateName;
    public $stateCode;
    public $countryId;
    public $lastModifiedDateTime;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Validate and enrich data (implementation can be added as needed)
    public function validateAndEnrichData()
    {
        // Validation and enrichment logic goes here
    }

    // Create an instance from a JSON string
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $stateDataModel = new self();

        if ($jsonData !== null) {
            $stateDataModel->stateId = $jsonData->stateId ?? null;
            $stateDataModel->stateName = $jsonData->stateName ?? null;
            $stateDataModel->stateCode = $jsonData->stateCode ?? null;
            $stateDataModel->countryId = $jsonData->countryId ?? null;
            $stateDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
        }

        return $stateDataModel;
    }

    // Create instances from a database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $states = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $states[] = self::fromDbResultRow($row);
            }
        }
        return $states;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $state = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object) $row;
            $state = new self();
            $state->stateId = $objRow->stateId ?? null;
            $state->stateName = $objRow->stateName ?? null;
            $state->stateCode = $objRow->stateCode ?? null;
            $state->countryId = $objRow->countryId ?? null;
            $state->lastModifiedDateTime = $objRow->lastModifiedDateTime ?? null;
        }
        return $state;
    }
}
