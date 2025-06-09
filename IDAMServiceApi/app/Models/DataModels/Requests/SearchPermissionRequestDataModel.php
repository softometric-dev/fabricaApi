<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;

class SearchPermissionRequestDataModel extends PaginationRequestDataModel
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
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'current page, page size');
        }

        // Optional inputs and setting defaults
    }
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchPermissionRequestDataModel = new SearchPermissionRequestDataModel();
        if ($jsonData != null) {
            $pagination = $jsonData->pagination ?? null;
            if ($pagination != null) {
                $paginationDataModel = PaginationDataModel::fromJson($pagination);
                $searchPermissionRequestDataModel->pagination = $paginationDataModel;
            }
        }
        return $searchPermissionRequestDataModel;
    }
}