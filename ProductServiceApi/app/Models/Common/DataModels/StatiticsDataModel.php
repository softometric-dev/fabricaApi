<?php

namespace App\Models\Common\DataModels;
use App\Models\Common\DataModels\BaseDataModel;

class StatiticsDataModel extends BaseDataModel 
{

    public $searchBy;
    public $value;
    public $count;
    // Constructor
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
			$statiticsDataModel = new StatiticsDataModel();
			if($jsonData != null)
			{
						
				$statiticsDataModel->searchBy = $jsonData->searchBy ?? null;
                $statiticsDataModel->value = $jsonData->value ?? null;
                $statiticsDataModel->count = $jsonData->count ?? null;
			}
			return $statiticsDataModel;
	}
    public static function fromDbResultSet($dbResultSet)
		{
			$statitics = array();
			if($dbResultSet != null)
			{
				foreach($dbResultSet as  $row)
				{
					$statitics[] = StatiticsDataModel::fromDbResultRow($row);
				}
			}			
			return $statitics;
		}

		public static function fromDbResultRow($row)
		{
			$statitics = null;
			if($row != null)
			{
				$objRow = is_object($row) ? $row : (object)$row;
				$statitics = new StatiticsDataModel();
				$statitics->searchBy = property_exists($objRow,'searchBy') ? $objRow->searchBy : null;
				$statitics->value = property_exists($objRow,'value') ? $objRow->value : null;
				$statitics->count = property_exists($objRow,'count') ? $objRow->count : null;

			}
			return $statitics;
		}

}