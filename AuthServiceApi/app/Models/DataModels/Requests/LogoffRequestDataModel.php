<?php

namespace App\Models\DataModels\Requests;

use App\Libraries\CustomExceptionHandler\ParameterException;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\StatusDataModel;

class LogoffRequestDataModel extends ApiRequestDataModel
{
    public $user;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $user = $this->user;

        // Validate mandatory inputs (if any)
        // Add validation logic if required

        // Optional inputs and setting defaults
        if (empty($user->status)) {
            $this->user->status = new StatusDataModel();
        }
        $this->user->status->statusId = STATUS_INACTIVE;
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $logoffRequestDataModel = new LogoffRequestDataModel();

        if ($jsonData !== null) {
            $user = $jsonData->user ?? null;
            if ($user !== null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($user);
                $logoffRequestDataModel->user = $userProfileDataModel;
            }
        }

        return $logoffRequestDataModel;
    }
}
