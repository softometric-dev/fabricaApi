<?php

namespace App\Models\Common\DataModels;

use CodeIgniter\Model;

class UserTypeDataModel extends BaseDataModel
{
    public $userTypeId;
    public $userType;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic here
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $userTypeDataModel = new UserTypeDataModel();
        if ($jsonData !== null) {
            $userTypeDataModel->userTypeId = $jsonData->userTypeId ?? null;
            $userTypeDataModel->userType = $jsonData->userType ?? null;
        }
        return $userTypeDataModel;
    }

    public static function fromDbResultSet($dbResultSet)
    {
        $userTypes = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $userTypes[] = self::fromDbResultRow($row);
            }
        }
        return $userTypes;
    }

    public static function fromDbResultRow($row)
    {
        $userType = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $userType = new UserTypeDataModel();
            $userType->userTypeId = $objRow->userTypeId ?? null;
            $userType->userType = $objRow->userType ?? null;
        }
        return $userType;
    }
}
