<?php

namespace App\Models\DataModels\Requests;

use App\Libraries\ParameterException;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\StatusDataModel;

class LoginRequestDataModel extends ApiRequestDataModel
{
    public $user;
    public $ipAddress;

    public function __construct()
    {
        parent::__construct();
        $this->ipAddress = $this->getHeaderIpAddress();
    }

    public function validateAndEnrichData()
    {
        $user = $this->user;

        // Validate mandatory inputs
        if (empty($user) || empty($user->email) || empty($user->password)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'email, password');
        }

        // Optional inputs and setting defaults
        if (empty($user->status)) {
            $this->user->status = new StatusDataModel();
        }
        $this->user->status->statusId = STATUS_ACTIVE;
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);

        $loginRequestDataModel = new LoginRequestDataModel();

        if ($jsonData !== null) {
            $user = $jsonData->user ?? null;

            if ($user !== null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($user);
                $loginRequestDataModel->user = $userProfileDataModel;
            }

            // Retrieve IP from headers
            $loginRequestDataModel->ipAddress = self::getHeaderIpAddress();
            
        }

        return $loginRequestDataModel;
    }

    public static function getHeaderIpAddress()
    {
        $headers = getallheaders();
        
        if (isset($headers['ipAddress'])) {
            return $headers['ipAddress'];
        }

        return 'UNKNOWN';
    }
}
