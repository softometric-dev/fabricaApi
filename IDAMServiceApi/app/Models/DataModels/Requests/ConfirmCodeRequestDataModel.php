<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;

class ConfirmCodeRequestDataModel extends ApiRequestDataModel
{
    public $confirmCode;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $confirmCode = $this->confirmCode;

        // Validate mandatory inputs
        if (
            is_null($confirmCode) ||
            (is_null($confirmCode->email) && is_null($confirmCode->verificationCode))
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'email or verificationCode');
        }
    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $confirmCodeRequestDataModel = new ConfirmCodeRequestDataModel();
        if ($jsonData != null) {
            $confirmCode = $jsonData->confirmCode ?? null;
            if ($confirmCode != null) {
                $verifyEmailDataModel = VerifyEmailDataModel::fromJson($confirmCode);
                $confirmCodeRequestDataModel->confirmCode = $verifyEmailDataModel;
            }
        }
        return $confirmCodeRequestDataModel;
    }

}