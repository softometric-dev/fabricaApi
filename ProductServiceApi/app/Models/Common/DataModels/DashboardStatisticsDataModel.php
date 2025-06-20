<?php

namespace App\Models\Common\DataModels;
use App\Models\Common\DataModels\BaseDataModel;

class DashboardStatisticsDataModel extends BaseDataModel 
{

    public $totalProducts;
    public $totalBrands;
    public $totalCategories;
    public $activeDeals;
    public function __construct()
    { 
        parent::__construct();
    }
    public function validateAndEnrichData()
	{
	}

    public static function fromJson($jsonString)
    {			
          $jsonData = BaseDataModel::jsonDecode($jsonString);
          $dashboardStatisticsDataModel = new DashboardStatisticsDataModel();
          if($jsonData != null)
          {
                      
              $dashboardStatisticsDataModel->totalProducts = $jsonData->totalProducts ?? null;
              $dashboardStatisticsDataModel->totalBrands = $jsonData->totalBrands ?? null;
              $dashboardStatisticsDataModel->totalCategories = $jsonData->totalCategories ?? null;
              $dashboardStatisticsDataModel->activeDeals = $jsonData->activeDeals ?? null;
          }
          return $dashboardStatisticsDataModel;
   }

   public static function fromDbResultSet($dbResultSet)
   {
       $dashBoardStatistics = array();
       if($dbResultSet != null)
       {
           foreach($dbResultSet as  $row)
           {
               $dashBoardStatistics[] = DashboardStatisticsDataModel::fromDbResultRow($row);
           }
       }			
       return $dashBoardStatistics;
   }

   public static function fromDbResultRow($row)
   {
			$dashBoardStatistic = null;
			if($row != null)
			{
				$objRow = is_object($row) ? $row : (object)$row;
				$dashBoardStatistic = new DashboardStatisticsDataModel();
				$dashBoardStatistic->totalProducts = property_exists($objRow,'totalProducts') ? $objRow->totalProducts : null;
				$dashBoardStatistic->totalBrands = property_exists($objRow,'totalBrands') ? $objRow->totalBrands : null;
				$dashBoardStatistic->totalCategories = property_exists($objRow,'totalCategories') ? $objRow->totalCategories : null;
				$dashBoardStatistic->activeDeals = property_exists($objRow,'activeDeals') ? $objRow->activeDeals : null;

			}
			return $dashBoardStatistic;
	}


}