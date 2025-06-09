<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;

class GetUserStatiticsRequestDataModel extends PaginationRequestDataModel
{

    public $searchBy;
    public $filter;
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

        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getUserStatiticsRequestDataModel = new GetUserStatiticsRequestDataModel();
        if ($jsonData != null) {
            $getUserStatiticsRequestDataModel->searchBy = isset($jsonData->searchBy) ? $jsonData->searchBy : null;
            $getUserStatiticsRequestDataModel->filter = isset($jsonData->filter) ? $jsonData->filter : null;
        }

        $pagination = $jsonData->pagination ?? null;
        if ($pagination != null) {
            $paginationDataModel = PaginationDataModel::fromJson($pagination);
            $getUserStatiticsRequestDataModel->pagination = $paginationDataModel;
        }
        return $getUserStatiticsRequestDataModel;
    }

}