<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class PartnerDataModel extends BaseDataModel
{
    public $partnerId;
    public $fullName;
    public $companyName;
    public $email;
    public $comment;
    public $partnerModifiedDateTime;

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
       
        $partnerDataModel = new PartnerDataModel();

        if ($jsonData != null) {
          
            $partnerDataModel->partnerId = $jsonData->partnerId ?? null;
            $partnerDataModel->fullName = $jsonData->fullName ?? null;
            $partnerDataModel->companyName = $jsonData->companyName ?? null;
            $partnerDataModel->email = $jsonData->email ?? null;
            $partnerDataModel->comment = $jsonData->comment ?? null;
            $partnerDataModel->partnerModifiedDateTime = $jsonData->partnerModifiedDateTime ?? null;
            
        }

        return $partnerDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $partners = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $partners[] = PartnerDataModel::fromDbResultRow($row);
            }
        }

        return $partners;
    }

    public static function fromDbResultRow($row)
    {

        $partner = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $partner = new PartnerDataModel();
            
            $partner->partnerId = $objRow->partnerId ?? null;
            $partner->fullName = $objRow->fullName ?? null;
            $partner->companyName = $objRow->companyName ?? null;
            $partner->email = $objRow->email ?? null;
            $partner->comment = $objRow->comment ?? null;
            $partner->partnerModifiedDateTime = $objRow->partnerModifiedDateTime ?? null;
        }

        return $partner;
    }


     
}