<?php

namespace App\Models\Common\DataModels;

use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;

abstract class PaginationResponseDataModel extends ApiResponseDataModel
{
    public $pagination;

    // Constructor
    public function __construct()
    {
        parent::__construct();
    }

    // Create an instance from JSON string
    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $paginationResponseDataModel = new PaginationResponseDataModel(); // Use `static` for late static binding

        if ($jsonData != null)
        {
            $pagination = $jsonData->pagination ?? null;	
            if ($pagination != null)
            {					
                $paginationDataModel = PaginationDataModel::fromJson($pagination);					
                $paginationResponseDataModel->pagination = $paginationDataModel;	
            }
        }

        return $paginationResponseDataModel;
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }

}
