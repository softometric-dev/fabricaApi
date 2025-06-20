<?php

namespace App\Models\Common\DataModels;
use App\Models\Common\DataModels\BaseDataModel;

class DashBoardProductEnquiryGraphDataModel extends BaseDataModel 
{
    public $monthNumber;
    public $enquiryCount;
    public $monthName;

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
          $dashBoardProductEnquiryGraphDataModel = new DashBoardProductEnquiryGraphDataModel();
          if($jsonData != null)
          {
                      
              $dashBoardProductEnquiryGraphDataModel->monthNumber = $jsonData->monthNumber ?? null;
              $dashBoardProductEnquiryGraphDataModel->enquiryCount = $jsonData->enquiryCount ?? null;
              $dashBoardProductEnquiryGraphDataModel->monthName = $jsonData->monthName ?? null;
          }
          return $dashBoardProductEnquiryGraphDataModel;
   }

   public static function fromDbResultSet($dbResultSet)
   {
       $dashBoardProductEnquiryGraphs = array();
       if($dbResultSet != null)
       {
           foreach($dbResultSet as  $row)
           {
               $dashBoardProductEnquiryGraphs[] = DashBoardProductEnquiryGraphDataModel::fromDbResultRow($row);
           }
       }			
       return $dashBoardProductEnquiryGraphs;
   }

   public static function fromDbResultRow($row)
   {
			$DashBoardProductEnquiryGraph = null;
			if($row != null)
			{
				$objRow = is_object($row) ? $row : (object)$row;
				$DashBoardProductEnquiryGraph = new DashBoardProductEnquiryGraphDataModel();
				$DashBoardProductEnquiryGraph->monthNumber = property_exists($objRow,'monthNumber') ? $objRow->monthNumber : null;
				$DashBoardProductEnquiryGraph->enquiryCount = property_exists($objRow,'enquiryCount') ? $objRow->enquiryCount : null;
				$DashBoardProductEnquiryGraph->monthName = property_exists($objRow,'monthName') ? $objRow->monthName : null;

			}
			return $DashBoardProductEnquiryGraph;
	}
}