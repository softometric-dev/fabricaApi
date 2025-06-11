<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;

class ProductDataModel extends BaseDataModel
{
    public $productId;
    public $productName;
    public $size;
    public $image;
    public $specification;
    public $productModifiedDateTime;
    public $category;
    public $brand;

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
       
        $productDataModel = new ProductDataModel();

        if ($jsonData != null) {
          
            $productDataModel->productId = $jsonData->productId ?? null;
            $productDataModel->productName = $jsonData->productName ?? null;
            $productDataModel->size = $jsonData->size ?? null;
            $productDataModel->image = $jsonData->image ?? null;
            $productDataModel->specification = $jsonData->specification ?? null;
            $productDataModel->productModifiedDateTime = $jsonData->productModifiedDateTime ?? null;
            
             if (isset($jsonData->category)) {
               
               $productDataModel->category = CategoryDataModel::fromJson($jsonData->category);
             }  

            if (isset($jsonData->brand)) {
               
               $productDataModel->brand = BrandDataModel::fromJson($jsonData->brand);
             }  
        }

        return $productDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $products = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $products[] = ProductDataModel::fromDbResultRow($row);
            }
        }

        return $products;
    }

    public static function fromDbResultRow($row)
    {
        $product = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $product = new ProductDataModel();
            
            $product->productId = $objRow->productId ?? null;
            $product->productName = $objRow->productName ?? null;
            $product->size = $objRow->size ?? null;
            // $product->image = $objRow->image ?? null;

             // Append base_url if image exists and is a relative path
            $imagePath = $objRow->image ?? null;
            if (!empty($imagePath)) {
                // If not already a full URL, prepend base_url()
                if (!preg_match('/^https?:\/\//', $imagePath)) {
                    $imagePath = base_url($imagePath);
                }
            }
             $product->image = $imagePath;

            $product->specification = $objRow->specification ?? null;
            $product->productModifiedDateTime = $objRow->productModifiedDateTime ?? null;
            $product->category = CategoryDataModel::fromDbResultRow($objRow);
            $product->brand = BrandDataModel::fromDbResultRow($objRow);
        }

        return $product;
    }


     
}