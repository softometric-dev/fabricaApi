<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\CategoryDataModel;

class BrandDataModel extends BaseDataModel
{
    public $brandId;
    public $brandName;
    public $image;
    public $brandModifiedDateTime;
    public $category;

     public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        // Add your validation and enrichment logic here
    }

    public static function fromJson($jsonString)
    {
        
        $jsonData = BaseDataModel::jsonDecode($jsonString);
       
        $brandDataModel = new BrandDataModel();

        if ($jsonData != null) {
          
            $brandDataModel->brandId = $jsonData->brandId ?? null;
            $brandDataModel->brandName = $jsonData->brandName ?? null;
            $brandDataModel->image = $jsonData->image ?? null;
            $brandDataModel->brandModifiedDateTime = $jsonData->brandModifiedDateTime ?? null;
            
             if (isset($jsonData->category)) {
               
               $brandDataModel->category = CategoryDataModel::fromJson($jsonData->category);
             }  
        }

        return $brandDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $brands = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $brands[] = BrandDataModel::fromDbResultRow($row);
            }
        }

        return $brands;
    }

    public static function fromDbResultRow($row)
    {
        $brand = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $brand = new BrandDataModel();
            
            $brand->brandId = $objRow->brandId ?? null;
            $brand->brandName = $objRow->brandName ?? null;
            $brand->image = $objRow->image ?? null;
            $brand->brandModifiedDateTime = $objRow->brandModifiedDateTime ?? null;
            $brand->category = CategoryDataModel::fromDbResultRow($objRow);
        }

        return $brand;
    }


     
}