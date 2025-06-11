<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class StatusDataModel extends BaseDataModel 
{
    public $statusId;
    public $status;

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
        $statusDataModel = new self();

        if ($jsonData !== null) {
            $statusDataModel->statusId = $jsonData->statusId ?? null;
            $statusDataModel->status = $jsonData->status ?? null;
        }

        return $statusDataModel;
    }

    // Create instances from a database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $statuses = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $statuses[] = self::fromDbResultRow($row);
            }
        }
        return $statuses;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $status = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object) $row;
            $status = new self();
            $status->statusId = $objRow->statusId ?? null;
            $status->status = $objRow->status ?? null;
        }
        return $status;
    }
}
