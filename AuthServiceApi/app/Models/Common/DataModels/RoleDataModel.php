<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;

class RoleDataModel extends BaseDataModel
{
    public $roleId;
    public $roleName;
    public $roleDescription;
    public $lastModifiedDateTime;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add your validation and enrichment logic here if needed
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $roleDataModel = new self();

        if ($jsonData !== null) {
            $roleDataModel->roleId = $jsonData->roleId ?? null;
            $roleDataModel->roleName = $jsonData->roleName ?? null;
            $roleDataModel->roleDescription = $jsonData->roleDescription ?? null;
            $roleDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
        }

        return $roleDataModel;
    }

    // Create instances from a database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $roles = [];
        if ($dbResultSet !== null) {
            foreach ($dbResultSet as $row) {
                $roles[] = self::fromDbResultRow($row);
            }
        }
        return $roles;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $role = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object) $row;
            $role = new self();
            $role->roleId = $objRow->roleId ?? null;
            $role->roleName = $objRow->roleName ?? null;
            $role->roleDescription = $objRow->roleDescription ?? null;
            $role->lastModifiedDateTime = $objRow->lastModifiedDateTime ?? null;
        }
        return $role;
    }
}
