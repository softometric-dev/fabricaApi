<?php

namespace App\Models\DataModels\Requests;

use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;

class GetDashboardStatisticsRequestDataModel extends ApiRequestDataModel
{
    public $dashBoardStatistic;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $dashBoardStatistic = $this->dashBoardStatistic;
   
        // Validate mandatory inputs
        if (
            empty($dashBoardStatistic)
            
        ) {
              
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'pass dashBoardStatistic object');
        }
      
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getDashboardStatisticsRequestDataModel = new GetDashboardStatisticsRequestDataModel();

        if ($jsonData !== null) {
            $getDashboardStatisticsRequestDataModel->dashBoardStatistic = $jsonData->dashBoardStatistic ?? null;
        }
    
        return $getDashboardStatisticsRequestDataModel;
        
    }

}