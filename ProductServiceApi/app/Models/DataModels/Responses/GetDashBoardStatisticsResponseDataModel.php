<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\DashboardStatisticsDataModel;
use App\Models\Common\DataModels\DashBoardProductEnquiryGraphDataModel;

class GetDashBoardStatisticsResponseDataModel extends ApiResponseDataModel
{
    public $statitics;
    public $productEnquiryGraph;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Validate mandatory inputs and set defaults if necessary
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getDashBoardStatisticsResponseDataModel = new GetDashBoardStatisticsResponseDataModel();

        if ($jsonData !== null) {
            $statitics = $jsonData->statitics ?? null;
            if ($statitics !== null) {
                $dashboardStatisticsDataModel = DashboardStatisticsDataModel::fromJson($statitics);
                $getDashBoardStatisticsResponseDataModel->statitics = $dashboardStatisticsDataModel;
            }

            $productEnquiryGraph = $jsonData->productEnquiryGraph ?? null;
            if ($productEnquiryGraph !== null) {
                $dashBoardProductEnquiryGraphDataModel = DashBoardProductEnquiryGraphDataModel::fromJson($productEnquiryGraph);
                $getDashBoardStatisticsResponseDataModel->productEnquiryGraph = $dashBoardProductEnquiryGraphDataModel;
            }


        }

        return $getDashBoardStatisticsResponseDataModel;
    }

}