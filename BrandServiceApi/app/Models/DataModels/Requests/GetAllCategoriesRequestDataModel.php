<?php
namespace App\Models\DataModels\Requests;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Libraries\{ParameterException};

class GetAllCategoriesRequestDataModel extends PaginationRequestDataModel
{

    public $pagination;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (is_null($pagination) ||
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
        $getAllCategoriesRequestDataModel = new GetAllCategoriesRequestDataModel();

        if ($jsonData !== null) {
            $pagination = $jsonData->pagination ?? null;
            if ($pagination !== null) {
                $paginationDataModel = PaginationDataModel::fromJson(json_encode($pagination));
                $getAllCategoriesRequestDataModel->pagination = $paginationDataModel;
            }
        }

        return $getAllCategoriesRequestDataModel;
    }
}