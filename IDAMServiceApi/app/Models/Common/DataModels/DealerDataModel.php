<?php

namespace App\Models\Common\DataModels;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\AddressDataModel;

class DealerDataModel extends BaseDataModel 
{

        public $dealerId;
        public $dealerName;
        public $address;
        public $taxId;
		public $website;
		public $email;
		public $phone;
		public $mobile;
        public $dealerModifiedDateTime;
		public $status;
      // Constructor
      public function __construct()
      { 
          parent::__construct();
      }
  
      // Validate and enrich data
      public function validateAndEnrichData()
      {
          // Add validation and enrichment logic if needed
      }
      public static function fromJson($jsonString)
      {
          $jsonData = BaseDataModel::jsonDecode($jsonString);
          $dealerDataModel = new DealerDataModel();
  
       
          if ($jsonData !== null) {
            
              $dealerDataModel->dealerId = $jsonData->dealerId ?? null;
              $dealerDataModel->dealerName = $jsonData->dealerName ?? null;
            
              if (isset($jsonData->address)) {
                  $dealerDataModel->address = AddressDataModel::fromJson($jsonData->address);
              }
  
              $dealerDataModel->taxId = $jsonData->taxId ?? null;
              $dealerDataModel->website = $jsonData->website ?? null;
              $dealerDataModel->email = $jsonData->email ?? null;
              $dealerDataModel->phone = $jsonData->phone ?? null;
              $dealerDataModel->mobile = $jsonData->mobile ?? null;
              $dealerDataModel->dealerModifiedDateTime = $jsonData->dealerModifiedDateTime ?? null;
              $dealerDataModel->status = $jsonData->status ?? null;
          }
     
  
          return $dealerDataModel;
      }

      public static function fromDbResultSet($dbResultSet)
      {
          $dealers = [];
  
          foreach ($dbResultSet as $row) {
              $dealers[] = DealerDataModel::fromDbResultRow($row);
          }
  
          return $dealers;
      }

      public static function fromDbResultRow($row)
    {
        $objRow = is_object($row) ? $row : (object) $row;
        $dealer = new DealerDataModel();

        $dealer->dealerId = $objRow->dealerId ?? null;
        $dealer->dealerName = $objRow->dealerName ?? null;
        $dealer->address = AddressDataModel::fromDbResultRow($objRow);
        $dealer->taxId = $objRow->taxId ?? null;
        $dealer->website = $objRow->website ?? null;
        $dealer->email = $objRow->email ?? null;
        $dealer->phone = $objRow->phone ?? null;
        $dealer->mobile = $objRow->mobile ?? null;
        $dealer->dealerModifiedDateTime = $objRow->dealerModifiedDateTime ?? null;
        $dealer->status = $objRow->status ?? null;

        return $dealer;
    }

}