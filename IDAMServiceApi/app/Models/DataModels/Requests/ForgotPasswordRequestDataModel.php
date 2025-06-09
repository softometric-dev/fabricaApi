<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class ForgotPasswordRequestDataModel extends ApiRequestDataModel
{
    public $passwordForgot;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $passwordForgot = $this->passwordForgot;

        // Validate mandatory inputs
        if (
            is_null($passwordForgot) ||
            (is_null($passwordForgot->email))
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'email');
        }

    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $forgotPasswordRequestDataModel = new ForgotPasswordRequestDataModel();

        if ($jsonData != null) {
            $passwordForgot = $jsonData->passwordForgot ?? null;
            if ($passwordForgot != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($passwordForgot);
                $forgotPasswordRequestDataModel->passwordForgot = $userProfileDataModel;
            }
        }
        return $forgotPasswordRequestDataModel;
    
    }
}