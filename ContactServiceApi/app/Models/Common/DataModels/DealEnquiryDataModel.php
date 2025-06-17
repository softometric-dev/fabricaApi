<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class DealEnquiryDataModel extends BaseDataModel
{
    public $dealEnquiryId;
    public $fullName;
    public $companyName;
    public $email;
    public $offerId;
    public $offerName;
    public $dealEnquiryModifiedDateTime;

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
       
        $dealEnquiryDataModel = new DealEnquiryDataModel();

        if ($jsonData != null) {
          
            $dealEnquiryDataModel->dealEnquiryId = $jsonData->dealEnquiryId ?? null;
            $dealEnquiryDataModel->fullName = $jsonData->fullName ?? null;
            $dealEnquiryDataModel->companyName = $jsonData->companyName ?? null;
            $dealEnquiryDataModel->email = $jsonData->email ?? null;
            $dealEnquiryDataModel->offerId = $jsonData->offerId ?? null;
            $dealEnquiryDataModel->offerName = $jsonData->offerName ?? null;
            $dealEnquiryDataModel->dealEnquiryModifiedDateTime = $jsonData->dealEnquiryModifiedDateTime ?? null;
            
        }

        return $dealEnquiryDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $dealEnquiries = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $dealEnquiries[] = DealEnquiryDataModel::fromDbResultRow($row);
            }
        }

        return $dealEnquiries;
    }

    public static function fromDbResultRow($row)
    {

        $dealEnquiry = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $dealEnquiry = new DealEnquiryDataModel();
            
            $dealEnquiry->dealEnquiryId = $objRow->dealEnquiryId ?? null;
            $dealEnquiry->fullName = $objRow->fullName ?? null;
            $dealEnquiry->companyName = $objRow->companyName ?? null;
            $dealEnquiry->email = $objRow->email ?? null;
            $dealEnquiry->offerId = $objRow->offerId ?? null;
            $dealEnquiry->offerName = $objRow->offerName ?? null;
            $dealEnquiry->dealEnquiryModifiedDateTime = $objRow->dealEnquiryModifiedDateTime ?? null;
        }

        return $dealEnquiry;
    }


     
}