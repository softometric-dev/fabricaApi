<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class CategoryDataModel extends UserBasicInfoDataModel
{
    public $categoryId;
    public $categoryName;

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
       
        $categoryDataModel = new CategoryDataModel();

        if ($jsonData != null) {
          
            $categoryDataModel->categoryId = $jsonData->categoryId ?? null;
            $categoryDataModel->categoryName = $jsonData->categoryName ?? null;
        }

        return $categoryDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $categories = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $categories[] = CategoryDataModel::fromDbResultRow($row);
            }
        }

        return $categories;
    }

    public static function fromDbResultRow($row)
    {
        $category = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $category = new CategoryDataModel();
            
            $category->categoryId = $objRow->categoryId ?? null;
            $category->categoryName = $objRow->categoryName ?? null;
        }

        return $category;
    }


     
}