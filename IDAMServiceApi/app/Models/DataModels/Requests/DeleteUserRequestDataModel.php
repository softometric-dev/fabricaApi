<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class DeleteUserRequestDataModel extends ApiRequestDataModel
{
    public $userToDelete;
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $userToDelete = $this->userToDelete;

        // Validate mandatory inputs
        if (
            is_null($userToDelete) ||
            (is_null($userToDelete->userProfileId) && is_null($userToDelete->email))
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'userProfileId or email');
        }

        // Optional inputs and setting defaults
        $this->userToDelete->status = STATUS_INACTIVE;
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $deleteUserRequestDataModel = new DeleteUserRequestDataModel();
        if ($jsonData != null) {
            $userToDelete = $jsonData->userToDelete ?? null;
            if ($userToDelete != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($userToDelete);
                $deleteUserRequestDataModel->userToDelete = $userProfileDataModel;
            }
        }
        return $deleteUserRequestDataModel;
    }
}