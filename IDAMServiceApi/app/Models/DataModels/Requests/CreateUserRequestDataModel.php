<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\StatusDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\VerifyEmailDataModel;

class CreateUserRequestDataModel extends ApiRequestDataModel
{
    public $newUser;
    public $role;
    public $confirmCode;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $newUser = $this->newUser;
        $role = $this->role;

        // Validate mandatory inputs
        if (
            is_null($newUser) ||
            is_null($newUser->userType) ||
            is_null($newUser->userType->userTypeId) ||
            empty($newUser->lastName) ||
            empty($newUser->ipAddress) ||
            empty($newUser->email) ||
            is_null($role) ||
            empty($role->roleId)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'last name, email, password, roleId,ipAddress');
        }

        // Optional inputs and setting defaults
        if (is_null($newUser->status)) {
            $this->newUser->status = new StatusDataModel();
        }
        $this->newUser->status->statusId = STATUS_ACTIVE;

        // Generate a password if not set
        if (empty($this->newUser->password)) {
            $passwordLength = 10; // You can adjust the length as needed
            $passwordCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
            $generatedPassword = substr(str_shuffle($passwordCharacters), 0, $passwordLength);
            $this->newUser->password = $generatedPassword;
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $createUserRequestDataModel = new CreateUserRequestDataModel();
        if ($jsonData != null) {
            $newUser = $jsonData->newUser ?? null;
            if ($newUser != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($newUser);
                $createUserRequestDataModel->newUser = $userProfileDataModel;
            }

            $role = $jsonData->role ?? null;
            if ($role != null) {
                $roleDataModel = RoleDataModel::fromJson($role);
                $createUserRequestDataModel->role = $roleDataModel;
            }
            $confirmCode = $jsonData->confirmCode ?? null;
            if ($confirmCode != null) {
                $verifyEmailDataModel = VerifyEmailDataModel::fromJson($confirmCode);
                $createUserRequestDataModel->confirmCode = $verifyEmailDataModel;
            }
            
        }
        return $createUserRequestDataModel;
    }
}

