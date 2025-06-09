<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\StatusDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class ResetPasswordRequestDataModel extends ApiRequestDataModel
{

    public $userProfileId;
    public $currentPassword;
    public $newPassword;
    public $confirmPassword;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Validate mandatory inputs
        if (
            empty($this->userProfileId) ||
            empty($this->currentPassword) ||
            empty($this->newPassword) ||
            empty($this->confirmPassword)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'userProfileId, currentPassword, newPassword, confirmPassword');
        }


        // Implement additional validation logic here if needed
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $resetPasswordRequestDataModel = new ResetPasswordRequestDataModel();
        if ($jsonData != null) {
            $resetPasswordRequestDataModel->userProfileId = $jsonData->userProfileId ?? null;
            $resetPasswordRequestDataModel->currentPassword = $jsonData->currentPassword ?? null;
            $resetPasswordRequestDataModel->newPassword = $jsonData->newPassword ?? null;
            $resetPasswordRequestDataModel->confirmPassword = $jsonData->confirmPassword ?? null;
        }
        return $resetPasswordRequestDataModel;
    }

}