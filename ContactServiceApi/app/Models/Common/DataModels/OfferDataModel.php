<?php

namespace App\Models\Common\DataModels;

use App\Models\Common\DataModels\BaseDataModel;

class OfferDataModel extends BaseDataModel
{
    public $offerId;
    public $offerName;
    public $title;
    public $date;
    public $description;
    public $image;
    public $offerModifiedDateTime;

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
       
        $offerDataModel = new OfferDataModel();

        if ($jsonData != null) {
          
            $offerDataModel->offerId = $jsonData->offerId ?? null;
            $offerDataModel->offerName = $jsonData->offerName ?? null;
            $offerDataModel->title = $jsonData->title ?? null;
            $offerDataModel->date = $jsonData->date ?? null;
            $offerDataModel->description = $jsonData->description ?? null;
            $offerDataModel->image = $jsonData->image ?? null;
            $offerDataModel->offerModifiedDateTime = $jsonData->offerModifiedDateTime ?? null;
            
        }

        return $offerDataModel;
    }

     public static function fromDbResultSet($dbResultSet)
    {
        $offers = [];

        if ($dbResultSet != null) {
            foreach ($dbResultSet as $row) {
                $offers[] = OfferDataModel::fromDbResultRow($row);
            }
        }

        return $offers;
    }

    public static function fromDbResultRow($row)
    {

        $offer = null;

        if ($row != null) {
            $objRow = is_object($row) ? $row : (object)$row;
            $offer = new OfferDataModel();
            
            $offer->offerId = $objRow->offerId ?? null;
            $offer->offerName = $objRow->offerName ?? null;
            $offer->title = $objRow->title ?? null;
            $offer->date = $objRow->date ?? null;
            $offer->description = $objRow->description ?? null;

           // Append base_url if image exists and is a relative path
            $imagePath = $objRow->image ?? null;
            if (!empty($imagePath)) {
                // If not already a full URL, prepend base_url()
                if (!preg_match('/^https?:\/\//', $imagePath)) {
                    $imagePath = base_url($imagePath);
                }
            }
             $offer->image = $imagePath;
             
            $offer->offerModifiedDateTime = $objRow->offerModifiedDateTime ?? null;
            
        }

        return $offer;
    }


     
}