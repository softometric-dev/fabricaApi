<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class ProductEnquiryDataModel extends BaseDataModel
{
    public $productEnquiryId;
    public $fullName;
    public $companyName;
    public $email;
    public $productEnquiryModifiedDateTime;

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
       
        $productEnquiryDataModel = new ProductEnquiryDataModel();

        if ($jsonData != null) {
          
            $productEnquiryDataModel->productEnquiryId = $jsonData->productEnquiryId ?? null;
            $productEnquiryDataModel->fullName = $jsonData->fullName ?? null;
            $productEnquiryDataModel->companyName = $jsonData->companyName ?? null;
            $productEnquiryDataModel->email = $jsonData->email ?? null;
            $productEnquiryDataModel->productEnquiryModifiedDateTime = $jsonData->productEnquiryModifiedDateTime ?? null;
            
        }

        return $productEnquiryDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $productEnquiries = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $productEnquiries[] = ProductEnquiryDataModel::fromDbResultRow($row);
            }
        }

        return $productEnquiries;
    }

    public static function fromDbResultRow($row)
    {

        $productEnquiry = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $productEnquiry = new ProductEnquiryDataModel();
            
            $productEnquiry->productEnquiryId = $objRow->productEnquiryId ?? null;
            $productEnquiry->fullName = $objRow->fullName ?? null;
            $productEnquiry->companyName = $objRow->companyName ?? null;
            $productEnquiry->email = $objRow->email ?? null;
            $productEnquiry->productEnquiryModifiedDateTime = $objRow->productEnquiryModifiedDateTime ?? null;
        }

        return $productEnquiry;
    }


     
}