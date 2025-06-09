<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class GetUserRolesRequestDataModel extends ApiRequestDataModel
{
    public $user;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $user = $this->user;

        // Validate mandatory inputs
        if (is_null($user) || (is_null($user->userProfileId) && is_null($user->email))) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'user profile id, email');
        }

        // Optional inputs and setting defaults
    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getUserRolesRequestDataModel = new GetUserRolesRequestDataModel();
        if ($jsonData != null) {
            $user = $jsonData->user ?? null;
            if ($user != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($user);
                $getUserRolesRequestDataModel->user = $userProfileDataModel;
            }
        }
        return $getUserRolesRequestDataModel;
    }
}