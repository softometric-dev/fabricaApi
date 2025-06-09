<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PermissionDataModel;


class CreatePermissionResponseDataModel extends ApiResponseDataModel
{

    public $newPermission;
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        //Validate mandatory inputs

        //Optional inputs and setting defaults			

    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $createRoleResponseDataModel = new CreateRoleResponseDataModel();
        if ($jsonData != null) {
            $newPermission = $jsonData->newPermission ?? null;
            if ($newPermission != null) {
                $permissionDataModel = PermissionDataModel::fromJson($newPermission);
                $createRoleResponseDataModel->newPermission = $permissionDataModel;
            }
        }
        return $createRoleResponseDataModel;
    }
}