<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\StatusDataModel;

class UserBasicInfoDataModel extends BaseDataModel
{
    public $userProfileId;
    public $firstName;
    public $middleName;
    public $lastName;
    public $status;
    public $user_photo;
    public $fullName;

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
        $userBasicInfoDataModel = new self();

        if ($jsonData !== null) {
            $userBasicInfoDataModel->userProfileId = $jsonData->userProfileId ?? null;
            $userBasicInfoDataModel->firstName = $jsonData->firstName ?? null;
            $userBasicInfoDataModel->middleName = $jsonData->middleName ?? null;
            $userBasicInfoDataModel->lastName = $jsonData->lastName ?? null;
            $userBasicInfoDataModel->fullName = $jsonData->fullName ?? null;
            $userBasicInfoDataModel->user_photo = $jsonData->user_photo ?? null;
            if (isset($jsonData->status)) {
                $userBasicInfoDataModel->status = StatusDataModel::fromJson($jsonData->status);
            }
        }

        return $userBasicInfoDataModel;
    }

    // Create instances from a database result set
    public static function fromDbResultSet($dbResultSet)
    {
        $userBasicInfo = [];
        foreach ($dbResultSet as $row) {
            $userBasicInfo[] = self::fromDbResultRow($row);
        }
        return $userBasicInfo;
    }

    // Create an instance from a database result row
    public static function fromDbResultRow($row)
    {
        $userBasicInfo = null;
        if ($row !== null) {
            $objRow = is_object($row) ? $row : (object) $row;
            $userBasicInfo = new self();
            $userBasicInfo->userProfileId = $objRow->userProfileId ?? null;
            $userBasicInfo->firstName = $objRow->firstName ?? null;
            $userBasicInfo->middleName = $objRow->middleName ?? null;
            $userBasicInfo->lastName = $objRow->lastName ?? null;
            $userBasicInfo->fullName = $objRow->fullName ?? null;
            $userBasicInfo->status = StatusDataModel::fromDbResultRow($objRow);
            $userBasicInfo->user_photo = property_exists($objRow, 'user_photo') ? $objRow->user_photo : null;
        }
        return $userBasicInfo;
    }
}
