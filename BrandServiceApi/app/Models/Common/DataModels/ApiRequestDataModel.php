<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

abstract class ApiRequestDataModel extends BaseDataModel
{
    public $authInfo;

    public function __construct()
    {
        parent::__construct();
    }
}
