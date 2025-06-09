<?php

namespace App\Models\Common\DataModels;

use App\Libraries\CustomException;
use App\Models\Common\DataModels\BaseDataModel;

class PermissionDataModel extends BaseDataModel
{
    public $permissionId;
    public $permissionName;
    public $permissionDescription;
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
        $permissionDataModel = new self(); // Use `self` to refer to the current class

        if ($jsonData !== null) {
            $permissionDataModel->permissionId = $jsonData->permissionId ?? null;
            $permissionDataModel->permissionName = $jsonData->permissionName ?? null;
            $permissionDataModel->permissionDescription = $jsonData->permissionDescription ?? null;
            $permissionDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
            $permissions[] = $permissionDataModel;
        }

        return $permissionDataModel;
    }

    // Create instances from database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $permissions = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $permissions[] = self::fromDbResultRow($row);
            }
        }
        return $permissions;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $permission = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $permission = new self();
            $permission->permissionId = $objRow->permissionId ?? null;
            $permission->permissionName = $objRow->permissionName ?? null;
            $permission->permissionDescription = $objRow->permissionDescription ?? null;
            $permission->lastModifiedDateTime = $objRow->lastModifiedDateTime ?? null;
        }
        return $permission;
    }
}
