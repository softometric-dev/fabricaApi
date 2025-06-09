<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;

class GetAllUserTypesRequestDataModel extends PaginationRequestDataModel
{
    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            is_null($pagination) ||
            is_null($pagination->currentPage) ||
            is_null($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'current page, page size');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getAllUserTypesRequestDataModel = new GetAllUserTypesRequestDataModel();
        if ($jsonData != null) {
            $pagination = $jsonData->pagination ?? null;
            if ($pagination != null) {
                $paginationDataModel = PaginationDataModel::fromJson($pagination);
                $getAllUserTypesRequestDataModel->pagination = $paginationDataModel;
            }
        }
        return $getAllUserTypesRequestDataModel;
    }
}