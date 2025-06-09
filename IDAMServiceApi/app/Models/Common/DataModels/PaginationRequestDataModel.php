<?php

namespace App\Models\Common\DataModels;

use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;

abstract class PaginationRequestDataModel extends ApiRequestDataModel
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
        $paginationRequestDataModel = new static(); // Use `static` to support late static binding

        if ($jsonData != null)
        {
            $pagination = $jsonData->pagination ?? null;	
            if ($pagination != null)
            {					
                $paginationDataModel = PaginationDataModel::fromJson($pagination);					
                $paginationRequestDataModel->pagination = $paginationDataModel;	
            }
        }

        return $paginationRequestDataModel;
    }

    // Validate and enrich data
    public function validateAndEnrichData()
    {
        // Add validation and enrichment logic if needed
    }

   
}
