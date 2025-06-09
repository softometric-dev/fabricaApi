<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\StatusDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class UpdateUserRequestDataModel extends ApiRequestDataModel
{
    public $user;
    public $role;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $user = $this->user;
        $role = $this->role;

        // Validate mandatory inputs
        if (empty($user) || empty($user->userProfileId) || empty($user->lastModifiedDateTime)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'userProfileId, lastModifiedDateTime');
        }

        // Optional inputs and setting defaults        
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $updateUserRequestDataModel = new UpdateUserRequestDataModel();
        if ($jsonData != null) {
            $user = $jsonData->user ?? null;
            if ($user != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($user);
                $updateUserRequestDataModel->user = $userProfileDataModel;
            }

            $role = $jsonData->role ?? null;
            if ($role != null) {
                $roleDataModel = RoleDataModel::fromJson($role);
                $updateUserRequestDataModel->role = $roleDataModel;
            }
        }
        return $updateUserRequestDataModel;
    }
}