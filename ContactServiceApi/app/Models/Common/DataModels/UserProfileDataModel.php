<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\AddressDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;
use App\Models\Common\DataModels\StatusDataModel;
use App\Models\Common\DataModels\UserBasicInfoDataModel;

class UserProfileDataModel extends UserBasicInfoDataModel
{
    public $dateOfBirth;
    public $address;
    public $email;
    public $phone;
    public $mobile;
    public $password;
    public $userType;
    public $roles;
    public $lastModifiedDateTime;
    public $user_photo;
    public $totalPoint;
    public $pointPercentage;
    public $ipAddress;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Add your validation and enrichment logic here
    }

    public static function fromJson($jsonString)
    {
        
        $jsonData = BaseDataModel::jsonDecode($jsonString);
       
        $userProfileDataModel = new UserProfileDataModel();

        if ($jsonData != null) {
          
            $userBasicInfo = UserBasicInfoDataModel::fromJson($jsonData);
            $userProfileDataModel->userProfileId = $userBasicInfo->userProfileId;
            $userProfileDataModel->firstName = $userBasicInfo->firstName;
            $userProfileDataModel->middleName = $userBasicInfo->middleName;
            $userProfileDataModel->lastName = $userBasicInfo->lastName;
            $userProfileDataModel->fullName = $userBasicInfo->fullName;
            $userProfileDataModel->status = $userBasicInfo->status;

            $userProfileDataModel->dateOfBirth = $jsonData->dateOfBirth ?? null;
            $userProfileDataModel->address = isset($jsonData->address) ? AddressDataModel::fromJson($jsonData->address) : null;
            $userProfileDataModel->email = $jsonData->email ?? null;
            $userProfileDataModel->phone = $jsonData->phone ?? null;
            $userProfileDataModel->mobile = $jsonData->mobile ?? null;
            $userProfileDataModel->password = $jsonData->password ?? null;
            $userProfileDataModel->userType = isset($jsonData->userType) ? UserTypeDataModel::fromJson($jsonData->userType) : null;
            $userProfileDataModel->lastModifiedDateTime = $jsonData->lastModifiedDateTime ?? null;
            $userProfileDataModel->user_photo = $jsonData->user_photo ?? null;
            $userProfileDataModel->totalPoint = $jsonData->totalPoint ?? null;
            $userProfileDataModel->pointPercentage = $jsonData->pointPercentage ?? null;
            $userProfileDataModel->ipAddress = $jsonData->ipAddress ?? null;
        }

        return $userProfileDataModel;
    }

    public static function fromDbResultSet($dbResultSet)
    {
        $userProfiles = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $userProfiles[] = UserProfileDataModel::fromDbResultRow($row);
            }
        }

        return $userProfiles;
    }

    public static function fromDbResultRow($row)
    {
        $userProfile = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $userProfile = new UserProfileDataModel();

            $userBasicInfo = UserBasicInfoDataModel::fromDbResultRow($objRow);
            $userProfile->userProfileId = $userBasicInfo->userProfileId;
            $userProfile->firstName = $userBasicInfo->firstName;
            $userProfile->middleName = $userBasicInfo->middleName;
            $userProfile->lastName = $userBasicInfo->lastName;
            $userProfile->status = $userBasicInfo->status;
            $userProfile->user_photo = $userBasicInfo->user_photo;
            $userProfile->fullName = $userBasicInfo->fullName;

            $userProfile->dateOfBirth = $objRow->dateOfBirth ?? null;
            $userProfile->address = AddressDataModel::fromDbResultRow($objRow);
            $userProfile->email = $objRow->email ?? null;
            $userProfile->phone = $objRow->phone ?? null;
            $userProfile->mobile = $objRow->mobile ?? null;
            $userProfile->password = $objRow->password ?? null;
            $userProfile->userType = UserTypeDataModel::fromDbResultRow($objRow);
            $role = RoleDataModel::fromDbResultRow($objRow);
            $userProfile->roles = $role ? [$role] : null;
            $userProfile->lastModifiedDateTime = $objRow->userProfileModifiedDateTime ?? null;
            $userProfile->totalPoint = $objRow->totalPoint ?? null;
            $userProfile->pointPercentage = $objRow->pointPercentage ?? null;
            $userProfile->ipAddress = $objRow->ipAddress ?? null;
        }

        return $userProfile;
    }
}
